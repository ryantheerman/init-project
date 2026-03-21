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
The scripts assume you are already in a tmux session named claude-vm, and that ~/workshop/init/scripts is on your PATH.
 - Run `project` to initialize a new project. If the name entered exists, the script exits with a message stating the project already exists. Otherwise
   - the project directory tree is created
   - necessary base files are copied and modified from the /workshop/init/skel directory to the correct locations in the project tree
   - a project specific ssh key pair is created
   - the project container image is created by using by building the base and project specific Dockerfiles
   - and finally a success message is echoed, followed by a tree of the newly created project
 - Run `launch <project name>` to spin up an existing project or, if the project is already running, switch to it.
   - sets up some vars
   - initializes port flags for the container run command (used to ensure the container network is accessible outside the container via the vm's localhost, or via the vm's ip from the outer host)
   - checks if the project is already running in another tmux window on the vm and switches to it if so
   - else creates a new tmux window on the vm and runs the project image, handling network setup, container naming, and bind mounting of the common config files and project specific dirs/files to the appropriate mount points in the container
   - this allows for common configuration across containers, as well as persistence of necessary project specific configurations and state between container restarts
   - the `podman run` command uses the `--rm` flag, so the image is cleaned up once it's killed. The vm has limited space, and I don't want to drown in old images.
   - when the container starts up, the entrypoint.sh will handle spinning up a container scoped tmux session (configured to be visually distinct from the vm tmux session) and launching claude. if this is the first time the container has been started, the user will need to authenticate with anthropic and authorize the claude instance. because the claude.json is bind mounted, auth is persistent. refreshes are handled automically, so you should only need to authenticate once.
 - `switch` is intended to be run via the tmux command line. I got tired of opening a new pane or window in the outer tmux session to launch another project, so together with a command alias in the vm .tmux.conf (not version controlled here, but specified in the switch script), you can trigger the tmux command line, type `launch <project name>` and the command alias will handle calling the launch script with the project name input


### Tools
