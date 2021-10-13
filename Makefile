#: Main Makefile for the mashmallow-0 project.
#: See https://makefiletutorial.com/


PROJECT_NAME := mashmallow-0
VENV_DIR := .venv

# current build version
# _version_ := $(shell git tag | tail -1)
_version_ := $(shell ./scripts/dump-version.sh)

# current branch
branch := $(shell git branch --no-color --show-current)

# Anything in src/ matters for re-creating the dist tarball (but install.sh)
EXCLUDED := install.sh
SOURCES := $(shell find ./src/ -name "*" -a ! -name $(EXCLUDED))
DISTFILE := ./dist/mash-v$(_version_).tgz


$(DISTFILE):  $(SOURCES)
	@echo "_version_=[$(_version_)]"
	@[ -n "$(_version_)" ] || { echo 'FATAL: version _version_ NOT found in git _version_ log'; exit 11; }
	@echo $(_version_) > ./src/etc/version
	@[ -d ./dist/ ] || mkdir -p ./dist
	@rm -f $(DISTFILE)
	@tar czvf $(DISTFILE) -C src --exclude=$(EXCLUDED) .
	@echo "Created $(DISTFILE)."

dist:  $(DISTFILE)


show-sources:
	@echo "SOURCES=$(SOURCES)"


#: Set environment variables so that this project's mash is active.
#: (Do "eval `make setenv`" to get these variables take effect.)
setenv:
	@./scripts/4make/setenv.sh


#: Clean up generated artifacts.
clean-dist:
	rm -rf ./dist; mkdir ./dist/


#: Clean docker builds. TODO: remove if not needed.
# clean-docker-builds:
# 	cd ./docker/focal-debootstrap; $(MAKE) clean-docker-build


#: Clean chroot-setup created tarballs.
clean-tarballs:
	@cd ./chroot-setup/; $(MAKE) clean-tarballs


#: Clean all non-source.
clean-all:  clean-dist clean-tarballs


#: Release this commit after versioning
show-release:
	@git log -n1 | ./scripts/4make/show-release.py


#: Show commands for deleting current branch.
show-del-branch:
	@echo '# current branch: $(branch)'
	@if [ "x$(branch)" = xmain ]; then \
	   echo '  ** You are on "main"!? - No deletion! ;)' \
	;else \
	    echo "\$$ git checkout main" && \
	    echo "\$$ git branch -d $(branch)" && \
	    echo "\$$ git push origin --delete $(branch)" && \
	    echo "\$$ # Don't forget 'git fetch --all --prune'!" \
	;fi


#: Create empty python venv.
create-venv:
	@if [ -x "$(VENV_DIR)/bin/python3" ]; then \
		echo "Virtualenv $(VENV_DIR) already exists" \
	;else \
		echo "Creating virtualenv $(VENV_DIR)..." ; \
		/usr/bin/env python3 -m venv "$(VENV_DIR)" --prompt "$(PROJECT_NAME)-here" && \
		"$(VENV_DIR)/bin/python3" -m pip install -U pip setuptools wheel >> /dev/null && \
		echo "Done." \
	;fi


#: Remove python venv.
del-venv:
	@if [ -x "$(VENV_DIR)/bin/python3" ]; then \
		rm -r "$(VENV_DIR)" ; \
		echo "Virtualenv $(VENV_DIR) removed" \
	;else \
		echo "Virtualenv $(VENV_DIR) does NOT exist" \
	;fi


# PIP_REQUIREMENTS := tests/shell_testbed/requirements.txt

# #: Install python venv dependencies.
# deps:
# 	@"$(VENV_DIR)/bin/python3" -m pip install -r "$(PIP_REQUIREMENTS)"


test-%:
	@$(MAKE) test-$* -C chroot-setup


.PHONY:  setenv clean-dist clean-tarballs clean-all
.PHONY:  dist show-release show-del-branch
.PHONY:  create-venv del-venv

# No python tools yet, sleeping ;)
# .PHONY:  deps
