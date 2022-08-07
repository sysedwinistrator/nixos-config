{ config, lib, pkgs, ...}:

with lib;

{
  config = lib.mkIf config.host.pdnsd.enable {
    services.pdnsd = {
      enable = true;
      globalConfig = ''
        launch=gsqlite3
        gsqlite3-database=/var/lib/powerdns/pdns.sqlite3
        webserver=true
        webserver-address=0.0.0.0
        webserver-port=8053
      '';
    };
  };
  options = {
    host.pdnsd = {
      enable = mkEnableOption "PowerDNS";
    };
  };
}
