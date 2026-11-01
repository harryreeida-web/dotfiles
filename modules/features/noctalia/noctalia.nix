{ inputs, ... }: {
  flake-file.inputs = {
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.noctalia = { ... }: {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ inputs.noctalia-greeter.nixosModules.default ];

        options.login = {
          automatic = lib.mkOption { default = false; };
          defaultUser = lib.mkOption { type = lib.types.str; };
          session = lib.mkOption {
            type = lib.types.str;
            default = "mango";
          };
        };

        config = {
          networking.networkmanager.enable = lib.mkForce true;
          hardware.bluetooth.enable = lib.mkForce true;
          services.power-profiles-daemon.enable = lib.mkForce true;
          services.upower.enable = lib.mkForce true;

          services.greetd = lib.mkIf config.login.automatic {
            enable = true;
            settings = rec {
              initial_session = {
                command = config.login.session;
                user = config.login.defaultUser;
              };
              default_session = initial_session;
            };
          };

          services.displayManager.noctalia-greeter = lib.mkIf (!config.login.automatic) {
            enable = true;
            passwordless-sync-users = builtins.attrNames config.users.users;
            settings = {
              cursor = {
                theme = "Bibata-Modern-Ice";
                size = 24;
                path = pkgs.bibata-cursors;
              };
            };
          };

          environment.systemPackages = with pkgs; [
            inputs.noctalia.packages.${stdenv.hostPlatform.system}.default

            # For GTK3/4 applications
            adw-gtk3
            nwg-look

            # For QT applications
            qt6Packages.qt6ct
          ];

          environment.variables.QT_QPA_PLATFORMTHEME = "qt6ct";
        };
      };

    hjem = { osConfig, pkgs, ... }: {
      xdg.config.files."noctalia/config.toml".source =
        "${osConfig.flake}/modules/features/noctalia/config.toml";
      files.".icons/default".source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Ice";
    };
  };
}
