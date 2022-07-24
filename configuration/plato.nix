{ config, lib, pkgs, ...}:

{
  imports = [
    ../common.nix
    ../hardware-configuration/plato.nix
  ];

  config = {
    host.name = "plato";
    host.hostId = "8556b001";
    host.rancher = {
      enable = true;
      roles = ["etcd" "worker"];
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+ResginDO3aOjCVc+5JIbvnxaw58LEwRhTSsv6JHJ4 edwin@dhyana"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII32nGkOM9WitJaDsiboxbQAVjpemC5uUotOFlFqiYhY rancher"
      ];
    };
    host.cgit = {
      enable = true;
      scanpath = /srv/git;
    };
  };
}
