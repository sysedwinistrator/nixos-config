{ config, lib, pkgs, ...}:

with lib;

let
  pdns = pkgs.pdns;
  pdnsConfig = pkgs.writeTextDir "etc/pdns.conf"
    ''
      launch=gsqlite3
      gsqlite3-database=/var/lib/powerdns/pdns.sqlite3
      webserver=true
      webserver-address=0.0.0.0
      webserver-port=8053
      webserver-allow-from=127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128, fe80::/10
      dnsupdate=yes
      allow-dnsupdate-from=127.0.0.0/8, 10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12, ::1/128, fe80::/10
      tcp-control-address=0.0.0.0
      tcp-control-secret=${pdnsControlSecret}
    '';
  pdnsControlSecret = builtins.readFile /etc/nixos/secrets/pdns-control;
  pdnsUser = "powerdns";
  pdnsGroup = "powerdns";
in

{
  config = lib.mkIf config.host.pdns.enable {
    users.users.${pdnsUser} = {
      group = pdnsGroup;
      isSystemUser = true;
    };
    users.groups.${pdnsGroup} = {};

    systemd.services.pdns = {
      description = "PowerDNS Authoritative Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = 
        {
          ExecStart = "${pdns}/bin/pdns_server --config-dir=${pdnsConfig}/etc --guardian=no --daemon=no --disable-syslog --log-timestamp=no --write-pid=no";
          SyslogIdentifier = "pdns_server";
          User = "${pdnsUser}";
          Group = "${pdnsGroup}";
          Type = "notify";
          Restart = "on-failure";
          RestartSec = "1";
          StartLimitInterval = "0";
          RuntimeDirectory = "pdns";
          # Sandboxing
          CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_CHOWN";
          AmbientCapabilities = "CAP_NET_BIND_SERVICE CAP_CHOWN";
          LockPersonality = "true";
          NoNewPrivileges = "true";
          PrivateDevices = "true";
          PrivateTmp = "true";
          # Setting PrivateUsers=true prevents us from opening our sockets
          ProtectClock = "true";
          ProtectControlGroups = "true";
          ProtectHome = "true";
          ProtectHostname = "true";
          ProtectKernelLogs = "true";
          ProtectKernelModules = "true";
          ProtectKernelTunables = "true";
          # ProtectSystem=full will disallow write access to /etc and /usr, possibly
          # not being able to write slaved-zones into sqlite3 or zonefiles.
          ProtectSystem = "full";
          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
          RestrictNamespaces = "true";
          RestrictRealtime = "true";
          RestrictSUIDSGID = "true";
          SystemCallArchitectures = "native";
          SystemCallFilter = "~ @clock @debug @module @mount @raw-io @reboot @swap @cpu-emulation @obsolete";
        };
    };
  };
  options = {
    host.pdns = {
      enable = mkEnableOption "PowerDNS";
    };
  };
}
