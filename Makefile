#: Makefile for the mashmallow-0 project
#: See https://makefiletutorial.com/


PROJECT_NAME := mashmallow-0
VENV_DIR := .venv

# latest git tag
tag := $(shell git tag | tail -1)

# current branch
branch := $(shell git branch --no-color --show-current)

# Anything in src/ matters for re-creating the dist tarball (but install.sh)
EXCLUDED := install.sh
SOURCES := $(shell find ./src/ -name "*.*" -a ! -name $(EXCLUDED))


#: Set environment variables so that this project's mash is active
setenv:
	@./scripts/4make/setenv.sh


dist:  $(SOURCES)
	@rm -f ./dist/mash-$(tag).tgz
	@[ -d ./dist/mash-$(tag).tgz ] || mkdir -p ./dist
	@[ -f ./dist/mash-$(tag).tgz ] || \
		tar czvf ./dist/mash-$(tag).tgz -C src --exclude=$(EXCLUDED) .


#: Clean up generated artifacts
clean-dist:
	rm -rf ./dist


#: Release this commit after versioning
show-release:
	@git log -n1 | ./scripts/4make/show-release.py


#: Show commands for deleting current branch
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


#: Create empty python venv
create-venv:
	@if [ -x "$(VENV_DIR)/bin/python3" ]; then \
		echo "Virtualenv $(VENV_DIR) already exists" \
	;else \
		echo "Creating virtualenv $(VENV_DIR)..." ; \
		/usr/bin/env python3 -m venv "$(VENV_DIR)" --prompt "$(PROJECT_NAME)-here" && \
		"$(VENV_DIR)/bin/python3" -m pip install -U pip setuptools wheel >> /dev/null && \
		echo "Done." \
	;fi


#: Remove python venv
del-venv:
	@if [ -x "$(VENV_DIR)/bin/python3" ]; then \
		rm -r "$(VENV_DIR)" ; \
		echo "Virtualenv $(VENV_DIR) removed" \
	;else \
		echo "Virtualenv $(VENV_DIR) does NOT exist" \
	;fi


PIP_REQUIREMENTS := tests/shell_testbed/requirements.txt

#: Add python venv dependencies
deps:
	@"$(VENV_DIR)/bin/python3" -m pip install -r "$(PIP_REQUIREMENTS)"


.PHONY:  setenv clean-dist show-release show-del-branch
.PHONY:  create-venv del-venv deps
