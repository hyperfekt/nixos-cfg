{ pkgs, unstable, lib, config, ... }:
{
  options.setupScript = lib.mkOption {
    type = lib.types.lines;
    default = "";
  };

  config.environment.etc."nixos/setup.sh".source = unstable.writers.writeBash "setup-script" config.setupScript;
}
