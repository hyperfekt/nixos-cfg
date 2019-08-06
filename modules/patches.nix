# credits to Till Höppner for telling me how to do this

{ lib, options, ... }:
with lib;
{
  options.patches = mkOption {
    type = with types; listOf (either path package);
    default = [];
    description = "patch files to apply to the nixpkgs tree";
  };

  config.nix.nixPath = [ "nixpkgs=${toString ../patched}" ];
}
