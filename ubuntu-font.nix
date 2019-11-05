{user, pkgs, ...}:
{
  fonts.fonts = [
    pkgs.ubuntu_font_family
  ];

  home-manager.users.${user}.programs = {
    vscode.userSettings = {
      "editor.fontFamily" = "Ubuntu Mono";
      "editor.fontSize" = 15;
    };
    alacritty.settings = {
      font = {
        normal.family = "Ubuntu Mono";
      };
      size = "13.0";
    };
  };
}
