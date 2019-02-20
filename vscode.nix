{ user, pkgs, unstable, lib, ... }:
let
  idToDrv = id:
    unstable.vscode-utils.buildVscodeExtension {
      name = id;
      src = getVsix id;
      vscodeExtUniqueId = id;
    };

  getVsix = id:
    let
      publisher = lib.head (lib.splitString "." id);
      name = lib.head (lib.tail (lib.splitString "." id));
    in
      builtins.fetchurl {
        url = "https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${name}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
        name = "${publisher}-${name}.zip";
      };

  custom-vscode = unstable.vscode-with-extensions.override {
      vscodeExtensions = with unstable.vscode-extensions; [
          bbenoist.Nix
        ] ++ (map idToDrv [
          "rust-lang.rust"
          "vadimcn.vscode-lldb"
        ])
      ;
    };
in
  {
    environment.systemPackages = [ custom-vscode ];

    home-manager.users.${user}.programs.vscode = {
      enable = true;

      userSettings = {
        "update.channel" = "none";
        "extensions.autoUpdate" = false;
        "files.insertFinalNewline" = true;
        "editor.renderFinalNewline" = false;
        "files.trimTrailingWhitespace" = true;
        "[plaintext]" = {
          "files.insertFinalNewline" = false;
          "editor.renderFinalNewline" = true;
          "files.trimTrailingWhitespace" = false;
        };
        "telemetry.enableTelemetry" = false;
        "telemetry.enableCrashReporter" = false;
        "[nix]"."editor.tabSize" = 2;
      };
    };
  }
