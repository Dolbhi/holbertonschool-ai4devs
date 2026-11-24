#!/usr/bin/env bash
# .github/scripts/sync-trello-branches.sh
set -euo pipefail

API="https://api.trello.com/1"
if [[ -z "${TRELLO_KEY:-}" || -z "${TRELLO_TOKEN:-}" ]]; then
  echo "::error::TRELLO_KEY and TRELLO_TOKEN must be provided"
  exit 1
fi
if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "::error::GH_TOKEN must be provided"
  exit 1
fi
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

# Builds the issue body Copilot will work from.
build_issue_body() {
  local desc="$1" short="$2"
  printf '%s\n\n' "${desc:-No description provided.}"
  printf 'Trello card: https://trello.com/c/%s\n\n' "$short"
  printf 'Please implement this task in this repository. '
  printf 'Follow the conventions in AGENTS.md at the repository root. '
  printf 'Run the validation commands listed there before opening the pull request.\n'
}

# Creates an issue assigned to Copilot and records it on the Trello card.
dispatch_to_repo() {
  local repo="$1" card_id="$2" short="$3" name="$4" desc="$5" existing="$6"
  local marker="Copilot issue: $short $repo"
  local legacy_marker="Copilot task: $short $repo" body output url

  if grep -qF "$marker" <<<"$existing" || grep -qF "$legacy_marker" <<<"$existing"; then
    echo "exists: $repo $short"; return 0
  fi

  body=$(build_issue_body "$desc" "$short")

  if ! output=$(printf '%s' "$body" |
    gh issue create --repo "$repo" --title "$name" \
      --body-file - --assignee "@copilot" 2>&1); then
    echo "::warning::failed to create Copilot issue in $repo for $short: $output"
    return 1
  fi

  url=$(grep -oE 'https://github\.com/[^[:space:])]+' <<<"$output" | head -n1 || true)
  if [[ -z "$url" ]]; then
    echo "::warning::issue created in $repo for $short, but gh did not return its URL: $output"
    return 1
  fi
  echo "created Copilot issue: $repo $short $url"

  if ! output=$(gh issue comment "$url" --repo "$repo" --body "/oc fix this" 2>&1); then
    echo "::warning::issue created in $repo for $short, but failed to post OpenCode trigger comment: $output"
  else
    echo "posted OpenCode trigger comment: $repo $short"
  fi

  curl -fsS -X POST "$API/cards/$card_id/attachments" "${AUTH[@]}" \
    --data-urlencode "url=$url" \
    --data-urlencode "name=$marker" >/dev/null
}

process_card() {
  local card="$1" id short name desc repos repo existing

  id=$(jq -r '.id' <<<"$card")
  short=$(jq -r '.shortLink' <<<"$card")
  name=$(jq -r '.name' <<<"$card")
  desc=$(jq -r '.desc // ""' <<<"$card")

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
  repos=$(printf '%s' "$repos" | awk 'NF && !seen[$0]++')

  if [[ -z "$repos" ]]; then
    echo "skip $short: no 'Frontend' or 'Backend' label"; return 0
  fi

  # Existing dispatch markers on this card, read once per card
  existing=$(curl -fsSG "$API/cards/$id/attachments" "${AUTH[@]}" \
    --data-urlencode "fields=name" | jq -r '.[].name')

  while IFS= read -r repo; do
    dispatch_to_repo "$repo" "$id" "$short" "$name" "$desc" "$existing" \
      || echo "::warning::failed to process $repo for card $short"
  done <<<"$repos"
}

# Process each card; one failure shouldn't stop the others
jq -c '.[]' <<<"$cards" | while read -r card; do
  process_card "$card" || echo "::warning::failed to process card: $(jq -r '.shortLink' <<<"$card")"
done