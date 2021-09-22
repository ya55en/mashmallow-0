# Raw ideas about *mash*

## Ideas about installed mash layout

```
.
└── mash
    ├── bin
    ├── etc
    ├── lib
    │   └── self
    └── recipes
        ├── fix
        ├── install
        └── setup

```

## Ideas about mash cli sub-commands

```
mash undo install bitwarden
mash undo fix i915-firmware

mash self update
mash self test
mash self uninstall
mash self reinstall
mash self security-check

mash fix i915-firmware

mash setup dev-essential [1]
mash setup python-dev
mash setup python-pip
mash setup python-pipx [2]

mash setup golang-dev
mash setup rust-dev
mash setup nim-dev
mash setup shell-dev

```

## Ideas about what to package

- Install Mega Desktop for Linux
  - URL: https://mega.nz/linux/MEGAsync/xUbuntu_20.04/amd64/megasync-xUbuntu_20.04_amd64.deb
_____

- python-4dev:
  - mash install dev-essential
  - python3-venv
  - python3-dev
  - mash install pip-bootstrap (?)
  - mash install pipx-local
- rust-4dev
- golang-4dev

_____
- [1] install dev-essential:
    - build-essential
    - make, cmake
    - git
    - vim (or neo-vim)
    - curl, bzip2, xz-utils
    - screen, (more? strace?)
    - github-cli
    - p_sswdless sudo
    - no-install-recommends + no-install-suggests
    - useful env vars (e.g. `EDITOR`); have `~/.env` point
      to the `~/.bashrc.d/` snippet (or simply have these in `.env`)
      and source them from a `~/.bashrc.d/` snippet)
    - useful aliases (e.g. uname-history):
      `uname-history='echo "$(date) - $(uname -a)" | tee -a  ~/uname_history'`
    - setup dot-files:
      - .gitconfig
      - .env
      - desktop-specific
      - (etc.)

_____
- [2] install python-pipx:
  - create `~/.local/venvs`
  - create pipx venv in `~/.local/venvs`
  - update (pip setuptools wheel) trio
  - install pipx
  - symlink `~/.local/bin/pipx` => `~/.local/venvs/pipx/bin/pipx`
  - create `~/.bashrc.d/32-pipx-setup.sh` with:
    - `PIPX_HOME=$HOME/.local/venvs/pipx`
    - `#eval "$(register-python-argcomplete3 pipx)"  # see if this can work`
_____


### Done (more or less):

- Bitwarden
- VS Code
- PyCharm
- Wire
