## Project Initialization
### Overview
This repo contains an opinionated set of scripts, configuration files, and image recipes for initializing new projects to work on with claude code.<br>I'm too paranoid to give claude access to my actual system, so i've set up an arch VM to house my experiments/work with claude. Call it being extra paranoid, but I also only install and launch claude in containers.<br>The original intent of this architecture was to keep claude two layers away from my host, but containerizing claude has the added benefits of clean dependency isolation per project, a reproducible and fully declarable environment, and no risk of quietly accumulating state on the vm. nuking a project is a single image delete with no loose ends dangling in the system.

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
 - Dockerfile.base installs a minimal arch install with some necessary tools, adds a user 'claude', sets up a .ssh dir under /home/claude in the container, installs claude code, sets a PATH, copies the entrypoint script into the container and makes it executable, sets the workdir, and establishes the entrypoint. The entry point simply spins up a tmux session named after the project and launches Claude when the container starts.
 - Dockerfile.project is copied when initializing a new project. It is basically a blank slate built on the Dockerfile.base. For each project, necessary software is added as needed and the image is rebuilt.
 - The other Dockerfiles are simple templates for java and python projects. I may remove these eventually.

### How it Works
#### Scripts
the scripts assume you are already in a tmux session named claude-vm
 - `project`: initializes a new project. prompts for a project name, then creates the project directory tree under workshop/projects, copies and modifies base files from init/skel, generates a project-specific ssh key pair, and builds the project container image. exits with an error if the project already exists. on success, prints a tree of the newly created project.
 - `launch <project name>`: spins up a project container in a new tmux window on the vm, or switches to the window if the project is already running. handles container naming, container networking, and bind mounting of common config and project-specific files. the entrypoint starts a container-scoped tmux session and launches claude automatically.
 - `switch`: a convenience wrapper around `launch`, intended to be invoked via the tmux command prompt rather than a shell. requires a tmux command alias defined in your ~/.tmux.conf. the exact line is in the script's header comments. once configured, you can type launch from the tmux command prompt and be prompted for a project name. `switch` handles the mechanics of running `launch` from within tmux; the actual window management behavior is the same as calling `launch` directly.

#### Operational Notes
 - PATH: add ~/workshop/init/scripts (or wherever you store these scripts) to your PATH. the scripts can be invoked directly from any directory once this is done, but nothing enforces it. you can also call them by full path if you prefer.
 - persistence: because i don't want to drown in old containers on the limited space of the vm, containers run with --rm, so any state not in a bind-mounted path is lost on container exit. verify your mount configuration before relying on in-container writes. make sure claude is also aware of this constraint, either in your global CLAUDE.md or per-workspace.
 - user uid: Dockerfile.base hardcodes the container user `claude` at uid 1000. the launch script uses `--userns=keep-id`, which maps your vm user's uid into the container. if your vm user is not uid 1000, you may hit permission issues on bind-mounted paths. verify with `id -u` on the vm before building.
 - ssh key scoping: project generates a project-specific key pair but does not attach it anywhere. attach the public key to a single github repository. this is a deliberate security boundary limiting claude's github access to that repo only.
 - authentication: on first launch of a new project container, you'll need to authenticate with anthropic and authorize the claude instance. because claude.json is bind mounted, auth persists across container restarts. token refreshes are handled automatically.
 - nested tmux prefix keys: both the vm and container .tmux.confs bind the prefix to ctrl+a. with keyd on the host, a ctrl tap sends ctrl+a while holding ctrl still acts as ctrl. in a nested tmux session, one tap sends the prefix to the outer session, two taps to the inner. worth setting up... check out keyd.

### Workflow
I connect to claude-vm via a connection script that handles sshing into the vm and attaching to or creating a tmux session. This means I'm always dropped back where I left off, as long as the vm is running.
From there, the typical project lifecycle looks like this:

 1. run `project` and enter a project name to initialize the project
 2. run `launch <project name>` to open the project container in a new vm tmux window. the entrypoint will drop you directly into a container-scoped tmux session with claude running. to run multiple projects concurrently, repeat in a new shell or leverage `switch` via the tmux command line
 3. on first launch, authenticate with anthropic and authorize the claude instance, then create a github repo and attach the project-specific public key to it
 4. enter a planning session with claude — discuss the objective, define requirements and constraints, agree on a stack, and produce an implementation plan. instruct claude to persist the relevant portions to memory before exiting
 5. update the project dockerfile with the required software and rebuild the image, then relaunch the container
 6. on subsequent launches, prompt claude for the current project state. it will review its memories and analyze the workspace to determine where things stand
 7. work iteratively — I toggle between planning and implementation modes. claude tends toward eagerness; planning mode helps pump the brakes
 8. commit and push periodically by instructing claude directly

**common/config/global-claude.md** is bind mounted to each container's /home/claude/.claude/ dir and picked up automatically by every claude instance. It describes the environment and sets behavioral preferences that apply across all projects.

### Tools
I've installed a handful of tools on the vm. The following are those required for use with the scripts in this repo:
  - openssh
  - podman
  - slirp4netns
  - tmux
  - tree

### Screenshots
<img width="1920" height="1200" alt="screenshot from 2026-03-20 23-01-30" src="https://github.com/user-attachments/assets/e6444095-100a-4ab5-9c73-f5d7f697d26b" />
