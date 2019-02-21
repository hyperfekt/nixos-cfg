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

  system.activationScripts.backupFilePermissions = {
    text =
      let
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
        concatStringsSep "\n" (
          flatten (
            mapAttrsToList (n: v: [ ''
                # remove all permissions for this user
                ${setfacl} -x d:u:${v.user},u:${v.user} /*
                '' ] ++ [
                (makeAccessible "u:${v.user}" v.passwordFile) ''
                ${setfacl} --mask -m u:${v.user}:r ${v.passwordFile}
                '' ] ++ optional (!(isNull v.s3CredentialsFile)) [
                  (makeAccessible "u:${v.user}" v.s3CredentialsFile) ''
                  ${setfacl} --mask -m u:${v.user}:r ${v.s3CredentialsFile}
                '' ] ++
              (map (path: ''
                # TODO: for some reason some files end up with execute bit???
                ${setfacl} --mask -Rm d:u:${v.user}:rX,u:${v.user}:rX ${path}
              '') v.paths)
            ) backupsWithUser
          )
        );
    deps = [];
  };
}
