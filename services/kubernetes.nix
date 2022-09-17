{ config, lib, pkgs, ...}:

let
  master = builtins.elemAt (builtins.filter (x: builtins.elem "master" x.kubernetes_roles) config.lab.all_hosts) 0;
  api = "https://${master.ip}:${builtins.toString config.services.kubernetes.apiserver.securePort}";
  is_master = builtins.elem "master" config.lab.current_host.kubernetes_roles;
  is_node = builtins.elem "node" config.lab.current_host.kubernetes_roles;
in
{
  config = lib.mkIf (is_master || is_node) {
    fileSystems = lib.mkIf config.host.zfs {
      "/var/lib/containerd" = {
        device = "${config.host.zfsDataSet}/containerd";
        fsType = "zfs";
        options = [ "zfsutils" ];
      };
      "/var/lib/etcd" = lib.mkIf is_master {
        device = "${config.host.zfsDataSet}/etcd";
        fsType = "zfs";
        options = [ "zfsutils" ];
      };
    };
    services.kubernetes = {
      # We use kube-proxy instead
      flannel.enable = false;
      proxy.enable = false;

      easyCerts = true;
      addons.dns.enable = true;

      roles = config.lab.current_host.kubernetes_roles;
      masterAddress = master.ip;
      apiserverAddress = api;

      # master configuration
      apiserver = lib.mkIf is_master {
        advertiseAddress = master.ip;
      };

      # node configuration
      kubelet.kubeconfig.server = lib.mkIf is_node api;
    };
  };
}
