{
  environment.shellAliases = {
    nix-build-call = ''nix-build -E "with import <nixos> {}; callPackage ./default.nix {}"'';
    nixos-rebuild-unpatched = "nixos-rebuild switch -I nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos";
    nrs = "sudo nixos-rebuild switch --fast";
    nru = "nix run -f /nix/var/nix/profiles/per-user/root/channels/nixos-unstable/";
  };
}
