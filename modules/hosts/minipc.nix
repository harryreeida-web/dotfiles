{ inputs, den, ... }:
{
  den.hosts.x86_64-linux.minipc.users.gmang.classes = [
    "hjem"
    "nixos"
  ];

  den.aspects.minipc = {
    includes = [ ];

    nixos =
      {
        config,
        lib,
        pkgs,
        modulesPath,
        ...
      }:

      {
        networking.hostName = "minipc";
        flake = "/home/gmang/.dotfiles";
        vim = false;

        login.automatic = true;
        login.defaultUser = "gmang";

        environment.systemPackages = with pkgs; [ openrgb-with-all-plugins ];

        services.hardware.openrgb.enable = true;
        # users.users.gmang.hashedPassword = "$6$ViKUvMFrL0cUsQh5$FzTwFXKBBTacGN7GjF0NOCW0nemcQtPO8.TLJ7WhLY19nCJOZnYj.8CQu7eoqLkabKSQc49W6K8FexP7LFxHp0";

        # DO NOT TOUCH PAST HERE!!!

        system.stateVersion = "25.11";


  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1d373edf-e679-4d2d-b1df-fb6ba0981650";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3223-F058";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/8a6c031e-bd03-42f1-bb57-4c7c7a97fe03"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
};


    provides.to-users.hjem = {
      xdg.config.files."mango/monitors.conf".text = ''
        monitor_rule=name:HDMI-A-1,width:1360,height:768,refresh:60,x:0,y:0
        monitor_rule=name:DP-2,width:1920,height:1080,refresh:59.94000,x:1360,y:0,primary:1
        monitor_rule=name:DP-3,width:1920,height:1080,refresh:60,x:3280,y:0,rr:3

        tag_rule=id:*,monitor_name:DP-3,layout_name:vertical_tile
      '';
    };
  };
}
