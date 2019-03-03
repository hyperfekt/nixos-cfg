{ pkgs, ... }:
{
  patches = [ (builtins.fetchurl https://github.com/NixOS/nixpkgs/pull/49506.diff) ];

  security.pam.defaults = "session required pam_keyinit.so force revoke";
}
