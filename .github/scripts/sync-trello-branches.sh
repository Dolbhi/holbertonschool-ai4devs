#!/usr/bin/env bash
# .github/scripts/sync-trello-branches.sh
set -euo pipefail

API="https://api.trello.com/1"
AUTH=(--data-urlencode "key=$TRELLO_KEY" --data-urlencode "token=$TRELLO_TOKEN")

# Manual run: one card. Otherwise: every open card with the requested label.
if [[ -n "${CARD_SHORT_LINK:-}" ]]; then
  cards=$(curl -fsSG "$API/cards/$CARD_SHORT_LINK" "${AUTH[@]}" \
    --data-urlencode "fields=id,name,desc,shortLink,labels" | jq -c '[.]')
else
  label="${TRELLO_LABEL:-${CARD_LABEL:-${LABEL:-}}}"
  if [[ -z "$label" ]]; then
    echo "::error::CARD_SHORT_LINK or TRELLO_LABEL must be provided"
    exit 1
  fi

  cards=$(curl -fsSG "$API/search" "${AUTH[@]}" \
    --data-urlencode "query=label:\"$label\"" \
    --data-urlencode "cards=open" \
    --data-urlencode "cards_limit=1000" \
    --data-urlencode "modelTypes=cards" \
    --data-urlencode "card_fields=id,name,desc,shortLink,labels" |
    jq -c --arg label "$label" '
        (.cards // .)
        | map(select((.labels // []) | any(.name == $label or .id == $label)))
      ')
fi

process_card() {
  local card="$1" id short name desc slug repos repo default base_sha branch

  id=$(jq -r '.id' <<<"$card")
  short=$(jq -r '.shortLink' <<<"$card")
  name=$(jq -r '.name' <<<"$card")
  desc=$(jq -r '.desc // ""' <<<"$card")

  slug=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' | cut -c1-40 | sed -E 's/-+$//')

  repos=""
  frontend_label="${FRONTEND_LABEL:-Frontend}"
  backend_label="${BACKEND_LABEL:-Backend}"

  if jq -e --arg label "$frontend_label" \
    '(.labels // []) | any(.name == $label)' <<<"$card" >/dev/null; then
    if [[ -z "${FRONTEND_REPO:-}" ]]; then
      echo "skip $short: FRONTEND_REPO is not configured"; return 0
    fi
    repos="${repos}${FRONTEND_REPO}"$'\n'
  fi
  if jq -e --arg label "$backend_label" \
    '(.labels // []) | any(.name == $label)' <<<"$card" >/dev/null; then
    if [[ -z "${BACKEND_REPO:-}" ]]; then
      echo "skip $short: BACKEND_REPO is not configured"; return 0
    fi
    repos="${repos}${BACKEND_REPO}"$'\n'
  fi
  repos=$(printf '%s' "$repos" | sed '/^$/d')

  if [[ -z "$repos" ]]; then
    echo "skip $short: no 'Frontend' or 'Backend' label"; return 0
  fi

  while IFS= read -r repo; do
    branch="trello/$short-$slug"

    if gh api "repos/$repo/git/ref/heads/$branch" >/dev/null 2>&1; then
      echo "exists: $repo $branch"; continue
    fi

    default=$(gh api "repos/$repo" --jq '.default_branch')
    base_sha=$(gh api "repos/$repo/git/ref/heads/$default" --jq '.object.sha')
    gh api -X POST "repos/$repo/git/refs" \
      -f "ref=refs/heads/$branch" -f "sha=$base_sha" >/dev/null
    echo "created: $repo $branch"

    issue_template=$(mktemp)
    {
      printf '# Agent Task\n\n'
      printf '## Name\n\n%s\n\n' "$name"
      printf '## Description\n\n'
      if [[ -n "$desc" ]]; then
        printf '%s\n\n' "$desc"
      else
        printf 'No description provided.\n\n'
      fi
      printf '## Trello Short Link\n\n%s\n' "$short"
    } >"$issue_template"

    issue_template_content=$(base64 -w0 "$issue_template")
    rm -f "$issue_template"
    gh api -X PUT "repos/$repo/contents/.github/ISSUE_TEMPLATE/agent-task.md" \
      -f "message=Add agent task template for $short" \
      -f "branch=$branch" \
      -f "content=$issue_template_content" >/dev/null

    # Attach only on creation so scheduled runs don't add duplicate attachments
    curl -fsS -X POST "$API/cards/$id/attachments" "${AUTH[@]}" \
      --data-urlencode "url=https://github.com/$repo/tree/$branch" \
      --data-urlencode "name=Branch: $branch" >/dev/null
  done <<<"$repos"
}

# Process each card; one failure shouldn't stop the others
jq -c '.[]' <<<"$cards" | while read -r card; do
  process_card "$card" || echo "::warning::failed to process card: $(jq -r '.shortLink' <<<"$card")"
done