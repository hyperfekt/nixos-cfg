{user, ...}:
{
  nixpkgs-alt.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  home-manager.users.${user}.xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';
}
