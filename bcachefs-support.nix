{ pkgs, ...}:
{
  disabledModules = [ "tasks/filesystems/bcachefs.nix" ];
  imports = [ (builtins.fetchurl https://raw.githubusercontent.com/hyperfekt/nixpkgs/4dc2a73c1474cd4dac5ee46808a3cd8ba9f48b8a/nixos/modules/tasks/filesystems/bcachefs.nix) ];

  boot.bcachefs.toolPackage = (pkgs.callPackage (builtins.fetchurl {url = https://raw.githubusercontent.com/hyperfekt/nixpkgs/bcachefs-update/pkgs/tools/filesystems/bcachefs-tools/default.nix; name = "bcachefs-tools-exp";}) {}).overrideAttrs (oldAttrs: {
    name = "${oldAttrs.pname}-${oldAttrs.version}";
  });
  boot.kernelPackages = pkgs.lib.mkForce (pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor (pkgs.callPackage (builtins.fetchurl {url = https://raw.githubusercontent.com/hyperfekt/nixpkgs/bcachefs-update/pkgs/os-specific/linux/kernel/linux-testing-bcachefs.nix; name = "bcachefs-kernel-exp";}) {
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.modinst_arg_list_too_long
    ];
  })));
}
