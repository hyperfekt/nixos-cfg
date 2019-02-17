{ user, pkgs, unstable, ... }:
let
  nixpkgs-mozilla = (import <nixos/nixpkgs> {}).fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    # 2019-01-28
    rev = "da76271a3c3d4f14359c9258f31d014b29f413a2";
    sha256 = "11qi27n43g1xl844p2yfxfygdjij2zifbqwa6yxkzy2sff2npsbf";
  };

  rust-mozilla = import "${nixpkgs-mozilla}/rust-overlay.nix";
  rust-src-mozilla = import "${nixpkgs-mozilla}/rust-src-overlay.nix";
in
{
  nixpkgs.overlays = [ rust-mozilla rust-src-mozilla ];

  environment.systemPackages = [
    pkgs.latest.rustChannels.nightly.rust
    pkgs.lldb
    unstable.carnix
  ];

  home-manager.users.${user}.programs.vscode.userSettings."rust-client.disableRustup" = true;
}
