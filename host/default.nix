{config, lib, pkgs, ...}:

with lib;

{
  config = {
    hardware.enableRedistributableFirmware = true;

    boot.loader = lib.mkIf config.host.uefi {
      grub.enable = false;
      systemd-boot.enable = true;
    };

    services.zfs = lib.mkIf config.host.zfs {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
      trim.enable = lib.mkIf config.host.ssd true;
    };
    boot.zfs.enableUnstable = lib.mkIf config.host.zfs true;
  };
  options.host = {
    name = mkOption {
      type = types.str;
      description = ''
        Host name
      '';
    };
    hostId = mkOption {
      type = types.str;
      description = ''
        HostID for ZFS
      '';
    };
    zfs = mkOption {
      type = types.bool;
    };
    ssd = mkOption {
      type = types.bool;
    };
    uefi = mkOption {
      type = types.bool;
      default = true;
    };
  };
}
