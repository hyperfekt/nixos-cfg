{ pkgs, ...}:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5 = {
    enable = true;
    enableQt4Support = false;
  };

  # see nixos/nixpkgs#20776
  system.userActivationScripts.updateStartMenu = {
    text = ''
      ${pkgs.libsForQt5.kservice}/bin/kbuildsycoca5
    '';
    deps = [];
  };
}
