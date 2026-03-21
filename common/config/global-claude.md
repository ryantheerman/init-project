# Environment

- Running in an Arch Linux container on an Arch Linux virtual machine
- No superuser privileges; cannot install software

# Persistence

The following locations are bind-mounted from the host and persist across container rebuilds:
- `/workspace` — primary project working directory
- `/home/claude/.ssh` - project specific ssh keys and config
- `/home/claude/.claude` — Claude config directory
- `/home/claude/.claude/CLAUDE.md` — this global config file
- `/home/claude/claude.json`
- `/home/claude/.zsh_history`
- Various other config files under `/home/claude` are also bind-mounted but should not be written to — they are shared across projects and concurrent writes risk data loss

Everything else in the container (outside of the above) is ephemeral and will not survive a rebuild.

# Global CLAUDE.md

- The global CLAUDE.md at `/home/claude/.claude/CLAUDE.md` is not writable by Claude

# Package Management

- Non-OS package managers (e.g. pip, npm, cargo) may be used to install dependencies as needed
- Always install to user-level directories, never root-level (no sudo)
- Follow best practices per ecosystem (e.g. use virtual environments for Python, `--user` flags where appropriate, etc.)
- Prefer project-local installs (e.g. inside `/workspace`) over user-global installs where possible, so dependencies stay with the project and installs survive container restarts

# General Principles

- Before taking any action that is hard to reverse or has broad impact (initializing a git repo, restructuring directories, modifying shared config, etc.), ask the user first
- When in doubt, ask rather than assume

# Communication and Collaboration

- User is a software developer — technical depth and precision are expected and appreciated
- Be direct and critical. Do not soften feedback or sugarcoat problems in the code
- Correctness and quality come first. If something is wrong or could be better, say so plainly
- Do not be unnecessarily harsh, but do not hedge criticism to protect feelings — honest feedback is more valuable
- The goal is to produce good code and help the user improve; uncorrected mistakes serve neither

# Version Control

- Git is used for version control across projects
- New projects will not have a git repo initialized by default — do not create one without asking first
- SSH is configured at `/home/claude/.ssh`. each key is scoped to a single container for use with just one project.
- Any repo the user grants access to will have the corresponding public key set as a deployment key

# Project Setup

- Each project runs in its own container built on a common base image (Arch Linux base, zsh, tmux, vim, fzf, openssh, git, etc.)
- On top of the base, each projects starts as a blank slate with just a claude user created. The project /workspace dir will be empty at first. We will collaborate on selecting the software needed for the project and the user will add it to the image and rebuild.
- The language/stack in use will vary per project — do not assume a default
