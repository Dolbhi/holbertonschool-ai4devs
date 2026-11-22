#!/usr/bin/env bash
# .github/scripts/sync-trello-branches.sh
set -euo pipefail

API="https://api.trello.com/1"
AUTH=(--data-urlencode "key=$TRELLO_KEY" --data-urlencode "token=$TRELLO_TOKEN")

# Manual run: one card. Otherwise: every open card with the requested label.
if [[ -n "${CARD_SHORT_LINK:-}" ]]; then
  cards=$(curl -fsSG "$API/cards/$CARD_SHORT_LINK" "${AUTH[@]}" \
    --data-urlencode "fields=id,name,desc,shortLink" | jq -c '[.]')
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
  local card="$1" id short name desc repo slug branch default base_sha

  id=$(jq -r '.id' <<<"$card")
  short=$(jq -r '.shortLink' <<<"$card")
  name=$(jq -r '.name' <<<"$card")
  desc=$(jq -r '.desc // ""' <<<"$card")

  repo=$(grep -oiE '^[[:space:]]*repo:[[:space:]]*[A-Za-z0-9._-]+/[A-Za-z0-9._-]+' <<<"$desc" \
    | head -n1 | sed -E 's/^[[:space:]]*repo:[[:space:]]*//I' || true)
  if [[ -z "$repo" ]]; then
    echo "skip $short: no 'repo: owner/name' line"; return 0
  fi
  if ! grep -qxF "$repo" "$ALLOWED_REPOS_FILE"; then
    echo "skip $short: $repo is not allowlisted"; return 0
  fi

  slug=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' | cut -c1-40 | sed -E 's/-+$//')
  branch="trello/$short-$slug"

  if gh api "repos/$repo/git/ref/heads/$branch" >/dev/null 2>&1; then
    echo "exists: $repo $branch"; return 0
  fi

  default=$(gh api "repos/$repo" --jq '.default_branch')
  base_sha=$(gh api "repos/$repo/git/ref/heads/$default" --jq '.object.sha')
  gh api -X POST "repos/$repo/git/refs" \
    -f "ref=refs/heads/$branch" -f "sha=$base_sha" >/dev/null
  echo "created: $repo $branch"

  # Attach only on creation so scheduled runs don't add duplicate attachments
  curl -fsS -X POST "$API/cards/$id/attachments" "${AUTH[@]}" \
    --data-urlencode "url=https://github.com/$repo/tree/$branch" \
    --data-urlencode "name=Branch: $branch" >/dev/null
}

# Process each card; one failure shouldn't stop the others
jq -c '.[]' <<<"$cards" | while read -r card; do
  process_card "$card" || echo "::warning::failed to process card: $(jq -r '.shortLink' <<<"$card")"
done