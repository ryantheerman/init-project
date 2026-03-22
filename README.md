## Project Initialization
### Overview
This repo contains an opinionated set of scripts, configuration files, and image recipes for initializing new projects to work on with claude code.<br>I'm too paranoid to give claude access to my actual system, so I've set up an arch VM to house my experiments/work with claude. Call it being extra paranoid, but I also only install and launch claude in containers.<br>The original intent of this architecture was to keep claude two layers away from my host, but containerizing claude has the added benefits of clean dependency isolation per project, a reproducible environment, and less risk of accumulating shared deps/configs on the vm. Nuking a project is a single image delete with no loose ends dangling in the system.

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
The scripts assume you are already in a tmux session named claude-vm.
 - `project`: Initializes a new project. Prompts for a project name, then creates the project directory tree under workshop/projects, copies and modifies base files from init/skel, generates a project-specific ssh key pair, and builds the project container image. Exits with an error if the project already exists. On success, prints a tree of the newly created project.
 - `launch <project name>`: Spins up a project container in a new tmux window on the vm, or switches to the window if the project is already running. Handles container naming, container networking, and bind mounting of common config and project-specific files. The entrypoint starts a container-scoped tmux session and launches claude automatically.
 ~~- `switch`: A convenience wrapper around `launch`, intended to be invoked via the tmux command prompt rather than a shell. Requires a tmux command alias defined in your ~/.tmux.conf. The exact line is in the script's header comments. Once configured, you can type `launch` from the tmux command prompt and be prompted for a project name. `switch` handles the mechanics of running `launch` from within tmux. The actual window management behavior is the same as calling `launch` directly.~~
    - Removed the above mentioned `switch` script. It was needlessly complicated. Instead, I've just set this in my vm ~/.tmux.conf: `set -s command-alias[100] 'launch=command-prompt -p "Project:" "run-shell \"~/workshop/init/scripts/launch %%\""'` This calls the `launch` script directly with no superfluous wrapper.

#### Operational Notes
 - PATH: Add ~/workshop/init/scripts (or wherever you store these scripts) to your PATH. The scripts can be invoked directly from any directory once this is done, but nothing enforces it. You can also call them by full path if you prefer.
 - persistence: Because I don't want to drown in old containers on the limited space of the vm, containers run with --rm, so any state not in a bind-mounted path is lost on container exit. Verify your mount configuration before relying on in-container writes. Make sure claude is also aware of this constraint, either in your global CLAUDE.md or per-workspace.
 - user uid: Dockerfile.base hardcodes the container user `claude` at uid 1000. The launch script uses `--userns=keep-id`, which maps your vm user's uid into the container. If your vm user is not uid 1000, you may hit permission issues on bind-mounted paths. Verify with `id -u` on the vm before building.
 - ssh key scoping: `project` generates a project-specific key pair but does not attach it anywhere. Attach the public key to a single github repository. This is a deliberate security boundary limiting claude's github access to that repo only.
 - authentication: On first launch of a new project container, you'll need to authenticate with anthropic and authorize the claude instance. Because claude.json is bind mounted, auth persists across container restarts. Token refreshes are handled automatically.
 - nested tmux prefix keys: Both the vm and container .tmux.confs bind the prefix key to ctrl+a. With keyd on the host, a ctrl tap sends ctrl+a (while holding ctrl still acts as ctrl). In a nested tmux session, one tap sends the prefix to the outer session, two taps to the inner. Worth setting up... check out keyd.

### Workflow
I connect to claude-vm via a connection script that handles sshing into the vm and attaching to or creating a tmux session. This means I'm always dropped back where I left off, as long as the vm is running.
From there, the typical project lifecycle looks like this:

 1. Run `project` and enter a project name to initialize the project
 2. Run `launch <project name>` to open the project container in a new vm tmux window. The entrypoint will drop you directly into a container-scoped tmux session with claude running. To run multiple projects concurrently, repeat in a new shell or leverage `switch` via the tmux command line
 3. On first launch, authenticate with anthropic and authorize the claude instance, then create a github repo and attach the project-specific public key to it
 4. Enter a planning session with claude. Discuss the objective, define requirements and constraints, agree on a stack, and produce an implementation plan. Instruct claude to persist the relevant portions to memory before exiting
 5. Update the project Dockerfile with the required software and rebuild the image, then relaunch the container
 6. On subsequent launches, prompt claude for the current project state. It will review its memories and analyze the workspace to determine where things stand
 7. Work iteratively. I toggle between planning and implementation modes frequently. Claude tends toward eagerness; planning mode helps pump the brakes
 8. Commit and push periodically by instructing claude directly

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
