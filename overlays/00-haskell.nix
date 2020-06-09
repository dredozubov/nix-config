self: super:

{
  haskell = super.haskell // {
    # applies overrides for all haskell.package versions
    packageOverrides = hself: hsuper: {
      Diff = super.haskell.lib.dontCheck hsuper.Diff;
    };
  };
}
