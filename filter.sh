#!/bin/bash

COMMIT_SHA="${SEMAPHORE_GIT_SHA}"
WHITELIST=("tbogosavljevic")
ARTIFACT_FILE="commit-history.txt"
TRIGGERED_BY="${SEMAPHORE_WORKFLOW_TRIGGERED_BY}"

echo "🚀 Starting rerun check..."
echo "🔀 Current commit SHA: $COMMIT_SHA"
echo "👤 Committer: $TRIGGERED_BY"
echo "✅ Whitelisted users: ${WHITELIST[*]}"
echo "📄 Artifact file: $ARTIFACT_FILE"

echo "📥 Pulling artifact file..."
if ! artifact pull project "$ARTIFACT_FILE"; then
  echo "⚠️ Artifact does not exist. Creating new file: $ARTIFACT_FILE"
  touch "$ARTIFACT_FILE"
else
  echo "📦 Artifact file contents after pull:"
  cat "$ARTIFACT_FILE" || echo "📝 (file empty or unreadable)"
fi

if grep -qx "$COMMIT_SHA" "$ARTIFACT_FILE"; then
  echo "🔎 Commit SHA found in artifact file."
  authorized=false
  for user in "${WHITELIST[@]}"; do
    echo "🔍 Checking if committer '$TRIGGERED_BY' equals whitelist user '$user'"
    if [[ "$TRIGGERED_BY" == "$user" ]]; then
      authorized=true
      echo "🟢 Committer is authorized."
      break
    fi
  done
  if ! $authorized; then
    echo "❌ Unauthorized rerun detected from committer '$TRIGGERED_BY'. Exiting."
    exit 1
  fi
else
  echo "ℹ️ Commit SHA NOT found in artifact file."
fi

if ! grep -qx "$COMMIT_SHA" "$ARTIFACT_FILE"; then
  echo "➕ Appending current commit SHA to artifact file."
  echo "$COMMIT_SHA" >> "$ARTIFACT_FILE"
  echo "📤 Pushing updated artifact file..."
  artifact push project --force "$ARTIFACT_FILE"
else
  echo "✅ Commit SHA already recorded; no update needed."
fi

echo "🎉 Rerun check completed successfully."
