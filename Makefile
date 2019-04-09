ENVS    = emacsEnv
MAX_AGE = 14d

all: link env

link:
	cp config.nix ~/.config/nixpkgs/
	mkdir -p ~/.config/nixpkgs/overlays/
	cp overlays/*.nix ~/.config/nixpkgs/overlays/

env: link
	for i in $(ENVS); do			\
	    echo Updating $$i;			\
	    nix-env -f '<nixpkgs>' -u --leq	\
	        -Q -k -A pkgs.$$i ;	\
	done
	@echo "Nix generation: $$(nix-env --list-generations | tail -1)"

gc:
	nix-collect-garbage --delete-older-than $(MAX_AGE)
