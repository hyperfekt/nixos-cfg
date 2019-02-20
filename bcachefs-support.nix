{ pkgs, unstable, ...}:
let
  fetchimport = args: ((import <nixos/nixpkgs> {config={};}).fetchurl args).outPath;
  kernel = unstable.linux_testing_bcachefs.override { argsOverride = {
    version = "4.20.2019.02.20";
    modDirVersion = "4.20.0";
    src = pkgs.fetchgit {
      url = "https://evilpiepirate.org/git/bcachefs.git";
      rev = "ea43593a9d07594e8a14eb44f9373c238a981612";
      sha256 = "0jiwb7wxhx6hnlv15rj4hcljrr44cddm5hb8sf4bfhln70zw5apf";
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
    boot.kernelPatches = [ {
      name = "bcachefs-acl";
      patch = null;
      extraConfig = ''
        BCACHEFS_POSIX_ACL y
      '';
    } ];
  }
