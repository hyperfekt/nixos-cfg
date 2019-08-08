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
          "pnp.polacode"
          "eamodio.gitlens"
          "skyapps.fish-vscode"
          "GitHub.vscode-pull-request-github"
          "liximomo.sftp"
          "MS-vsliveshare.vsliveshare"
        ]) ++ [ (
          unstable.vscode-utils.buildVscodeExtension rec {
            name = "vadimcn.vscode-lldb-x86_64-linux";
            src = builtins.fetchurl {
              url = "https://github.com/vadimcn/vscode-lldb/releases/latest/download/vscode-lldb-x86_64-linux.vsix";
              name = "vadimcn-vscode-lldb-x86_64-linux.zip";
            };
            vscodeExtUniqueId = name;
          }
        ) ];
    };
in
  {
    environment.systemPackages = [ custom-vscode ];

    environment.variables."EDITOR" = "${custom-vscode}/bin/code --wait --new-window";

    home-manager.users.${user}.programs = {
      git.extraConfig = {
        diff.tool = "vscode";
        "difftool \"vscode\"".cmd = "${custom-vscode}/bin/code --wait --new-window --diff $LOCAL $REMOTE";
      };

      vscode = {
        enable = true;

        userSettings = {
          "update.channel" = "none";
          "extensions.autoUpdate" = false;
          "editor.wordWrap"= "on";
          "files.insertFinalNewline" = true;
          "editor.renderFinalNewline" = false;
          "files.trimTrailingWhitespace" = true;
          "[plaintext]" = {
            "files.insertFinalNewline" = false;
            "editor.renderFinalNewline" = true;
            "files.trimTrailingWhitespace" = false;
          };
          "[markdown]" = {
            "files.trimTrailingWhitespace" = false;
          };
          "telemetry.enableTelemetry" = false;
          "telemetry.enableCrashReporter" = false;
          "[nix]"."editor.tabSize" = 2;
          "diffEditor.originalEditable"= true;
        };
      };
    };
  }
