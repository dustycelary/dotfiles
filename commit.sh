#!/usr/bin/env bash
# Stage and commit all changes in this repo, with a commit message written
# by `claude -p` from the actual diff (falls back to a manual prompt if
# claude isn't available or returns nothing). Never pushes.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ -z "$(git status --porcelain)" ]]; then
	echo "Nothing to commit."
	exit 0
fi

# Bail out if anything that looks like a secret is about to be staged, so it
# doesn't get swept in by `git add -A` without a second look.
secret_pattern='(^|/)(\.env(\..*)?|.*\.pem|.*\.p12|id_(rsa|ed25519|ecdsa)|.*_rsa|credentials\.json|.*\.key)$'
suspicious=()
while IFS= read -r path; do
	[[ -n "$path" ]] && suspicious+=("$path")
done < <(git status --porcelain | awk '{print $2}' | grep -E -i "$secret_pattern" || true)
if [[ ${#suspicious[@]} -gt 0 ]]; then
	echo "These changed paths look like they might contain secrets:"
	printf '  %s\n' "${suspicious[@]}"
	read -r -p "Stage and commit them anyway? [y/N] " reply
	if [[ ! "$reply" =~ ^[Yy]$ ]]; then
		echo "Aborted. Nothing staged."
		exit 1
	fi
fi

git add -A

diff_for_message="$(git diff --cached)"

commit_msg=""
if command -v claude >/dev/null 2>&1; then
	prompt='Write a git commit message for this diff, matching the style of
this repo'"'"'s history: short, lowercase, imperative, no trailing period.
Use an "area: summary" first line when the change is scoped to one area
(e.g. "nvim: ...", "tmux: ...", "lsp: ..."), otherwise just a summary line.
Add a blank line and a few terse bullet points below the summary only if
the diff spans multiple unrelated changes worth calling out separately.
Output ONLY the commit message text, no code fences, no commentary.'

	commit_msg="$(printf '%s' "$diff_for_message" | claude -p "$prompt" 2>/dev/null || true)"
	# strip stray code fences in case the model wraps its output anyway
	commit_msg="$(printf '%s' "$commit_msg" | sed -e '/^```/d')"
fi

if [[ -z "$commit_msg" ]]; then
	echo "Could not generate a commit message automatically."
	read -r -p "Commit message: " commit_msg
	if [[ -z "$commit_msg" ]]; then
		echo "Aborted. Changes are staged but not committed."
		exit 1
	fi
fi

echo "----------------------------------------"
echo "$commit_msg"
echo "----------------------------------------"

git commit -m "$commit_msg"
echo "Committed. Run 'git push' when ready."
