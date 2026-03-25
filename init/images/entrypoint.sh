#!/bin/bash
SESSION="${PROJECT_NAME:-claude}"
#claude update
tmux new-session -s "$SESSION" \; send-keys 'claude' Enter
