{
  allowUnfree = true;

  packageOverrides = pkgs: with pkgs; {

    emacsEnv = myEnvFun {
      name = "emacs";
      buildInputs = [
        coq_8_9
        coqPackages_8_9.ssreflect
        myEmacs
      ];
    };

    dsss17 = pkgs.callPackage ~/workspace/dsss17-nix {};

  };

}
