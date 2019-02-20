{ pkgs, lib, ... }:
with lib;
let
  backups = {
    normal = {
      paths = [
        "/home"
        "/cfg"
      ];
      timerConfig.OnCalendar = "*:0/5";
      repository = "s3:https://s3.eu-central-1.wasabisys.com/hyperfekt-personal-backup";
      passwordFile = "/cfg/secrets/restic-normal-backup.pass";
      s3CredentialsFile = "/cfg/secrets/wasabi-bismuth-restic.env";
    };
  };
  backupsWithUser = mapAttrs (n: v: v // {user = "restic-${n}"; }) backups;
in
{
  environment.systemPackages = [ pkgs.restic ];

  services.restic.backups = backupsWithUser;

  users.users = mapAttrs' (n: v: nameValuePair v.user { isSystemUser = true; }) backupsWithUser;

  setupScript = concatStringsSep "\n" (
    flatten (
      mapAttrsToList (n: v:
        map (path: ''
          ${pkgs.acl.bin}/bin/setfacl -Rm d:u:${v.user}:r,u:${v.user}:r ${path}
        '') v.paths
      ) backupsWithUser
    )
  );
}
