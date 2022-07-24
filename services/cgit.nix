{ config, lib, pkgs, ...}:

with lib;

{
  config = lib.mkIf config.host.cgit.enable {
    services.lighttpd = {
      enable = true;
      cgit = {
        enable = true;
        configText =
          ''
            scan-path=${config.host.cgit.path}
          '';
      };
    };
  };
  options = {
    host.cgit.enable = mkOption {
      type = types.bool;
      default = false;
    };
    host.cgit.scanpath = mkOption {
      type = types.path;
    };
  };
}
