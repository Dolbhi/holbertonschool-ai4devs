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

# Builds the prompt sent to Copilot. Kept in one place so it's easy to tune.
build_prompt() {
  local name="$1" desc="$2" short="$3"
  printf 'Task: %s\n\n' "$name"
  printf 'Description:\n%s\n\n' "${desc:-No description provided.}"
  printf 'Trello card: https://trello.com/c/%s\n\n' "$short"
  printf 'Follow the conventions in AGENTS.md at the repository root. '
  printf 'Run the validation commands listed there before opening the pull request.\n'
}

# Posts the task to Copilot for a single repo and records it on the card.
dispatch_to_repo() {
  local repo="$1" card_id="$2" short="$3" name="$4" desc="$5" existing="$6"
  local marker="Copilot task: $short $repo" prompt output url base_args=()

  if grep -qF "$marker" <<<"$existing"; then
    echo "exists: $repo $short"; return 0
  fi

  prompt=$(build_prompt "$name" "$desc" "$short")
  if [[ -n "${BASE_BRANCH:-}" ]]; then
    base_args=(--base "$BASE_BRANCH")
  fi

  if ! output=$(gh agent-task create "$prompt" --repo "$repo" "${base_args[@]}" 2>&1); then
    echo "::warning::failed to dispatch $repo $short: $output"
    return 1
  fi
  echo "dispatched: $repo $short"

  # Link to the PR if the CLI printed one, otherwise to the repo's PR list.
  url=$(grep -oE 'https://github\.com/[^[:space:])]+' <<<"$output" | head -n1 || true)
  url=${url:-"https://github.com/$repo/pulls"}

  # Attach only on dispatch so scheduled runs don't dispatch the same card twice
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
  repos=$(printf '%s' "$repos" | sed '/^$/d')

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