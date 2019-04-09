self: super: {

nix-scripts = with self; stdenv.mkDerivation {
  name = "nix-scripts";

  src = ../bin;

  buildInputs = [ emacsEnv ];

  installPhase = ''
    mkdir -p $out/bin
    echo `find . -maxdepth 1 \( -type f -o -type l \) -executable`
    find . -maxdepth 1 \( -type f -o -type l \) -executable \
        -exec cp -pL {} $out/bin \;
  '';

  meta = with stdenv.lib; {
    description = "Various convenience scripts";
    homepage = https://github.com/dredozubov;
    license = licenses.mit;
    maintainers = with maintainers; [  ];
    platforms = platforms.darwin;
  };
};

}
