{user, pkgs, ...}:
{
  fonts.fonts = [
    pkgs.ubuntu_font_family
  ];

  home-manager.users.${user}.programs.vscode.userSettings = {
    "editor.fontFamily" = "Ubuntu Mono";
    "editor.fontSize" = 15;
  };
}
