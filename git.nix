{user, pkgs, unstable, lib, config, ...}:
with lib;
{
  options.git.excludes = mkOption {
    type = types.listOf types.string;
    default = [];
  };

  config = {
    environment.systemPackages = with pkgs; [
      git
      gitAndTools.hub
      unstable.gitAndTools.transcrypt
    ];

    home-manager.users.${user}.programs.git = {
      enable = true;
      userName = "hyperfekt";
      userEmail = "git@hyperfekt.net";
      extraConfig = {
        credential = {
          helper = "cache --timeout=7200";
        };
        core = {
          excludesfile = "${pkgs.writeText "git-global.ignore" (concatStringsSep "\n" config.git.excludes)}";
        };
      };
    };
  };
}
