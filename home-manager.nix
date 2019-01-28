{user, pkgs, lib, ... }:
let
  home-manager-source = (import <nixos/nixpkgs> {}).fetchFromGitHub {
    owner = "rycee";
    repo = "home-manager";
    rev = "9f013a8fb8690d218a4dbefa891faf09c2260a8c";
    sha256 = "10ncbri6l5a173vzi4fdgdg466dk59xmf28kfwxlfjwrndl4f2y0";
  };

  home-manager = pkgs.home-manager.overrideAttrs (oldAttrs: {
    version = "2019-01-28";
    src = home-manager-source;
  });
in
  {
    imports = [ "${home-manager-source}/nixos" ];

    environment.systemPackages = [ home-manager ];

    home-manager.users.${user}.home.packages = lib.mkForce [];
  }
