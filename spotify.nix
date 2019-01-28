{ unstable, ... }:
{
  environment.systemPackages = [ unstable.spotify ];

  # needed for syncing local tracks across the LAN
  networking.firewall.allowedTCPPorts = [ 57621 ];
}
