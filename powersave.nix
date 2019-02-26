{pkgs, lib, ...}:
{
  powerManagement = {
    cpuFreqGovernor = "powersave";
    # SATA link power management
    scsiLinkPolicy = "med_power_with_dipm";
  };

  boot.extraModprobeConfig = lib.mkMerge [
    # idle audio card after one second
    "options snd_hda_intel power_save=1"
    # enable wifi power saving (keep uapsd off to maintain low latencies)
    "options iwlwifi power_save=1 power_level=5 d0i3_disable=0 uapsd_disable=1"
    "options iwldvm force_cam=0"
  ];

  services.udev.extraRules = lib.mkMerge [
    # autosuspend USB devices
    ''ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"''
    # autosuspend PCI devices
    ''ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"''
    # disable Ethernet Wake-on-LAN
    ''ACTION=="add", SUBSYSTEM=="net", NAME=="enp*", RUN+="${pkgs.ethtool}/sbin/ethtool -s $name wol d"''
  ];
}
