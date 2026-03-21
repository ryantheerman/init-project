## Project Initialization
### Overview
This repo contains an opinionated set of scripts, configurations files, and image recipes for initializing new projects to work on with claude code.<br>I'm too paranoid to give claude access to my actual system, so i've set up an arch VM to house my experiments/work with claude. Call it being extra paranoid, but I also only install and launch claude in containers.<br>The original intent of this architecture was to erect 2 walls of separation between claude and my host machine, but containerizing claude has the added benefit of allowing me to wipe out an entire claude project with no loose ends left hanging in the system.

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
 - Run `project` to initialize a new project. When prompted, enter a name for the project. If the project already exists, the script exits with a message stating such. Otherwise
   - the project directory tree is created under **workshop/projects** (excluded from version control in this repo via .gitignore)
   - necessary base files are copied and modified from the /workshop/init/skel directory to the correct locations in the project tree
   - a project specific ssh key pair is created. this will be scoped to a single repo for claude to read from and write to. i don't want claude accessing my entire github (coughwhataboutcopilotcough)
   - the project container image is created by using by building the base and project specific Dockerfiles
   - and finally a success message is echoed, followed by a tree of the newly created project
 - Run `launch <project name>` to spin up an existing project or, if the project is already running, switch to it.
   - sets up some vars
   - initializes port flags for the container run command (used to ensure the container network is accessible outside the container via the vm's localhost, or via the vm's ip from the outer host)
   - checks if the project is already running in another tmux window on the vm and switches to it if so
   - else creates a new tmux window on the vm and runs the project image, handling network setup, container naming, and bind mounting of the common config files and project specific dirs/files to the appropriate mount points in the container
   - this allows for common configuration across containers, as well as persistence of necessary project specific configurations and state between container restarts
   - the `podman run` command uses the `--rm` flag, so the image is cleaned up once the container is killed. The vm has limited space, and I don't want to drown in old images.
   - when the container starts up, the entrypoint.sh will handle spinning up a container scoped tmux session (configured to be visually distinct from the vm tmux session) and launching claude. if this is the first time the container has been started, the user will need to authenticate with anthropic and authorize the claude instance. because the claude.json is bind mounted, auth is persistent. refreshes are handled automically, so you should only need to authenticate once.
     - (a note on tmux prefix keys... in both the vm and container .tmux.confs i bind my prefix key to ctrl+a. I'm running keyd on the host, and have a ctrl tap mapped to send ctrl+a (while holding ctrl still acts as ctrl). this means that in a nested tmux session, I can tap ctrl once to send the prefix key to the outer session and tap ctrl twice to send the prefix key to the inner session. do yourself a favor and check out keyd.)
 - `switch` is intended to be run via the tmux command line. I got tired of opening a new pane or window in the outer tmux session to launch another project, so together with a command alias in the vm .tmux.conf (not version controlled here, but specified in the switch script), you can trigger the tmux command line, type `launch <project name>` and the command alias will handle calling the launch script with the project name input

### Workflow
I connect to claude-vm using a connection script that handles sshing into vms/remote machines and either launching or switching to an existing tmux session on those machines. This automates my not losing my place when losing connection with remotes, so long as the remote remains powered on.
<br>That script will drop me back where I was last time I connected to the session, or if starting fresh, will drop me at a prompt in window 1.
<br>If I need to set up a new project, I run `project` and input a project name.
<br>I use `launch <project name>` to open the new or existing project container in a new window in the vm tmux session.
<br>If I want multiple projects up at the same time, I'll either leverage my switch script via my tmux command alias, or just open a new shell and launch the desired project.
<br>When the project container starts in the new window, I'm dropped into a container scoped tmux session with claude launched.
<br>If this is a fresh project, I authenticate with Anthropic and authorize claude in the container. I create a new github repo and attach the project specific public key to it. Then in the container I enter a plannig session with claude to discuss the project objective, define requirements and constraints, and set up an implementation plan for accomplishing the goals we set. We'll discuss the best stack for the project. I tell Claude to persist the relevant portions of our discussion and the implementation plan to memory before exiting, updating the project Dockerfile with the required software, and rebuilding the image. Then I launch back into the project container.
<br>Typically I'll prompt claude to give me the current state of the project. It will review its stored memories and analyze the /workspace dir to determine where in the implementation we are. I toggle between multiple modes quite a bit. Claude has a tendency to be very eager to just get started. Planning mode helps to pump the brakes.
<br>As we work and test, I'll occasionally instruct claude to commit the changes and push to the remote.
<br>**common/config/global-claude.md** on the vm is bind mounted to each container's /home/claude/.claude/ dir. This file is picked up by default by each container's claude instance (or multiple instances, when it comes to that). It describes the environment and some preferences for its behavior.

### Tools
I've installed a handful of tools on the vm. The following are those required for use with the scripts in this repo:
  - openssh
  - podman
  - slirp4netns
  - tmux
  - tree
