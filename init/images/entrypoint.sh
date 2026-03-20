#!/bin/bash
SESSION="${PROJECT_NAME:-claude}"
tmux new-session -s "$SESSION" \; send-keys 'claude' Enter
