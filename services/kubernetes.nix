{ ... }:

let
  inherit all_hosts;
  inherit current_all;
  master = builtins.filter (x: builtins.elem "master" x.kubernetes_roles) all_hosts;
  api = "https://${master.ip}:${services.kubernetes.apiserver.securePort}";
in
{
  config = lib.mkIf services.kubernetes.roles != null {
    fileSystems = lib.mkIf config.host.zfs {
      "/var/lib/containerd" = {
        device = "${config.host.zfsDataSet}/containerd";
        fsType = "zfs";
        options = [ "zfsutils" ];
      };
      "/var/lib/etcd" = lib.mkIf services.kubernetes.roles == "master" {
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

      roles = current_host.kubernetes_roles;
      masterAddress = master.ip;
      apiserverAddress = api;

      # master configuration
      apiserver = lib.mkIf services.kubernetes.roles == "master" {
        advertiseAddress = master.ip;
      };

      # node configuration
      kubelet.kubeconfig.server = lib.mkIf services.kubernetes.roles == "node" api;
    };
  };
}
