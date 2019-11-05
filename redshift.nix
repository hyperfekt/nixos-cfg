{ pkgs, ... }:
{
  patches = [
    ./patches/redshift.diff
  ];

  services.redshift = {
    enable = true;
    settings = {
      redshift = {
        dawn-time = "05:00-06:00";
        dusk-time = "22:00-23:00";
        temp-night = 3000;
      };
    };
  };
}
