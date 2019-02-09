{ pkgs, ...}:
{
  disabledModules = [ "tasks/filesystems/bcachefs.nix" ];
  imports = [ (((import <nixos/nixpkgs> {config={};}).fetchurl { url = 
https://raw.githubusercontent.com/hyperfekt/nixpkgs/4dc2a73c1474cd4dac5ee46808a3cd8ba9f48b8a/nixos/modules/tasks/filesystems/bcachefs.nix; 
sha256 = "0l5rap6kl5nmkfjpnkk906qrnp2w7z6gdv46yz8frydgyilsxbpw"; }).outPath) ];

  boot.bcachefs.toolPackage = (pkgs.callPackage (pkgs.fetchurl {url = 
https://raw.githubusercontent.com/hyperfekt/nixpkgs/bcachefs-update/pkgs/tools/filesystems/bcachefs-tools/default.nix; 
name = "bcachefs-tools-exp"; sha256 = "0kp2pdcy9x14nig4jq0gpagq9gwi8wli2x7rffr27v3864g8sj2v"; }) 
{}).overrideAttrs (oldAttrs: {
    name = "${oldAttrs.pname}-${oldAttrs.version}";
  });
  boot.kernelPackages = pkgs.lib.mkForce (pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor (pkgs.callPackage 
(pkgs.fetchurl {url = 
https://raw.githubusercontent.com/hyperfekt/nixpkgs/bcachefs-update/pkgs/os-specific/linux/kernel/linux-testing-bcachefs.nix; 
name = "bcachefs-kernel-exp"; sha256 = "000rqy6nvs8f0j0nim7y3ikv3bpz3hv593b23cp83b7w6wb8f1xb"; }) {
    kernelPatches = [
      pkgs.kernelPatches.bridge_stp_helper
      pkgs.kernelPatches.modinst_arg_list_too_long
    ];
  })));
}
