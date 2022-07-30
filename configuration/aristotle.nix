{ config, lib, pkgs, ...}:

{
  imports = [
    ../common.nix
    ../hardware-configuration/aristotle.nix
  ];

  config = {
    host.name = "aristotle";
    host.hostId = "8e6e09c0";
    host.zfs = true;
    host.ssd = false;
    host.rancher = {
      enable = true;
      roles = ["worker"];
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+ResginDO3aOjCVc+5JIbvnxaw58LEwRhTSsv6JHJ4 edwin@dhyana"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII32nGkOM9WitJaDsiboxbQAVjpemC5uUotOFlFqiYhY rancher"
      ];
    };
  };
}
