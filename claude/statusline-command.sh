#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
# Get context window size and calculate used tokens from percentage
context_limit=$(echo "$input" | jq -r '.context_window.context_window_size')
# Calculate used tokens from percentage (matches /context display)
total_used=$(awk "BEGIN {printf \"%.0f\", $used_pct * $context_limit / 100}")

# Get project name (basename of cwd)
project=$(basename "$cwd")

# Check if in git repo and get branch
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null || echo "")
  if [ -n "$branch" ]; then
    git_info=" on $branch"
  else
    git_info=""
  fi
else
  git_info=""
fi

# Round to nearest integer for progress bar
used_int=$(printf "%.0f" "$used_pct")

# Determine color based on usage percentage using floating point comparison
# 0-16%: light blue, 17-33%: green, 34-50%: yellow, 51-66%: orange, 67-100%: red
if awk "BEGIN {exit !($used_pct <= 16)}"; then
  color="\033[38;5;75m"  # light blue
elif awk "BEGIN {exit !($used_pct <= 33)}"; then
  color="\033[32m"  # green
elif awk "BEGIN {exit !($used_pct <= 50)}"; then
  color="\033[33m"  # yellow
elif awk "BEGIN {exit !($used_pct <= 66)}"; then
  color="\033[38;5;214m"  # orange
else
  color="\033[31m"  # red
fi
reset="\033[0m"

# Progress bar width (20 chars)
bar_width=20
filled=$((used_int * bar_width / 100))
empty=$((bar_width - filled))

# Build progress bar with color
bar="["
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done
bar+="]"

# Color codes for sections
cyan="\033[36m"
magenta="\033[35m"
blue="\033[34m"

# Format total_used in k (e.g., "23k")
if [ "$total_used" -ge 1000 ]; then
  used_display="$((total_used / 1000))k"
else
  used_display="$total_used"
fi

# Format context_limit in k (e.g., "200k")
if [ "$context_limit" -ge 1000 ]; then
  limit_display="$((context_limit / 1000))k"
else
  limit_display="$context_limit"
fi

# Format: model | [progress] used% | 23k/200k tokens | project on branch
# Each section gets a different color
printf "\033[36m%s\033[0m | %b%s %.1f%%\033[0m | \033[35m%s/%s tokens\033[0m | \033[34m%s%s\033[0m" \
  "$model" \
  "$color" "$bar" "$used_pct" \
  "$used_display" "$limit_display" \
  "$project" "$git_info"
