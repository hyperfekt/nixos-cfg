# credits to Till Höppner for telling me how to do this

{ lib, options, config, ... }:
with lib;
{
  options = {
    patches = mkOption {
      type = with types; listOf (either path package);
      default = [];
      description = "patch files to apply to the nixpkgs tree";
    };

    nixpkgs-alt = mkOption {
      type = types.attrs;
      default = {};
      description = "same format as options.nixpkgs";
    };
  };

  config = {
    nixpkgs = config.nixpkgs-alt;

    nix.nixPath = [ "nixpkgs=${toString ../patched}" ];
  };
}
