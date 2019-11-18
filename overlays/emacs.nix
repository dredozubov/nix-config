self: super:

/*

# Overriding

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
  emacsEnv = with super; self.myEnvFun {
    name = "emacs";
    buildInputs = [
      coq_8_9
      coqPackages_8_9.ssreflect
      super.emacsPackages.proofgeneral_HEAD
      myAgda
      myEmacs
      pandoc
      gdb
      lldb
      clang
    ];
  };

  myPackages = epkgs: with epkgs; [
    (self.runCommand "default.el" {} ''
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
    company-lsp
    company-lua
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
    hindent
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
    lsp-mode
    lsp-ui
    lua-mode
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
;;; enable proof general
(when (not (require 'proof-site
    (replace-regexp-in-string
      "/bin$"
      "/share/emacs/site-lisp/ProofGeneral/generic/proof-site"
      (cl-some
        (lambda (s) (when (cl-search "ProofGeneral" s) s))
        (split-string (getenv "PATH") ":")))))
  (message "`ProofGeneral` not found on PATH"))
;;; agda2-mode nix-setup
(require 'agda2)
  '';

  myAgda = self.haskell.packages.ghc844.Agda;

  myEmacsPackages = super.emacsPackagesNg.overrideScope' (eself: esuper: {

    # https://github.com/NixOS/nixpkgs/issues/57746
    agda2-mode =
      let Agda = myAgda; in
      eself.trivialBuild {
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

    # https://github.com/NixOS/nixpkgs/issues/57747
    w3m = super.stdenv.lib.overrideDerivation esuper.w3m (attrs: rec {
      name = "emacs-w3m-${version}";
      version = "20190227.2349";
      src = self.fetchFromGitHub {
        owner = "emacs-w3m";
        repo = "emacs-w3m";
        rev = "58d7f72e039529833e97b69d8ca2827a2fc69a97";
        sha256 = "0dn145ha63sbpz8zxbcf3rfcdmdn3ifik1gspb8pdvsnq8vb55mw";
        # date = 2019-02-27T23:49:44+09:00;
      };
    });
  });
}
