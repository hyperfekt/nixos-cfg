{ configuration ? import "${<nixos>}/nixos/lib/from-env.nix" "NIXOS_CONFIG" <nixos-config>
, system ? builtins.currentSystem
}:

let

  pkgs = import <nixos> {};

  patches = (pkgs.lib.evalModules {
    modules = [ configuration ];
    check = false;
  }).config.patches;

  patched-nixpkgs = pkgs.stdenv.mkDerivation {
    name = "nixpkgs-patched";
    src = builtins.storePath <nixos>;
    unpackPhase = ''
      cp -r $src/. .
      chmod -R u=rwX,g=rX,o=rX * # necessary because store hashes include the execute bit
    '';
    patches = [ ./nix-instantiate_find-file_nixpkgs-to-nixos.patch ] ++ patches;
    patchFlags = [ "-p1" "--merge" ];
    dontBuild = true;
    installPhase = ''
      shopt -s dotglob nullglob
      mkdir -p $out
      rm env-vars
      mv * $out
    '';
    fixupPhase = "true";
  };

  eval = import <nixos/nixos/lib/eval-config.nix> {
    inherit system;
    modules = [ configuration ];
    baseModules = import "${patched-nixpkgs}/nixos/modules/module-list.nix";
    specialArgs.modulesPath = "${patched-nixpkgs}/nixos/modules";
  };

  # This is for `nixos-rebuild build-vm'.
  vmConfig = (import ./lib/eval-config.nix {
    inherit system;
    modules = [ configuration ./modules/virtualisation/qemu-vm.nix ];
    baseModules = import "${patched-nixpkgs}/nixos/modules/module-list.nix";
    specialArgs.modulesPath = "${patched-nixpkgs}/nixos/modules";
  }).config;

  # This is for `nixos-rebuild build-vm-with-bootloader'.
  vmWithBootLoaderConfig = (import ./lib/eval-config.nix {
    inherit system;
    modules =
      [ configuration
        ./modules/virtualisation/qemu-vm.nix
        { virtualisation.useBootLoader = true; }
      ];
    baseModules = import "${patched-nixpkgs}/nixos/modules/module-list.nix";
    specialArgs.modulesPath = "${patched-nixpkgs}/nixos/modules";
}).config;

in

{
  inherit (eval) pkgs config options;

  system = eval.config.system.build.toplevel;

  vm = vmConfig.system.build.vm;

  vmWithBootLoader = vmWithBootLoaderConfig.system.build.vm;
}
