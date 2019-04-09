{
  allowUnfree = true;

  packageOverrides = pkgs: with pkgs; {

    dsss17 = pkgs.callPackage ~/workspace/dsss17-nix {};

  };

}
