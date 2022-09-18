{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = lib.mkIf config.host.lxd.enable {
    virtualisation = {
      lxd = {
        enable = true;
        recommendedSysctlSettings = true;
        zfsSupport = lib.mkIf config.host.zfs true;
      };
      lxc = {
        enable = true;
        lxcfs.enable = true;
      };
    };
  };
  options = {
    host.lxd.enable = mkEnableOption "lxd";
  };
}
