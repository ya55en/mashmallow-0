# mashmallow-0

!maSHmallow! at phase zero. Ma(r)SHmallow is envisioned to be a tool
for executing SHell recipes on POSIX systems.

## Installation

Install mash v0.0.1 with:

```bash
$ curl -sL https://github.com/ya55en/mashmallow-0/raw/main/src/install.sh | sh
```

After the installation close and reopen all your terminals.

## Smoke test

To check if mash is operable, do:

```bash
$ mash setup hello
```

## Development

To get your repository code to take effect when you run mash, do:

```bash
$ eval `make setenv`
```

Check that you get the right mash executable:

```bash
$ which mash
/home/{USER}/{Project}/mashmallow-0/src/bin/mash
```
