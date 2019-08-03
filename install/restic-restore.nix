{ pkgs ? import <nixpkgs> {} }:
pkgs.restic.overrideAttrs (oldAttrs: {
  src = pkgs.fetchgit {
    url = "https://github.com/ifedorenko/restic";
    rev = "5db73a6c006b58976e648a95fc8c058a78020feb";
    sha256 = "0ygrq8qql0k06hmqsfa6krz43ckh2an90388pxczhwi8fwx5nzxn";
  };
})
