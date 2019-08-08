{ pkgs, ... }:
{
  patches = [ (pkgs.fetchpatch {
    url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/50979.diff";
    sha256 = "0jq2k3xjk5a8nvbwq5gvhg3z5wf4388lrlzbf3hsfixmzfih6758";
   }) ];

  services.redshift = {
    enable = true;
    config = {
      redshift = {
        dawn-time = "05:00-06:00";
        dusk-time = "22:00-23:00";
        temp-night = 3000;
      };
    };
  };
}
