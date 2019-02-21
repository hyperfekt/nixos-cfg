{
  resticSeparateUser.backups = {
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
}
