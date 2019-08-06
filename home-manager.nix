{ user, pkgs, lib, sources, ... }:
let
  home-manager-source = import (import ./nix/sources.nix).home-manager {};
in
  {
    imports = [ home-manager-source.nixos ];

    environment.systemPackages = [ home-manager-source.home-manager ];

    home-manager.users.${user}.home.packages = lib.mkForce [];
  }
