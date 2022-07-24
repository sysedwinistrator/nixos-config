{ config, lib, pkgs, ...}:

{
  config = libMkif config.host.cgit.enable {
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
    };
    host.cgit.scanpath = {
      type = types.path;
    };
  };
}
