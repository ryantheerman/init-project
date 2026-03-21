## Project Initialization
### Overview
This repo contains an opinionated set of scripts, configurations files, and image recipes for initializing new projects to work on with claude code.
I'm too paranoid to give claude access to my actual system, so i've set up an arch VM to house my experiments/work with claude.
Call it being extra paranoid, but I also only install and launch claude in containers. The original intent of this architecture was to erect 2 walls of isolation between claude and my host machine, but containerizing claude has the added benefit of allowing me to wipe out an entire claude project with no loose ends left hanging in the system.

### Structure
workshop
├── common
│   └── config
│       ├── .bc
│       ├── global-claude.md
│       ├── .tmux.conf
│       ├── .vimrc
│       ├── .zsh_aliases
│       ├── .zshenv
│       ├── .zsh_functions
│       └── .zshrc
├── .gitignore
├── init
│   ├── images
│   │   ├── Dockerfile.base
│   │   ├── Dockerfile.java-base
│   │   ├── Dockerfile.project
│   │   ├── Dockerfile.python-base
│   │   └── entrypoint.sh
│   ├── scripts
│   │   ├── launch
│   │   ├── project
│   │   └── switch
│   └── skel
│       ├── claude.json
│       ├── ports
│       ├── ssh-config
│       └── .zsh_history



### Tools
