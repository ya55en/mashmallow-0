# Raw ideas about *mash*

## Ideas about installed mash layout

New ideas needed for separating the recipes repository and the
mash-code code.


## Testing framework

We want to easily invoke test execution from console (via make)
and within the CI environment.

Would be great to be able to make a diff with the previous commit
and execute tests for mash-core only if mash-core files are affected
(including install.sh), tests for particular recipes if those have
been changed, and only for them, and (almost) full tests probably
nightly.


## Ideas about mash cli sub-commands

```
mash repair install pycharm-community

mash self config LOG_LEVEL=DEBUG
mash self config color-scheme=dark-bg

mash self test
mash self repair
mash self fix-links

mash undo fix linux-firmware-i915

mash self puge  # removing EVERYTHING mash
mash self test
mash self reinstall  (or mash self repair)
mash self security-check

mash fix linux-firmware-i915

mash setup python-pip

mash setup python-dev
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


## posix-shell-stdlib:

Path to install on a live system:
- `~/.local/lib/posix-shell/stdlib/`

Any other, non-std libs go to:
- `~/.local/lib/shell/posix-sh/dist-pkg/`

`~/.local/bin/upgrade-sh-stdlib`  POSIX_SH_IMPORT_PATH


### Done (more or less):

## Ideas about mash cli sub-commands

```
mash undo install bitwarden  # DONE
mash self update  # DONE, beta
mash self remove  # DONE, beta (was mash self uninstall)
mash setup dev-essential [1]  # DONE, beta
mash setup python-pipx [2]  # DONE, seems stable
```

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

Apps to provide install recipes for:

- Bitwarden
- VS Code
- PyCharm
- Wire
