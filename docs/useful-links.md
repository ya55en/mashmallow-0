# Useful hints and links

Useful hints and links for the `ma'shmallow-0` project

## Important standards (e.g. POSIX)

- POSIX.2017 (?) aka "The Open Group Base Specifications Issue 7, 2018 edition":
  - https://pubs.opengroup.org/onlinepubs/9699919799/

## dot-desktop-related

- https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-1.5.html

- https://askubuntu.com/questions/367396/what-does-the-startupwmclass-field-of-a-desktop-file-represent

- How to obtain the `StartupWMClass` value(s) for the .desktop file:
  ```
  $ xprop WM_CLASS  # then click on the running app window
  ```


## Makefile guides

- General tutorials:
  - https://makefiletutorial.com/

- Flow control:
  - https://stackoverflow.com/questions/180760

- Makefile examples:
  - https://riptutorial.com/makefile/example/21376

- Sources from sub-directories:
  - https://stackoverflow.com/questions/4036191


## Shell (sh/bash)

### General resources:

- Best known linter: https://github.com/koalaman/shellcheck/
- Good ex. of getopts: https://blog.mafr.de/2007/08/05/cmdline-options-in-shell-scripts/
- Sh/Bash debugging
  - excellent article: https://www.shell-tips.com/bash/debug-script/

### Recipes:

- @konsolebox reply to finding a char in a string: https://stackoverflow.com/questions/18488270
- split by delimiter: https://stackoverflow.com/questions/19930823/sh-split-string-by-delimiter


## git-related

- Deleting branches:
  - https://stackoverflow.com/questions/2003505
  - https://www.freecodecamp.org/news/how-to-delete-a-git-branch-both-locally-and-remotely/
