# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/17870658-6118-46af-837f-70c9175e09c3";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" ];
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/c6098a16-c8a6-4a97-8648-6f46ca919d13";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/17870658-6118-46af-837f-70c9175e09c3";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/17870658-6118-46af-837f-70c9175e09c3";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/swap" =
    { device = "/dev/disk/by-uuid/17870658-6118-46af-837f-70c9175e09c3";
      fsType = "btrfs";
      options = [ "subvol=swap" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/29B7-F46D";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ {
    device = "/swap/swapfile";
  } ];

  boot.resumeDevice = "/dev/disk/by-uuid/17870658-6118-46af-837f-70c9175e09c3";
  boot.kernelParams = [ "resume_offset=53224704" ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
