#!/usr/bin/env zsh

TARGET_APPS=("Ghostty" "Safari" "Ollama" "Hammerspoon" "Docker" "Slack" "Code")

# Set window title, hide cursor & clear screen ONCE at start
printf "\033]0;📊 App Resource Monitor\007\033[?25l\033[2J"
trap 'printf "\033[?25h\n"; exit 0' INT TERM HUP EXIT

while true; do
    PS_OUTPUT=$(ps -eo %cpu,rss,comm)
    TIME_STR=$(date +'%H:%M:%S')
    
    BUFFER="\033[H"
    BUFFER+="$(printf "\033[1;36m📊 APP RESOURCES\033[0m \033[90m(%s)\033[0m\033[K" "$TIME_STR")"$'\n'
    BUFFER+="$(printf "\033[90m------------------------------------\033[0m\033[K")"$'\n'
    BUFFER+="$(printf "\033[1;37m%-12s %6s  %9s  %4s\033[0m\033[K" "APPLICATION" "CPU" "RAM" "PROC")"$'\n'
    BUFFER+="$(printf "\033[90m------------------------------------\033[0m\033[K")"$'\n'
    
    for APP in "${TARGET_APPS[@]}"; do
        MATCHES=$(echo "$PS_OUTPUT" | grep -i "$APP")
        if [[ -n "$MATCHES" ]]; then
            CPU_SUM=$(echo "$MATCHES" | awk '{sum+=$1} END {printf "%.1f", sum}')
            MEM_KB=$(echo "$MATCHES" | awk '{sum+=$2} END {print sum}')
            COUNT=$(echo "$MATCHES" | wc -l | tr -d ' ')
            
            if [[ $MEM_KB -gt 1048576 ]]; then
                MEM_STR=$(awk -v kb="$MEM_KB" 'BEGIN {printf "%.2f GB", kb/1048576}')
            else
                MEM_STR=$(awk -v kb="$MEM_KB" 'BEGIN {printf "%.1f MB", kb/1024}')
            fi
            
            CPU_STR="${CPU_SUM}%"
            BUFFER+="$(printf "%-12s %6s  %9s  %4d\033[K" "$APP" "$CPU_STR" "$MEM_STR" "$COUNT")"$'\n'
        else
            BUFFER+="$(printf "%-12s %6s  %9s  %4s\033[K" "$APP" "0.0%" "offline" "-")"$'\n'
        fi
    done
    BUFFER+="$(printf "\033[90m------------------------------------\033[0m\033[K")"$'\n'
    
    print -n "$BUFFER"
    sleep 1
done
