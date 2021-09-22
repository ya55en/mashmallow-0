#: Makefile for the mashmallow-0 project
#: See https://makefiletutorial.com/

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


.PHONY:  setenv clean-dist show-release show-del-branch
