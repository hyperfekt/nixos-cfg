{ pkgs, unstable, ... }:
{
  environment.systemPackages = [ pkgs.spotify ];

  # needed for syncing local tracks across the LAN
  networking.firewall.allowedTCPPorts = [ 57621 ];
}
