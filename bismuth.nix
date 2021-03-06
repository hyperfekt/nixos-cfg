{ config, pkgs, ... }:
let
  user = "adrian";

  sources = import ./nix/sources.nix;

  unstable = import sources.nixpkgs-unstable { config = config.nixpkgs-alt.config; };

  niv = import sources.niv {};

in
{
  _module.args.user = user;
  _module.args.sources = sources;
  _module.args.unstable = unstable;

  imports = [
    # Add custom modules.
    ./modules/all-modules.nix
    # Include the results of the hardware scan.
    ./bismuth/hardware-configuration.nix
    # Enable bcachefs root support.
    ./bcachefs-support.nix
    # Backups!
    ./backup.nix
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
    # Use the Sway window manager.
    ./sway.nix
    # Make Ubuntu the default font.
    ./ubuntu-font.nix
    # Enable aptX Bluetooth.
    ./bluetooth.nix
    # Activate powersaving measures.
    ./powersave.nix
    # Enable hardware video decoding acceleration for Intel graphics.
    ./video-acceleration.nix
    # Enable SSD-specific tweaks.
    ./ssd.nix
    # Enable platter-specific tweaks.
    ./hdd.nix
    # Compress memory in RAM.
    ./zram.nix
    # Add shell aliases.
    ./aliases.nix
    ./redshift.nix
    ./steam.nix
  ];

  nix.nixPath = [ "nixos-config=${toString ./bismuth.nix}" ];
  setupScript = ''
    NIX_PATH=nixpkgs=/cfg/patched:nixos-config=/cfg/bismuth.nix
    nixos-rebuild switch
  '';

  # kills networking for some reason?
  # system.autoUpgrade.enable = true;

  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;
  nix.maxJobs = 16;

  # use --option binary-caches https://cache.nixos.org to rebuild if any of these goes down
  nix.binaryCaches = [
    "http://aseipp-nix-cache.global.ssl.fastly.net/"
    "https://cache.nixos.org"
  ];
  nix.extraOptions = ''
    # fall back to other caches if one is down
    fallback = true
    # prevent future rebuilds from breaking if one is violently aborted (breaks bcachefs)
    # sync-before-registering = true
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "bismuth"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$6$64iOISRiRDrN$rJIV0nCsnxZ4kCFHQSq7vAc.3EX8JJ6Q22YFGrCLLNoBiOk3B4WW3Y4AUaxKW1JhmuCt7cHkxGhJY8eomKc0k0";
  };

  users.mutableUsers = false;

  environment.systemPackages = with pkgs; [
    firefox
    unstable.pijul
    nix-prefetch-git
    alacritty
    ripgrep
    unstable.youtube-dl
    vlc
    lsof
    unstable.nox
    iotop
    fd
    hyperfine
    bat
    fzf #todo: enable
    asciinema
    pv
    du-dust
    parallel
    gdb
    wget
    nix-diff
    /* polyglot */ (callPackage (builtins.fetchurl https://raw.githubusercontent.com/hyperfekt/nixpkgs/init_polyglot/pkgs/development/tools/misc/polyglot/default.nix) {})
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
