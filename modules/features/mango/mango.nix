{ den, inputs, ... }: {
  flake-file.inputs.mango = {
    url = "github:mangowm/mango";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.mango = {
    nixos =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        imports = [
          inputs.mango.nixosModules.mango
        ];

        programs.mango.enable = true;
      };

    hjem = { osConfig, lib, ... }: {
      xdg.config.files."mango/config.conf".source =
        "${osConfig.flake}/modules/features/mango/config.conf";
      xdg.config.files."mango/binds.conf".source = "${osConfig.flake}/modules/features/mango/binds.conf";
      xdg.config.files."mango/monitors.conf".text = lib.mkDefault "";
      xdg.config.files."mango/swap-tags.sh".source = "${osConfig.flake}/modules/features/mango/swap-tags.sh";
    };
  };
}
