{ pkgs, ... }:
{
  hardware.opengl.driSupport32Bit = true;
  environment.systemPackages = [ pkgs.steam ];
}
