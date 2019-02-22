{pkgs, user, ...}:
{
  resticSeparateUser.backups = {
    normal = {
      paths = [
        "/home"
        "/cfg"
      ];
      extraBackupArgs = [ "--exclude-file ${pkgs.writeText "restic-normal-excludes" ''
        */baloo/index*
        */.cache
      ''}" ];
      timerConfig.OnCalendar = "*:0/5";
      repository = "s3:https://s3.eu-central-1.wasabisys.com/hyperfekt-personal-backup";
      passwordFile = "/cfg/secrets/restic-normal-backup.pass";
      s3CredentialsFile = "/cfg/secrets/wasabi-bismuth-restic.env";
    };
  };

  home-manager.users.${user}.xdg.configFile."baloofilerc".text = ''
    [General]
    dbVersion=2
    exclude filters=${pkgs.lib.concatStringsSep "," ([
      "lzo"
      "ui_*.h"
      "nbproject"
      "CTestTestfile.cmake"
      "*.ini"
      "*.pyo"
      ".yarn-cache"
      "core-dumps"
      "*.rcore"
      "*.loT"
      "*.aux"
      ".moc"
      ".bzr"
      "CMakeFiles"
      "lost+found"
      "*.gmo"
      "*.elc"
      "CMakeTmp"
      "__pycache__"
      "*.qmlc"
      "po"
      "CMakeTmpQmake"
      "autom4te"
      "*.part"
      "qrc_*.cpp"
      ".pch"
      "*.so"
      "conftest"
      "*.map"
      ".yarn"
      "*.orig"
      ".uic"
      "CVS"
      "*.m4"
      "moc_*.cpp"
      "*.jsc"
      "node_modules"
      "cmake_install.cmake"
      "config.status"
      "CMakeCache.txt"
      "*.pc"
      "*.tmp"
      "*.moc""*.la"
      "_darcs"
      "*.qrc"
      "*.po"
      "*.init"
      "*.csproj"
      "*.vm*"
      ".xsession-errors*"
      "*.lo"
      "*.db"
      "libtool"
      "*.a"
      "confstat"
      "litmain.sh"
      "*.class"
      "*~"
      ".obj"
      ".npm"
      ".histfile.*"
      "*.omf"
      "*.o"
      ".git"
      "Makefile.am"
      ".hg"
      "*.nvram"
      "*.swap"
      ".svn"
      "node_packages"
      "*.rej"
      "confdefs.h"
      "*.pyc"
    ] ++ [
      "restic-generated"
      ".cache/restic"
    ])}
    exclude filters version=3
    first run=false
  '';
}
