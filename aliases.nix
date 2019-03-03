{
  environment.shellAliases = {
    nix-build-call = "nix-build -E \"with import <nixos-unstable> {}; callPackage ./default.nix {}\"";
    nixos-rebuild-unpatched = "nixos-rebuild switch -I nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos";
  };
}
