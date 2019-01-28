{user, pkgs, ...}:
{
  environment.systemPackages = [ pkgs.git ];

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
