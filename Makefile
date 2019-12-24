ENVS    = emacsEnv
MAX_AGE = 14d
NIXPATH = ${NIX_PATH}

PWD := $(shell pwd)

all: link env bin

link:
	ln -sfn `pwd`/config.nix ~/.config/nixpkgs/config.nix
	ln -sfn `pwd`/overlays ~/.config/nixpkgs/overlays
	ln -sfn `pwd`/bin ~/.config/nixpkgs/bin

env: link
	@echo $(NIX_PATH)
	export NIX_PATH=$(NIX_PATH)
	for i in $(ENVS); do			\
	    echo Updating $$i;			\
	    nix-env -f '<nixpkgs>' -i	\
	        -Q -k -A pkgs.$$i ;	\
	done
	@echo "Nix generation: $$(nix-env --list-generations | tail -1)"

gc:
	nix-collect-garbage --delete-older-than $(MAX_AGE)

# https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

zshrc:
	echo "export NIXPATH=nixpkgs=$(PWD)/nixpkgs" >> ~/.zshrc
