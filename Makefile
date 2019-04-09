ENVS    = emacsEnv
MAX_AGE = 14d

all: link env

link:
	ln -sfn `pwd`/config.nix ~/.config/nixpkgs/config.nix
	ln -sfn `pwd`/overlays ~/.config/nixpkgs/overlays
	ln -sfn `pwd`/bin ~/.config/nixpkgs/bin

env: link
	for i in $(ENVS); do			\
	    echo Updating $$i;			\
	    nix-env -f '<nixpkgs>' -u --leq	\
	        -Q -k -A pkgs.$$i ;	\
	done
	@echo "Nix generation: $$(nix-env --list-generations | tail -1)"

gc:
	nix-collect-garbage --delete-older-than $(MAX_AGE)
