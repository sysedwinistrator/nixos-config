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
    host.cgit.enable = {
      type = types.bool;
      default = false;
    };
    host.cgit.scanpath = {
      type = types.path;
    };
  };
}
