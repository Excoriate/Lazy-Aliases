#!/usr/bin/env bash

function gh_create_repo() {
  local repo_name
  local repo_desc
  local repo_visibility

  repo_name=$(gum input --placeholder "Enter repository name")
  repo_desc=$(gum input --placeholder "Enter repository description (optional)")
  repo_visibility=$(gum choose "Public" "Private")

  # Using awk to perform lowercase conversion for better compatibility across shells
  repo_visibility=$(echo "$repo_visibility" | awk '{print tolower($0)}')

  local repo_template
  local repo_org
  repo_template=$(gum input --placeholder "Enter repository template (optional)")
  repo_org=$(gum input --placeholder "Enter organization name (optional, leave blank for user)")

  local create_cmd="gh repo create \"$repo_name\" --description \"$repo_desc\" --${repo_visibility}"
  [[ -n "$repo_template" ]] && create_cmd+=" --template \"$repo_template\""
  [[ -n "$repo_org" ]] && create_cmd+=" --org \"$repo_org\""

  # Eval can be a security risk if any input is not controlled. Ensure inputs are validated/sanitized.
  eval "$create_cmd"
  local cmd_status=$?

  if [ $cmd_status -ne 0 ]; then
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "Failed to create repository: $repo_name"
    return
  fi

  local ssh_url
  ssh_url=$(gh repo view "$repo_name" --json sshUrl --jq .sshUrl)

  if [ -z "$ssh_url" ]; then
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "Failed to retrieve repository SSH URL: $repo_name"
  fi

  gum style \
      --foreground 212 --border-foreground 212 --border double \
      --align center --width 50 --margin "1 2" --padding "2 4" \
      "Repository created: $repo_name ($ssh_url)"
}

# alias ghreponnew=gh_create_repo
