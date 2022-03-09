# mashmallow-0

**ma'shmallow** at phase zero.

_WARNING:_
This is pre-alpha, super-early phase of development. Do NOT use on a
production machine!


## What is it?

_ma'shmallow_ is envisioned as a universal tool for storing and managing
recipes for POSIX-compliant systems.

### The need

Imagine often repeated tasks you do when installing a new OS, or
a fix that you need for, say, missing linux firmware. You usually
do that by hand or using a quick script you draft on-the-go. However,
some time later you need to do the same fix on a different machine and
you just remeber you have done that but don't know where. So you do it
by hand again.

### The helper

Meet ma'shmallow, known as `mash` ;)

```bash
$ mash fix linux-firmare-i915  # apply a fix for that missing firmware issue
$ mash install shell-dev  # install common tools for developing w/ unix shell
$ mash install golang-dev  # install common tools for developing w/ go
$ mash configure personal gnome-terminal  # set up your terminal the way you want it
```
All done, you just sit and watch or take a up of coffee ;)


## Installation

_ma'shmallow_ is still in exeprimental phase - do NOT install on your production machine! Use a virtual machine, a container or a chroot environment at this phase.

Install the latest stable `mash` with:

```bash
curl -sL https://github.com/ya55en/mashmallow-0/raw/main/src/install.sh | sh
```

After the installation close and reopen all your terminals.

## Quck smoke test

To check if mash is operable, do:

```bash
$ mash setup hello
```

## Development

Clone this repository (and a submodule for test environments) with:

```bash
$ git clone --recurse-submodules https://ya55en@github.com/ya55en/mashmallow-0.git
```

or

```bash
$ git clone --recurse-submodules git@github.com:ya55en/mashmallow-0.git
```

To get your repository code to take effect when you run mash, do:

```bash
$ eval `make setenv`
```

Check that you get the right mash executable:

```bash
$ which mash
/home/{USER}/{Project}/mashmallow-0/src/bin/mash
```

## TODO and Known issues

Huh... plenty of tickets to resolve! ;) The project is in its infancy.


## License

MIT
