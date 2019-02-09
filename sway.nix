{ pkgs, unstable, ... }:
{
  imports = [ <nixos-unstable/nixos/modules/programs/sway-beta.nix> ];

  programs.sway-beta = {
    package = unstable.sway-beta;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
    extraPackages = [ pkgs.qt5.qtwayland ];
  };
}
