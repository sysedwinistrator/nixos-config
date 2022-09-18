{
  config,
  lib,
  pkgs,
  ...
}: let
  master = builtins.elemAt (builtins.filter (x: builtins.elem "master" x.kubernetes_roles) config.lab.all_hosts) 0;
  api = "https://${master.ip}:${builtins.toString config.services.kubernetes.apiserver.securePort}";
  is_master = builtins.elem "master" config.lab.current_host.kubernetes_roles;
  is_node = builtins.elem "node" config.lab.current_host.kubernetes_roles;
  fromYAMLString = yamlString: (fromYAML (builtins.toFile "from-yaml-string" yamlString));

  fromYAML = yamlFile:
    builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommandNoCC "from-yaml"
        {
          allowSubstitutes = false;
          preferLocalBuild = true;
        }
        ''
          ${pkgs.yq}/bin/yq -s < "${yamlFile}" > "$out"
        ''
      )
    );
  kuberouter_manifests_src = builtins.fetchurl "https://raw.githubusercontent.com/cloudnativelabs/kube-router/v1.5.1/daemonset/generic-kuberouter-all-features-advertise-routes.yaml";
  kuberouter_manifests_templated = pkgs.runCommand "kuberouter.yaml" {} ''
    sed ${kuberouter_manifests_src} -e "s;%APISERVER%;${api};g" -e "s;%CLUSTERCIDR%;${config.services.kubernetes.clusterCidr};g" > $out
  '';
  kuberouter_manifests_rendered = fromYAML kuberouter_manifests_templated;
  kuberouter_manifests_final = builtins.listToAttrs (builtins.map (resource: {
      name = "${resource.kind}-${resource.metadata.name}";
      value = resource;
    })
    kuberouter_manifests_rendered);
in {
  config = lib.mkIf (is_master || is_node) {
    fileSystems = lib.mkIf config.host.zfs {
      "/var/lib/containerd/io.containerd.snapshotter.v1.zfs" = {
        device = "${config.host.zfsDataSet}/containerd";
        fsType = "zfs";
        options = ["zfsutils"];
      };
      "/var/lib/etcd" = lib.mkIf is_master {
        device = "${config.host.zfsDataSet}/etcd";
        fsType = "zfs";
        options = ["zfsutils"];
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

      addonManager = lib.mkIf is_master {
        enable = true;
        bootstrapAddons = kuberouter_manifests_final;
      };
    };
    systemd.services = {
      etcd.environment = lib.mkIf is_master {
        ETCD_UNSUPPORTED_ARCH = "arm64";
      };
      kube-addon-manager.serviceConfig = lib.mkIf is_master {
        User = "root";
      };
    };
  };
}
