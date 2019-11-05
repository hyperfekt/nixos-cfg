{ pkgs, unstable, ... }:
{
  hardware.opengl.driSupport32Bit = true;
  environment.systemPackages = [ unstable.steam ];
}
