{
  # Enable hard drive active protection system.
  services.hdapsd.enable = true;
  nixpkgs.overlays = [
    (self: super: {
      hdapsd = super.hdapsd.overrideAttrs (oldAttrs: {
        src = super.fetchFromGitHub {
          owner = "evgeni";
          repo = "hdapsd";
          rev = "3ca4b1a9150514f8e92190d3b43da5aab1244ef9";
          sha256 = "108qyd524s9jzb696hlkjglxh3c6rjni4kjn322vfw442rc25izx";
        };
        preConfigurePhases = "autoconfPhase";
        autoconfPhase = "./autogen.sh";
        nativeBuildInputs = with super; [ autoconf automake pkgconfig ];
      });
    })
  ];
}
