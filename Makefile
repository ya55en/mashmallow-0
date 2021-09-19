#: Makefile for the mashmallow-0 project
#: See https://makefiletutorial.com/


#: Show commands for deleting current branch
del-branch:
	@echo "git checkout main && git branch -d $$(git branch --no-color --show-current)"
	@echo git push origin --delete -d $$(git branch --no-color --show-current)


#: Set environment variables so that this project's mash is active
setenv:
	@MASH_HOME="$$(pwd)/src" ; export MASH_HOME
	@PATH="$$MASH_HOME/bin:$$PATH" ; export PATH
	@echo "MASH_HOME=$$MASH_HOME"
	@echo "which mash: $$(which mash)"


# clean:
# 	rm -f hey one two


.PHONY:  setenv del-branch
