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
      # Use KDE desktop environment.
      ./kde.nix
      # Make Ubuntu the default font.
      ./ubuntu-font.nix
      # Enable aptX Bluetooth.
      ./bluetooth.nix
    ];

  system.autoUpgrade.enable = true;

  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;
  nix.buildCores = 0; # redundant in 19.03
  nix.maxJobs = 16;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bismuth"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
    alacritty
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
