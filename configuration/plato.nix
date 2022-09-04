{ config, lib, pkgs, ...}:

{
  imports = [
    ../common.nix
    ../hardware-configuration/plato.nix
  ];

  config = {
    host.name = "plato";
    host.hostId = "8556b001";
    host.zfs = true;
    host.zfsDataSet = "znix/data";
    host.ssd = true;
    host.cgit = {
      enable = true;
      scanpath = "/srv/git";
    };
    host.pdns.enable = true;
  };
}
