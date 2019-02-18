{ unstable, ... }:
{
  hardware.opengl = {
     enable = true;
     extraPackages = with unstable; [
       (vaapiIntel.override { enableHybridCodec = true; })
       vaapiVdpau
       libvdpau-va-gl
     ];
   };
}
