{ config, lib, pkgs, ...}:

{
  config = lib.mkIf config.host.rancher.enable {
    # SSH access
    users.users.rancher = {
      isNormalUser = true;
      home = "/home/rancher";
      description = "Service user for rancher";
      extraGroups = [ "docker" ];
      openssh.authorizedKeys.keys = config.host.rancher.sshKeys;
    };
  };
  options = {
    host.rancher.enable = mkOption {
      type = types.bool;
    };
    host.rancher.roles = mkOption {
      type = types.listOf types.enum ["controlplane" "worker" "etcd"];
      description = ''
        Rancher roles
      '';
    };
    host.rancher.sshKeys = mkOption {
      type = types.listOf types.string;
    };
  };
}
