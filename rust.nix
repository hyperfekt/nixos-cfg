{ user, pkgs, unstable, ... }:
let
  nixShellWrapper = command: pkgs.writeShellScript "${command}_nix-shell_wrapper.sh" ''
    argv=( "$@" )
    exec nix-shell --pure --run "${command} ''${argv[*]}"
  '';

  nixShellRustFmt = nixShellWrapper "rustfmt";
  nixShellRLS = pkgs.writeShellScript "rls_with-sysroot_nix-shell_wrapper.sh" ''
    export LD_LIBRARY_PATH=$(${nixShellWrapper "rustc"} --print sysroot)/lib:$LD_LIBRARY_PATH
    source ${nixShellWrapper "rls"}
  '';
in
{
  environment.systemPackages = [
    unstable.carnix
    ( unstable.rr.overrideAttrs (oldAttrs: rec {
      version = "2019-08-03";
      pname = "rr";
      name = "${pname}-${version}";
      src = pkgs.fetchFromGitHub {
        owner = "mozilla";
        repo = "rr";
        rev = "37dfe3320d4dbb0a93810f9178d5fb838e726217";
        sha256 = "14ynvkrjm70f5jyd993cry1gy0kp7igwaik73m51zb6q79bp1lgr";
      };
      buildInputs = with unstable; [ python3Packages.python python3Packages.pexpect ] ++ oldAttrs.buildInputs;
    } ) )
  ];

  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1; # required for rr recording

  vscode.settings = {
    "rust-client.disableRustup" = true;
    "rust-client.rlsPath" = "${nixShellRLS}";
    "rust.rustfmt_path" = "${nixShellRustFmt}";
    "rust.clippy_preference" = "on";
    "lldb.adapterType" = "native";
  };

  vscode.pulledExtensions = [
    "rust-lang.rust"
    "bungcip.better-toml"
  ];

  vscode.packagedExtensions = [ (
    unstable.vscode-utils.buildVscodeExtension rec {
      name = "vadimcn.vscode-lldb-x86_64-linux";
      src = pkgs.requireFile {
        url = "https://github.com/vadimcn/vscode-lldb/releases/latest/download/vscode-lldb-x86_64-linux.vsix";
        name = "vadimcn-vscode-lldb-x86_64-linux.zip";
        sha256 = "186f8f6r2awiqaz0gcknm4zdf8vxfxmzxg64l0z8is6q307gr90m";
      };
      vscodeExtUniqueId = name;
      dontPatchELF = false;
      dontStrip = false;
    }
  ) ];
}
