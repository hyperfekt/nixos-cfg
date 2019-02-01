{
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Berlin";
  
  services.xserver.layout = "de";
  services.xserver.xkbOptions = "eurosign:e";

  programs.sway-beta.extraSessionCommands = ''
      export XKB_DEFAULT_LAYOUT=de
      export XKB_DEFAULT_OPTIONS=eurosign:e
  '';
}
