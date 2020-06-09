self: super:

/* # Overriding

   `emacsWithPackages` inherits the package set which contains it, so the
   correct way to override the provided package set is to override the
   set which contains `emacsWithPackages`. For example, to override
   `emacsPackagesNg.emacsWithPackages`,
   ```
   let customEmacsPackages =
         emacsPackagesNg.overrideScope' (self: super: {
           # use a custom version of emacs
           emacs = ...;
           # use the unstable MELPA version of magit
           magit = self.melpaPackages.magit;
         });
   in customEmacsPackages.emacsWithPackages (epkgs: [ epkgs.evil epkgs.magit ])
   ```
*/

rec {
  emacsEnv = with super;
    self.myEnvFun {
      name = "emacs";
      buildInputs =
        [ coq_8_9 coqPackages_8_9.ssreflect myEmacs pandoc gdb lldb clang ];
    };

  myPackages = epkgs:
    with epkgs; [
      (self.runCommand "default.el" { } ''
        mkdir -p $out/share/emacs/site-lisp
        cp ${myEmacsConfig} $out/share/emacs/site-lisp/default.el
      '')
      ace-window
      agda2-mode
      async
      auto-complete
      auto-complete-pcmp
      auto-highlight-symbol
      avy
      bind-key
      bnfc
      cargo
      cmake-font-lock
      cmake-mode
      company
      company-ansible
      company-c-headers
      company-cabal
      company-coq
      company-ghc
      company-ghci
      company-go
      company-math
      conda
      cubicaltt
      dash
      dash-functional
      deferred
      delight
      direnv
      docker
      docker-tramp
      dockerfile-mode
      edts
      eglot
      emojify
      epl
      eproject
      erlang
      ess
      eval-in-repl
      evil
      evil-args
      evil-leader
      evil-magit
      evil-nerd-commenter
      exec-path-from-shell
      f
      flycheck
      flycheck-ats2
      flycheck-ghcmod
      flycheck-haskell
      flycheck-plantuml
      # flycheck-purescript
      flycheck-pyflakes
      gh-md
      ghc
      ghci-completion
      ghub
      git-commit
      go-mode
      goto-chg
      grizzl
      haskell-mode
      helm
      helm-ag
      helm-company
      helm-core
      helm-descbinds
      helm-ghc
      helm-git
      helm-git-grep
      helm-idris
      helm-ispell
      #hindent
      ht
      hydra
      idris-mode
      import-popwin
      interaction-log
      intero
      json-mode
      json-reformat
      json-snatcher
      # julia-mode
      let-alist
      log4e
      lsp-haskell
      macrostep
      magit
      magit-popup
      markdown-mode
      math-symbol-lists
      matlab-mode
      nix-buffer
      nix-mode
      nixos-options
      ob-diagrams
      org
      org-ac
      org-babel-eval-in-repl
      ox-pandoc
      ox-reveal
      pandoc-mode
      paredit
      paredit-everywhere
      pkg-info
      plantuml-mode
      popup
      popwin
      projectile
      proof-general
      prop-menu
      psc-ide
      psci
      purescript-mode
      pydoc
      pydoc-info
      pyenv-mode
      pyenv-mode-auto
      projectile
      pythonic
      # realgud
      rust-mode
      s
      seq
      shm
      slime
      smart-tab
      smartparens
      sml-mode
      solarized-theme
      tablist
      undo-tree
      use-package
      w3m
      wgrep
      wgrep-helm
      which-key
      whole-line-or-region
      with-editor
      yasnippet
      yaxception
      znc
    ];

  myEmacs = myEmacsPackages.emacsWithPackages myPackages;

  myEmacsConfig = self.writeText "default.el" ''
    ;;; agda2-mode nix-setup
    (require 'agda2)
      '';

  myEmacsPackages = super.emacsPackagesNg.overrideScope' (eself: esuper: {
    proof-general = let
      texinfo = super.texinfo4;
      texLive = super.texlive.combine {
        inherit (super.texlive) scheme-basic cm-super ec;
      };
    in super.stdenv.mkDerivation rec {
      name = "emacs-proof-general-${version}";
      version = "2020-01-13";

      # This is the main branch
      src = super.fetchFromGitHub {
        owner = "ProofGeneral";
        repo = "PG";
        rev = "ea62543527e6c0fcca8bbb70695e25c2f5d89614";
        sha256 = "0jzyj3a3b9b26b2cksrcby39gj9jg77dzj3d4zzbwf33j1vkvfd2";
      };
            # src = ~/src/proof-general;

      buildInputs = [ eself.emacs ] ++ (with super; [ texinfo perl which ]);

      prePatch =
        '' sed -i "Makefile" \
               -e "s|^\(\(DEST_\)\?PREFIX\)=.*$|\1=$out|g ; \
                   s|/sbin/install-info|install-info|g"
           sed -i '94d' doc/PG-adapting.texi
           sed -i '96d' doc/ProofGeneral.texi
        '';

      meta = {
        description = "Proof General, an Emacs front-end for proof assistants";
        longDescription = ''
          Proof General is a generic front-end for proof assistants (also known as
          interactive theorem provers), based on the customizable text editor Emacs.
        '';
        homepage = http://proofgeneral.inf.ed.ac.uk;
        license = super.lib.licenses.gpl2Plus;
        platforms = super.lib.platforms.unix;
      };
    };

    # https://github.com/NixOS/nixpkgs/issues/57746
    agda2-mode = let Agda = self.haskellPackages.Agda;
    in eself.trivialBuild {
      pname = "agda-mode";
      version = Agda.version;

      phases = [ "buildPhase" "installPhase" ];

      # already byte-compiled by Agda builder
      buildPhase = ''
        agda=`${Agda}/bin/agda-mode locate`
        cp `dirname $agda`/*.el* .
      '';

      meta = {
        description = "Agda2-mode for Emacs extracted from Agda package";
        longDescription = ''
          Wrapper packages that liberates init.el from `agda-mode locate` magic.
          Simply add this to user profile or systemPackages and do `(require 'agda2)` in init.el.
        '';
        homepage = Agda.meta.homepage;
        license = Agda.meta.license;
      };
    };

  });
}
