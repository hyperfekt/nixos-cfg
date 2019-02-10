{ pkgs, unstable, ...}:
let
  fetchimport = args: ((import <nixos/nixpkgs> {config={};}).fetchurl args).outPath;
  kernel = unstable.linux_testing_bcachefs.override { argsOverride = {
    version = "4.20.2019.02.09";
    modDirVersion = "4.20.0";
    src = pkgs.fetchgit {
      url = "https://evilpiepirate.org/git/bcachefs.git";
      rev = "09a546543006b60d44c4c51e7b40cd3ec7837a5e";
      sha256 = "0p187vp9df0nnhawql0f2bj2sdim0f2b424106d41yxc8ayhz0d9";
    };
  }; };
  kernelPackages = pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor kernel);
  tools = unstable.bcachefs-tools.overrideAttrs (oldAttrs: rec {
    name = "${oldAttrs.pname}-${version}";
    src = pkgs.fetchgit {
      url = "https://evilpiepirate.org/git/bcachefs-tools.git";
      rev = "17c5215c1c542dd7b6b4f891a0da16d8c98e0591";
      sha256 = "1zm2lnvijfmz483m2nhxz1rhk7ghgh0c450nyiwi6wa7lc1y3339";
    };
    version = "2019-02-09";
  });
in
  {
    disabledModules = [
      "tasks/filesystems/bcachefs.nix"
    ];
    imports = [
      (fetchimport {
        url = https://raw.githubusercontent.com/hyperfekt/nixpkgs/bcachefs-packageoptions/nixos/modules/tasks/filesystems/bcachefs.nix;
        sha256 = "0p6kkh99282s90xjc4zir08ngvmf1lyzv841cqmisqsfryxqjli5";
      })
    ];

    boot.bcachefs.toolPackage = tools;
    boot.kernelPackages = pkgs.lib.mkForce kernelPackages;
    boot.zfs.enableUnstable = true;
    boot.supportedFilesystems = [ "bcachefs" ];
  }
