{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../common.nix
    ../hardware-configuration/aristotle.nix
  ];

  config = {
    host.name = "aristotle";
    host.hostId = "8e6e09c0";
    host.zfs = true;
    host.zfsDataSet = "zroot/data";
    host.ssd = false;
    host.lxd.enable = true;
  };
}
