{
  disabledModules = [ "config/zram.nix" ];
  imports = [ <nixos-unstable/nixos/modules/config/zram.nix> ];

  zramSwap = {
    enable = true;
    algorithm = "lz4";
  };
}
