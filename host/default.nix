{config, lib, pkgs, ...}:

with lib;

{
  config = {
    services.zfs = lib.mkIf config.host.zfs {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
      trim.enable = lib.mkIf config.host.ssd true;
    };
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
  };
}
