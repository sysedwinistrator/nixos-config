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
    host.rancher = {
      enable = true;
      roles = ["controlplane" "worker"];
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+ResginDO3aOjCVc+5JIbvnxaw58LEwRhTSsv6JHJ4 edwin@dhyana"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII32nGkOM9WitJaDsiboxbQAVjpemC5uUotOFlFqiYhY rancher"
      ];
    };
    host.pdns.enable = true;
  };
}
