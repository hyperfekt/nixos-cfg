{user, pkgs, unstable, ...}:
{
  environment.systemPackages = [
    pkgs.git
    pkgs.gitAndTools.transcrypt
  ];

  home-manager.users.${user}.programs.git = {
    enable = true;
    userName = "hyperfekt";
    userEmail = "git@hyperfekt.net";
    extraConfig = {
      credential = {
        helper = "cache --timeout=7200";
      };
    };
  };
}
