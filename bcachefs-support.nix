
{ pkgs, unstable, ...}:
let
  fetchimport = args: ((import <nixos/nixpkgs> {config={};}).fetchurl args).outPath;
  kernel = unstable.linux_testing_bcachefs.override { argsOverride = {
    version = "4.20.2019.02.08";
    modDirVersion = "4.20.0";
    src = pkgs.fetchgit {
      url = "https://evilpiepirate.org/git/bcachefs.git";
      rev = "474af5d4235d194d7299b68d2ebdd8fbbe291ed1";
      sha256 = "1fkd03p21had22894pgccin4zx8vqlf623na6zdfirpy9ln6al6s";
    };
  }; };
  kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor kernel);
  tools = unstable.bcachefs-tools.overrideAttrs (oldAttrs: {
    name = "${oldAttrs.pname}-${oldAttrs.version}";
  });
in
  {
    disabledModules = [
      "tasks/filesystems/bcachefs.nix"
    ];
    imports = [
      (fetchimport {
        url = https://raw.githubusercontent.com/hyperfekt/nixpkgs/4dc2a73c1474cd4dac5ee46808a3cd8ba9f48b8a/nixos/modules/tasks/filesystems/bcachefs.nix;
        sha256 = "0l5rap6kl5nmkfjpnkk906qrnp2w7z6gdv46yz8frydgyilsxbpw";
      })
    ];

    boot.bcachefs.toolPackage = tools;
    boot.kernelPackages = pkgs.lib.mkForce kernelPackages;
    boot.zfs.enableUnstable = true;
    boot.supportedFilesystems = [ "bcachefs" ];
  }
