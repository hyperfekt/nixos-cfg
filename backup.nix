{ pkgs, lib, user, ... }:
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
      # the default home (where restic locates the cache directory) for system users is /var/empty
      extraBackupArgs = [ "--cache-dir /home/${user}/.cache/restic" ];
    };
  };
  backupsWithUser = mapAttrs (n: v: v // {user = "restic-${n}"; }) backups;
in
{
  environment.systemPackages = [ pkgs.restic ];

  services.restic.backups = backupsWithUser;

  users.users = mapAttrs' (n: v: nameValuePair v.user { isSystemUser = true; }) backupsWithUser;

  # necessary to do as prestart because a default set with X would make newly created files executable
  # and because some applications change the ACL mask upon saving
  systemd.services =
    let
      # using '!' for elevated privileges
      setfacl = "${pkgs.acl.bin}/bin/setfacl";
      # make sure to run before any other setfacl calls as they are destructive
      makeAccessible = entity: target: ''
        current=${target}
        while current="$(dirname "$current")"; do
          ${setfacl} --mask -m ${entity}:x "$current" || break
          if [ "$current" = "/" ]; then
            break
          fi
        done
      '';
    in
      mapAttrs' (n: v:
        nameValuePair "restic-backups-${n}" {
          # deprecated in 19.09, see nixos/nixpkgs#53852
          serviceConfig.PermissionsStartOnly = true;
          preStart =
            concatStringsSep "\n" (
              flatten ( [
                (makeAccessible "u:${v.user}" v.passwordFile) ''
                ${setfacl} --mask -m u:${v.user}:r ${v.passwordFile}
                '' ] ++ optional (!(isNull v.s3CredentialsFile)) [
                  (makeAccessible "u:${v.user}" v.s3CredentialsFile) ''
                  ${setfacl} --mask -m u:${v.user}:r ${v.s3CredentialsFile}
                '' ] ++ [ ''
                  ${setfacl} --mask -Rm u:${v.user}:rX ${concatStringsSep " " v.paths}
                '' ]
              )
            );
          postStop = ''
            ${setfacl} --mask -Rx u:${v.user} /
          '';
          } ) backupsWithUser;
}
