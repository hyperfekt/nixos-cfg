{ unstable, ... }:
{
  disabledModules = [ "config/pulseaudio.nix" ];
  imports = [ <nixos-unstable/nixos/modules/config/pulseaudio.nix> ];

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = unstable.pulseaudioFull;
    extraModules = [ unstable.pulseaudio-modules-bt ];
  };
  hardware.bluetooth.enable = true;
}
