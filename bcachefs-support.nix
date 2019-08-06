{ pkgs, unstable, lib, ...}:
{
  disabledModules = [ "tasks/filesystems/zfs.nix" ];

  options.security.pam.services = with lib; mkOption {
    type = types.loaOf (types.submodule {
      config.text = mkDefault (mkAfter "session required pam_keyinit.so force revoke");
    });
  };

  config = {
    nixpkgs.overlays = [ (
      self: super: {
        linux_testing_bcachefs = unstable.linux_testing_bcachefs.override { argsOverride = {
          modDirVersion = "5.1.0";
          version = "5.1.2019.07.23";
          src = pkgs.fetchgit {
            url = "https://evilpiepirate.org/git/bcachefs.git";
            rev = "d541578796b99f78decb7c22e8e173d3192234bf";
            sha256 = "0rvpzhr9b1afzms7yhj3dlv8ahpcv177naivnc1v55nzp4v4mg2z";
          };
        }; };
        bcachefs-tools = unstable.bcachefs-tools.overrideAttrs (oldAttrs: {
          version = "2019-07-13";
          src = pkgs.fetchgit {
            url = "https://evilpiepirate.org/git/bcachefs-tools.git";
            rev = "692eadd6ca9b45f12971126b326b6a89d7117e67";
            sha256 = "0d2kqy5p89qjrk38iqfk9zsh14c2x40d21kic9kcybdhalfq5q31";
          };
        } );
      }
    ) ];

    boot.supportedFilesystems = [ "bcachefs" ];
    boot.kernelPatches = [ {
      name = "bcachefs-acl";
      patch = null;
      extraConfig = ''
        BCACHEFS_POSIX_ACL y
      '';
    } ];
  };
}
