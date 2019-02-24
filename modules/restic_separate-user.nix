{ pkgs, lib, config, options, ... }:
with lib;
let
  dot = f: g: x: f (g x);
  compose = foldr dot id;
  excludeFiles = mapAttrs (n: v: pkgs.writeText "restic-${n}_exclude-file" v.exclude) renamedBackups;
  withUser = n: v: { user = "restic-${n}"; };
  cacheDir = n: "/var/tmp/restic-${n}";
  withExclude = n: v: { extraBackupArgs = v.extraBackupArgs ++ [ "--exclude-file ${excludeFiles.${n}}" ]; };
  withCache = n: v: { extraBackupArgs = v.extraBackupArgs ++ [ "--cache-dir ${cacheDir n}" ]; };
  extendAttrs = f: mapAttrs (n: v: v // (f n v));
  renamedBackups = mapAttrs' (n: v: nameValuePair "generated-${n}" v) config.resticSeparateUser.backups;
  augmentedBackups = compose (map extendAttrs [ withUser withCache withExclude ]) renamedBackups;
in
{
  options.resticSeparateUser.backups = mkOption {
    description = ''
      Periodic backups to create with Restic employing autogenerated users.
    '';
    type = with types; attrsOf
      (submodule ({name, ...}:
        recursiveUpdate
        (mapAttrs (n: v:
          if n == "options" then
            filterAttrs (n: v: n != "user") v
          else
            v
        ) ((head options.services.restic.backups.type.getSubModules).submodule { name = name; }))
        {
          options.exclude = mkOption {
            type = lines;
            default = "";
            description = ''
              Glob patterns of files to exclude from the backup.
            '';
            example = ''
              .cache
              baloo/index*
            '';
          };
        }
        ));
    default = options.services.restic.backups.default;
    example = options.services.restic.backups.example;
  };

  config = {
    services.restic.backups = mapAttrs (n: v: filterAttrs (n: v: n != "exclude") v) augmentedBackups;

    environment.systemPackages = [ pkgs.restic ];

    # create users
    users.users = mapAttrs' (n: v: nameValuePair v.user { isSystemUser = true; }) augmentedBackups;

    # create and set permissions for cache directory
    system.activationScripts = mapAttrs' (n: v: nameValuePair
      "restic-backups-${n}-cachedir"
      {
        text = ''
          ${pkgs.coreutils}/bin/mkdir -pm 0700 ${cacheDir n}
          ${pkgs.coreutils}/bin/chown ${v.user} ${cacheDir n}
          ${pkgs.acl.bin}/bin/setfacl -k ${cacheDir n}
        '';
        deps = [];
      }) augmentedBackups;

    # add permissions for paths
    # necessary to do as prestart because a default set with X would make newly created files executable
    # and because some applications change the ACL mask upon saving
    systemd.services =
      let
        setfacl = "${pkgs.acl.bin}/bin/setfacl --mask";
        fd = "${pkgs.fd}/bin/fd --hidden --no-ignore";
        parallel = "${pkgs.parallel}/bin/parallel --pipe";
        # make sure to run before any other setfacl calls as they are destructive
        giveAccess = entity: target: ''
          current=${target}
          ${setfacl} -m ${entity}:rX "$current"
          while current="$(${pkgs.coreutils}/bin/dirname "$current")"; do
            ${setfacl} -m ${entity}:X "$current"
            if [ "$current" = "/" ]; then
              break
            fi
          done
        '';
        removeAccess = entity: target: ''
          current=${target}
          ${setfacl} -x ${entity} "$current"
          while current="$(${pkgs.coreutils}/bin/dirname "$current")"; do
            ${setfacl} -x ${entity} "$current"
            if [ "$current" = "/" ]; then
              break
            fi
          done
        '';
        wrapCheckError = command: ''
          set +e
          stderr=$(${command})
          status=$?
          set -e
          [[ $status -eq 0 ]] && exit 0 || [[ -z $stderr ]] && exit 0 || ${pkgs.coreutils}/bin/tee >&2 <<< "$stderr" && exit $status
        '';
      in
        mapAttrs' (n: v:
          let
            listFiles = "export PARALLEL_SHELL=${pkgs.bash}/bin/bash; ${fd} --ignore-file ${excludeFiles.${n}} . ${concatStringsSep " " v.paths}";
          in
            nameValuePair "restic-backups-${n}" {
              # deprecated in 19.09, see nixos/nixpkgs#53852
              serviceConfig.PermissionsStartOnly = true;
              preStart = ''
                ${giveAccess "u:${v.user}" v.passwordFile}
                ${optionalString (!(isNull v.s3CredentialsFile)) ''
                  ${giveAccess "u:${v.user}" v.s3CredentialsFile}
                ''}
                ${concatStringsSep "\n" (map (giveAccess "u:${v.user}") v.paths)}
                ${wrapCheckError ''${listFiles} | ${parallel} ${setfacl} -m u:${v.user}:rX - 2>&1 | ${pkgs.gnugrep}/bin/grep -vE "setfacl: .*: (No such file or directory|Read-only file system)"''}
              '';
              postStart = ''
                ${removeAccess "u:${v.user}" v.passwordFile}
                ${optionalString (!(isNull v.s3CredentialsFile)) ''
                  ${removeAccess "u:${v.user}" v.s3CredentialsFile}
                ''}
                ${concatStringsSep "\n" (map (removeAccess "u:${v.user}") v.paths)}
                ${wrapCheckError ''${listFiles} | ${parallel} ${setfacl} -x u:${v.user} - 2>&1 | ${pkgs.gnugrep}/bin/grep -v "setfacl: .*: No such file or directory"''}
              '';
              } ) augmentedBackups;
    };
}
