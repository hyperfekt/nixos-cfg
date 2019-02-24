{user, pkgs, unstable, ...}:
{
  environment.systemPackages = with pkgs; [
    git
    gitAndTools.hub
    (pkgs.callPackage (/home/adrian/code/nixpkgs-transcrypt/pkgs/applications/version-management/git-and-tools/transcrypt/default.nix) {})
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
