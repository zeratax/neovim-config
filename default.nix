{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "my-nvim-config";
  version = "1.0.0";

  src = builtins.path {
    path = ./.;
    name = "nvim-config";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out
    cp -r ${src}/* $out
  '';

  meta = with pkgs.lib; {
    description = "my neovim config";
    homepage = "https://github.com/zeratax/neovim-config";
    license = licenses.mit;
  };
}
