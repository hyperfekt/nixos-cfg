{ unstable, ...}:
{
  nixpkgs.overlays = [
    (self: super: {
        nix = unstable.nix;
    })
  ];
}
