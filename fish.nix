{user, pkgs, unstable, ...}:
let
  fishWithCompletions = builtins.fetchurl "https://raw.githubusercontent.com/hyperfekt/nixpkgs/fish_generate-completions/nixos/modules/programs/fish.nix";
in
  {
    disabledModules = [ "programs/fish.nix" ];
    imports = [ fishWithCompletions ];
    
    programs.fish = {
      enable = true;
      package = unstable.fish;
    };

    home-manager.users.${user}.programs.fish = {
      enable = true;
      package = unstable.fish;
    };

    users.users.${user}.shell = unstable.fish;
  }
