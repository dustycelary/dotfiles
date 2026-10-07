#!/bin/bash
# List floating windows in a picker; choosing one focuses it.
# Runnable from AeroSpace, Alfred, Keyboard Maestro or a terminal.
export PATH="/opt/homebrew/bin:$PATH"

list=$(aerospace list-windows --all \
    --format '%{window-id}|%{workspace}|%{app-name}|%{window-title}|%{window-layout}' |
    awk -F'|' '$5 == "floating" { printf "%s  [%s] %s — %s\n", $1, $2, $3, $4 }')

if [[ -z "$list" ]]; then
    osascript -e 'display notification "No floating windows" with title "AeroSpace"'
    exit 0
fi

choice=$(osascript - "$list" <<'EOF'
on run argv
    set items_ to paragraphs of (item 1 of argv)
    tell application "System Events"
        activate
        set picked to choose from list items_ with title "AeroSpace" with prompt "Floating windows:" OK button name "Focus"
    end tell
    if picked is false then return ""
    return item 1 of picked
end run
EOF
)

[[ -n "$choice" ]] && aerospace focus --window-id "${choice%% *}"
