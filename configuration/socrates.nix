{ config, lib, pkgs, ...}:

{
  imports = [
    ../common.nix
    ../hardware-configuration/socrates.nix
  ];

  config = {
    host.name = "socrates";
    host.hostId = "7ee536a0";
    host.zfs = true;
    host.ssd = true;
    host.pdns.enable = true;
  };
}
