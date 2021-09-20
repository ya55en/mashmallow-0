#: Makefile for the mashmallow-0 project
#: See https://makefiletutorial.com/


#: Set environment variables so that this project's mash is active
setenv:
	@MASH_HOME="$$(pwd)/src" ; export MASH_HOME
	@PATH="$$MASH_HOME/bin:$$PATH" ; export PATH
	@echo "MASH_HOME=$$MASH_HOME"
	@echo "which mash: $$(which mash)"


#: Show commands for deleting current branch
del-branch:
	@echo "git checkout main && git branch -d $$(git branch --no-color --show-current)"
	@echo git push origin --delete -d $$(git branch --no-color --show-current)


#: Release this commit after versioning
release:
	@mkdir -p ./dist
	@tar czvf ./dist/mash-$$(git tag | tail -1).tgz -C src --exclude=install.sh .
	@# @gh release create "$(git tag | tail -1)" --notes "Unofficial release (still)" ./dist/mash-$$(git tag | tail -1).tgz


#: Clean up generated artifacts
clean:
	rm -rf ./dist


.PHONY:  setenv del-branch release clean
