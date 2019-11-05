{ user, pkgs, unstable, lib, config, options, ... }:
with lib;
let
  idToDrv = id:
    unstable.vscode-utils.buildVscodeExtension {
      name = id;
      src = getVsix id;
      vscodeExtUniqueId = id;
    };

  getVsix = id:
    let
      publisher = head (splitString "." id);
      name = head (tail (splitString "." id));
    in
      builtins.fetchurl {
        url = "https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${name}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage";
        name = "${publisher}-${name}.zip";
      };

  customVSCode = unstable.vscode-with-extensions.override {
    vscodeExtensions = config.vscode.packagedExtensions ++ (map idToDrv config.vscode.pulledExtensions);
  };
in
  {
    options.vscode = with types; {
      packagedExtensions = mkOption {
        type = listOf package;
        default = [];
      };
      pulledExtensions = mkOption {
        type = listOf string;
        default = [];
      };
      settings = mkOption {
        type = attrs;
        default = {};
      };
    };

    config = {
      vscode.settings = {
          "update.mode" = "none";
          "extensions.autoUpdate" = false;
      } // {
          "editor.scrollBeyondLastLine"= false;
          "editor.wordWrap" = "on";
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
          "diffEditor.originalEditable" = true;
          "workbench.sideBar.location" = "right";
          "editor.acceptSuggestionOnEnter" = "off";
          "terminal.integrated.automationShell.linux" = pkgs.runCommand "nix-shell_run.sh" { nativeBuildInputs = [ pkgs.makeWrapper ]; }
            "makeWrapper ${pkgs.nix}/bin/nix-shell $out --run 'shift' --add-flags '--run'"; # replace -c flag with --run flag
        };

      vscode.pulledExtensions = [
        "pnp.polacode"
        "eamodio.gitlens"
        "GitHub.vscode-pull-request-github"
        "liximomo.sftp"
        #"MS-vsliveshare.vsliveshare"
        "ms-vscode-remote.remote-ssh"
        "bbenoist.Nix"
        "arrterian.nix-env-selector"
        "TabNine.tabnine-vscode"
      ];

      vscode.packagedExtensions = with unstable.vscode-extensions; [
        ms-vscode.cpptools
      ];

      environment.systemPackages = [ customVSCode ];

      environment.variables."EDITOR" = "${customVSCode}/bin/code --wait --new-window";

      home-manager.users.${user}.programs = {
        git.extraConfig = {
          diff.tool = "vscode";
          "difftool \"vscode\"".cmd = "${customVSCode}/bin/code --wait --new-window --diff $LOCAL $REMOTE";
        };

        vscode = {
          enable = true;
          userSettings = config.vscode.settings;
        };
      };
    };
  }
