{
  lib,
  den,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    nix-fast-build.url = "github:Mic92/nix-fast-build";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify.url = "github:Gerg-L/spicetify-nix";
  };

  perSystem = { pkgs, ... }: {
    packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
    formatter = pkgs.nixfmt-tree;
  };

  den.default = {
    includes = [
      den.aspects.keyboard
      den.aspects.terminal
      den.aspects.mango
      den.aspects.noctalia
      den.aspects.editor
      den.aspects.gaming
    ];

    hjem.clobberFiles = true;

    nixos =
      {
        config,
        pkgs,
        options,
        ...
      }:
      {
        imports = [
          ./_cachix/cachix.nix
          inputs.spicetify.nixosModules.default
        ];

        options = {
          vim = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };

          flake = lib.mkOption { };
        };

        config = {
          time.timeZone = "Australia/Melbourne";

          xdg.portal.enable = true;
          environment.pathsToLink = [
            "/share/xdg-desktop-portal"
            "/share/applications"
          ];

          services.dbus.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
          };

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          hardware.uinput.enable = true;
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };

          environment.sessionVariables.NIXOS_OZONE_WL = "1";

          nixpkgs.config.allowUnfree = true;

          fonts.packages = with pkgs; [ jetbrains-mono ];
          environment.systemPackages = with pkgs; [
            cachix
            inputs.hjem.packages.${pkgs.stdenv.hostPlatform.system}.hjem
            inputs.nix-fast-build.packages.${pkgs.stdenv.hostPlatform.system}.default
            inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

            brightnessctl
            jq

            # Random applications
            mpv # Video player
            qview # Image viewer
            krita # Image editor
            nautilus # File explorer
            libreoffice # Document editor
            flamegraph # Profiler visualiser
            transmission_4-qt # Torrent
            obsidian
            localsend
            discord-ptb
            # (discord.override {
            #   withOpenASAR = true; # can do this here too
            #   withVencord = true;
            # })
          ];

          programs.nh = {
            enable = true;
            clean.enable = true;
            clean.extraArgs = "--keep-since 4d --keep 3";
            flake = config.flake;
          };

          programs.spicetify = {
            enable = true;

            theme = {
              name = "Tokyo";
              colorScheme = "Night";
              src = pkgs.fetchFromGitHub {
                owner = "evening-hs";
                repo = "Spotify-Tokyo-Night-Theme";
                rev = "d88ca06eaeeb424d19e0d6f7f8e614e4bce962be";
                hash = "sha256-cLj9v8qtHsdV9FfzV2Qf4pWO8AOBXu51U/lUMvdEXAk=";
              };

              # Additional theme options all set to defaults
              # the docs of the theme should say which of these
              # if any you have to change
              injectCss = true;
              injectThemeJs = true;
              replaceColors = true;
              sidebarConfig = true;
              homeConfig = true;
              overwriteAssets = false;
              additonalCss = "";
            };
          };

          # For localsend
          programs.localsend.enable = true;
          programs.localsend.openFirewall = true;
          networking.firewall.enable = true;

          # For torrent client
          services.transmission.settings = {
            download-dir = "${config.services.transmission.home}/Downloads";
          };

          programs.dconf.enable = true;

          networking.networkmanager.enable = true;
          nix.settings = {
            trusted-users = [
              "root"
              "mckahz"
              "gmang"
            ];
            warn-dirty = false;
            experimental-features = [
              "nix-command"
              "flakes"
              "pipe-operators"
            ];
          };
        };
      };

  };

  # enable hm by default
  den.schema.user.classes = lib.mkDefault [ "hjem" ];
}
