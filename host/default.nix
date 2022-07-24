{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.host;
in
{
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
  };
}
