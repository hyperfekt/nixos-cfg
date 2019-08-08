{ user, pkgs, unstable, ... }:
let
  nixpkgs-mozilla = (import (import ./nix/sources.nix).nixpkgs {}).fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    # 2019-01-28
    rev = "da76271a3c3d4f14359c9258f31d014b29f413a2";
    sha256 = "11qi27n43g1xl844p2yfxfygdjij2zifbqwa6yxkzy2sff2npsbf";
  };

  rust-mozilla = import "${nixpkgs-mozilla}/rust-overlay.nix";
  rust-src-mozilla = import "${nixpkgs-mozilla}/rust-src-overlay.nix";

  rust = pkgs.latest.rustChannels.nightly.rust;
  #rust = (pkgs.rustChannelOf { date = "2019-03-13"; channel = "nightly"; }).rust;
in
{
  nixpkgs.overlays = [ rust-mozilla rust-src-mozilla ];

  environment.systemPackages = [
    rust
    unstable.carnix
    ( unstable.rr.overrideAttrs (oldAttrs: rec {
      version = "2019-08-03";
      pname = "rr";
      name = "${pname}-${version}";
      src = pkgs.fetchFromGitHub {
        owner = "mozilla";
        repo = "rr";
        rev = "37dfe3320d4dbb0a93810f9178d5fb838e726217";
        sha256 = "14ynvkrjm70f5jyd993cry1gy0kp7igwaik73m51zb6q79bp1lgr";
      };
      buildInputs = with unstable; [ python3Packages.python python3Packages.pexpect ] ++ oldAttrs.buildInputs;
    } ) )
  ];

  home-manager.users.${user}.programs.vscode.userSettings = {
    "rust-client.disableRustup" = true;
    "lldb.adapterType" = "native";
  };
}
