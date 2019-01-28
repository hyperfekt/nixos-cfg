{ config, pkgs, ... }:
let
  user = "adrian";

  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
in
{
  _module.args.user = user;
  _module.args.unstable = unstable;

  imports =
    [ # Include the results of the hardware scan.
      ./bismuth/hardware-configuration.nix
      # Enable bcachefs root support.
      ./bcachefs-support.nix
      # Pull in Mozilla Rust Overlay and install Rust & Carnix.
      ./rust.nix
      # Set German keyboard layout.
      ./layout_de.nix
      # Allow unfree packages.
      ./unfree.nix
      # Install Visual Studio Code with extensions.
      ./vscode.nix
      # Activate home-manager for use as a NixOS module.
      ./home-manager.nix
      # Set the fish shell as default.
      ./fish.nix
      # Install and configure git.
      ./git.nix
      # Install Spotify.
      ./spotify.nix
    ];

  system.autoUpgrade.enable = true;

  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bismuth"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5 = {
    enable = true;
    enableQt4Support = false;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adrian = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "configuration" ];
    hashedPassword = "$6$64iOISRiRDrN$rJIV0nCsnxZ4kCFHQSq7vAc.3EX8JJ6Q22YFGrCLLNoBiOk3B4WW3Y4AUaxKW1JhmuCt7cHkxGhJY8eomKc0k0";
  };

  users.groups.configuration = {};

  users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    firefox
    unstable.pijul
    nix-prefetch-git
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
