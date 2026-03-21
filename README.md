## Project Initialization
### Overview
This repo contains an opinionated set of scripts, configurations files, and image recipes for initializing new projects to work on with claude code.<br>I'm too paranoid to give claude access to my actual system, so i've set up an arch VM to house my experiments/work with claude. Call it being extra paranoid, but I also only install and launch claude in containers.<br>The original intent of this architecture was to erect 2 walls of isolation between claude and my host machine, but containerizing claude has the added benefit of allowing me to wipe out an entire claude project with no loose ends left hanging in the system.

### Structure
```
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
└── init
    ├── images
    │   ├── Dockerfile.base
    │   ├── Dockerfile.java-base
    │   ├── Dockerfile.project
    │   ├── Dockerfile.python-base
    │   └── entrypoint.sh
    ├── scripts
    │   ├── launch
    │   ├── project
    │   └── switch
    └── skel
        ├── claude.json
        ├── ports
        ├── ssh-config
        └── .zsh_history
```
**common/config** contains configuration files that are bind mounted read only to any given project container.
<br>**init/scripts** contains the scripts for creating and launching/switching to projects
<br>**init/skel** contains some files either empty or with default contents that are used when initializing a new project.
<br>**init/images** contains Dockerfiles used to build container images.
 - Dockerfile.base installs a minimal arch install with some necessary tools, adds a user 'claude', sets up a .ssh dir under /home/claude in the container, installs claude code, sets a PATH, copies the entrypoint script into the container and makes it executable, sets the workdir, and establishes the entrypoint. The entry point simply spins up a tmux session when the container named after the project and launches Claude.
 - Dockerfile.project is copied when initializing a new project. It is basically a blank slate build on the Dockerfile.base. For each project, necessary software is added as needed and the image is rebuilt.
 - The other Dockerfiles are simple templates for java and python projects. I may remove these eventually.

### How it Works
 - Running `project` will prompt the user for a project name. If the name entered exists, the script exits with a message stating the project already exists.<br>Otherwise, the project directory tree is created, necessary base files are copied and modified from the /workshop/init/skel directory, a project specific ssh key pair is created, a project container image is created by using 


### Tools
