{ inputs, den, ... }:
{
  den.aspects.minipc.includes = [ ];

  perSystem = { pkgs, ... }: {
    packages.vm = pkgs.writeShellApplication {
      name = "vm";
      text =
        let
          host = inputs.self.nixosConfigurations.minipc.config;
        in
        ''
          ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm \
            -device virtio-vga-gl \
            -vga none \
            -display gtk,gl=on,grab-on-hover=on,clipboard=on \
            "$@"
        '';
    };
  };
}
