{ config, lib, pkgs, ...}:

{
  config = lib.mkIf config.host.docker.enable {
    # docker
    virtualisation.docker = {
      enable = true;
      storageDriver = "zfs";
    };
  };
  options = {
    host.docker.enable = mkOption {
      type = types.bool;
    };
  };
}
