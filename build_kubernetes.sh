#!/bin/bash

K8S_VERSION=${K8S_VERSION:-1.2.0}
K8S_CLEAN_BUILD=${K8S_CLEAN_BUILD:-true}

if [[ "${K8S_CLEAN_BUILD}" != "false" ]]; then
  rm -rf kubernetes/source/kubernetes/v$K8S_VERSION
  rm -f kubernetes/master/kubernetes-master-$K8S_VERSION-1.x86_64.rpm
  rm -f kubernetes/master/kubernetes-node-$K8S_VERSION-1.x86_64.rpm
  rm -f kubernetes/master/kubernetes-master_$K8S_VERSION_amd64.deb
  rm -f kubernetes/master/kubernetes-node_$K8S_VERSION_amd64.deb
fi

mkdir -p kubernetes/source/kubernetes/v$K8S_VERSION
cd kubernetes/source/kubernetes/v$K8S_VERSION
curl -L -O https://storage.googleapis.com/kubernetes-release/release/v$K8S_VERSION/kubernetes.tar.gz -z kubernetes.tar.gz
tar -xvzf kubernetes.tar.gz
# Nightly
# https://github.com/GoogleCloudPlatform/kubernetes/releases/download/v$K8S_VERSION/kubernetes.tar.gz
tar xfvz kubernetes/server/kubernetes-server-linux-amd64.tar.gz
cd ../../../../

#build_deb_master

    # deb
    # /etc/init.d/
    # --deb-init FILEPATH           (deb only) Add FILEPATH as an init script
    # --deb-default FILEPATH        (deb only) Add FILEPATH as /etc/default configuration
    # --deb-upstart FILEPATH        (deb only) Add FILEPATH as an upstart script


fpm -s dir -n "kubernetes-master" \
-p kubernetes/builds \
-C ./kubernetes/master -v $K8S_VERSION \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--exclude .gitkeep \
--after-install kubernetes/master/scripts/deb/after-install.sh \
--before-install kubernetes/master/scripts/deb/before-install.sh \
--after-remove kubernetes/master/scripts/deb/after-remove.sh \
--before-remove kubernetes/master/scripts/deb/before-remove.sh \
--deb-init kubernetes/master/services/initd/kube-apiserver \
--deb-init kubernetes/master/services/initd/kube-controller-manager \
--deb-init kubernetes/master/services/initd/kube-scheduler \
--deb-default kubernetes/master/initd_config/kube-apiserver \
--deb-default kubernetes/master/initd_config/kube-controller-manager \
--deb-default kubernetes/master/initd_config/kube-scheduler \
--license "Apache Software License 2.0" \
--maintainer "Kismatic, Inc. <info@kismatic.com>" \
--vendor "Kismatic, Inc." \
--description "Kubernetes master binaries and services" \
--url "https://www.kismatic.com" \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-apiserver=/usr/bin/kube-apiserver \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-controller-manager=/usr/bin/kube-controller-manager \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-scheduler=/usr/bin/kube-scheduler \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubectl=/usr/bin/kubectl \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/hyperkube=/usr/bin/hyperkube \
etc/kubernetes/manifests

mkdir -p kubernetes/builds/systemd

# systemd version
fpm -s dir -n "kubernetes-master" \
-p kubernetes/builds/systemd \
-C ./kubernetes/master -v "$K8S_VERSION~systemd" \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--exclude .gitkeep \
--after-install kubernetes/master/scripts/deb/systemd/after-install.sh \
--before-install kubernetes/master/scripts/deb/systemd/before-install.sh \
--after-remove kubernetes/master/scripts/deb/systemd/after-remove.sh \
--before-remove kubernetes/master/scripts/deb/systemd/before-remove.sh \
--license "Apache Software License 2.0" \
--maintainer "Kismatic, Inc. <info@kismatic.com>" \
--vendor "Kismatic, Inc." \
--description "Kubernetes master binaries and services" \
--url "https://www.kismatic.com" \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-apiserver=/usr/bin/kube-apiserver \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-controller-manager=/usr/bin/kube-controller-manager \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-scheduler=/usr/bin/kube-scheduler \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubectl=/usr/bin/kubectl \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/hyperkube=/usr/bin/hyperkube \
services/systemd/kube-apiserver.service=/lib/systemd/system/kube-apiserver.service \
services/systemd/kube-controller-manager.service=/lib/systemd/system/kube-controller-manager.service \
services/systemd/kube-scheduler.service=/lib/systemd/system/kube-scheduler.service \
etc/kubernetes/master/apiserver.conf \
etc/kubernetes/master/config.conf \
etc/kubernetes/master/controller-manager.conf \
etc/kubernetes/master/scheduler.conf \
etc/kubernetes/manifests


# post launch script for addons
# skydns enable
# Kubernetes installs do not configure the nodes' resolv.conf files to use the cluster DNS by default, because that process is inherently environment-specific.
# This should probably be implemented eventually.

#build_deb_node

# services
# deps etcd, docker (etcd.service, docker.service)
# kube-proxy.service
# kube-kubelet.service
# cadvisor.service?

# TODO later
# /var/lib/kubelet/kubernetes_auth
# {"BearerToken": "SF839TwEqeyO2mwbOtQMZFJ8nQIu7asb", "Insecure": true }
fpm -s dir -n "kubernetes-node" \
-p kubernetes/builds \
-C ./kubernetes/node -v $K8S_VERSION \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--exclude .gitkeep \
--after-install kubernetes/node/scripts/deb/after-install.sh \
--before-install kubernetes/node/scripts/deb/before-install.sh \
--after-remove kubernetes/node/scripts/deb/after-remove.sh \
--before-remove kubernetes/node/scripts/deb/before-remove.sh \
--deb-default kubernetes/node/initd_config/kubelet \
--deb-default kubernetes/node/initd_config/kube-proxy \
--deb-init kubernetes/node/services/initd/kubelet \
--deb-init kubernetes/node/services/initd/kube-proxy \
--license "Apache Software License 2.0" \
--maintainer "Kismatic, Inc. <info@kismatic.com>" \
--vendor "Kismatic, Inc." \
--description "Kubernetes node binaries and services" \
--url "https://www.kismatic.com" \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubelet=/usr/bin/kubelet \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-proxy=/usr/bin/kube-proxy \
etc/kubernetes/manifests


# systemd version
fpm -s dir -n "kubernetes-node" \
-p kubernetes/builds/systemd \
-C ./kubernetes/node -v "$K8S_VERSION~systemd" \
-t deb \
-a amd64 \
-d "dpkg (>= 1.17)" \
--exclude .gitkeep \
--after-install kubernetes/node/scripts/deb/systemd/after-install.sh \
--before-install kubernetes/node/scripts/deb/systemd/before-install.sh \
--after-remove kubernetes/node/scripts/deb/systemd/after-remove.sh \
--before-remove kubernetes/node/scripts/deb/systemd/before-remove.sh \
--config-files etc/kubernetes/node \
--license "Apache Software License 2.0" \
--maintainer "Kismatic, Inc. <info@kismatic.com>" \
--vendor "Kismatic, Inc." \
--description "Kubernetes node binaries and services" \
--url "https://www.kismatic.com" \
etc/kubernetes/node/config.conf \
etc/kubernetes/node/kubelet.conf \
etc/kubernetes/node/kube-proxy.conf \
services/systemd/kubelet.service=/lib/systemd/system/kubelet.service \
services/systemd/kube-proxy.service=/lib/systemd/system/kube-proxy.service \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubelet=/usr/bin/kubelet \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-proxy=/usr/bin/kube-proxy \
etc/kubernetes/manifests

# build_rpm_master
    # rpm
    # /lib/systemd/system

fpm -s dir -n "kubernetes-master" \
-p kubernetes/builds \
-C ./kubernetes/master -v $K8S_VERSION \
-d 'docker-engine >= 1.7.0' \
-t rpm --rpm-os linux \
--exclude .gitkeep \
-a x86_64 \
--after-install kubernetes/master/scripts/rpm/after-install.sh \
--before-install kubernetes/master/scripts/rpm/before-install.sh \
--after-remove kubernetes/master/scripts/rpm/after-remove.sh \
--before-remove kubernetes/master/scripts/rpm/before-remove.sh \
--config-files etc/kubernetes/master \
--license "Apache Software License 2.0" \
--maintainer "Kismatic, Inc. <info@kismatic.com>" \
--vendor "Kismatic, Inc." \
--description "Kubernetes master binaries and services" \
--url "https://www.kismatic.com" \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-apiserver=/usr/bin/kube-apiserver \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-controller-manager=/usr/bin/kube-controller-manager \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-scheduler=/usr/bin/kube-scheduler \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubectl=/usr/bin/kubectl \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/hyperkube=/usr/bin/hyperkube \
services/systemd/kube-apiserver.service=/lib/systemd/system/kube-apiserver.service \
services/systemd/kube-controller-manager.service=/lib/systemd/system/kube-controller-manager.service \
services/systemd/kube-scheduler.service=/lib/systemd/system/kube-scheduler.service \
etc/kubernetes/master/apiserver.conf \
etc/kubernetes/master/config.conf \
etc/kubernetes/master/controller-manager.conf \
etc/kubernetes/master/scheduler.conf \
etc/kubernetes/manifests


fpm -s dir -n "kubernetes-node" \
-p kubernetes/builds \
-C ./kubernetes/node -v $K8S_VERSION \
-d 'docker-engine >= 1.7.0' \
-a x86_64 \
-t rpm --rpm-os linux \
--exclude .gitkeep \
--after-install kubernetes/node/scripts/rpm/after-install.sh \
--before-install kubernetes/node/scripts/rpm/before-install.sh \
--after-remove kubernetes/node/scripts/rpm/after-remove.sh \
--before-remove kubernetes/node/scripts/rpm/before-remove.sh \
--config-files etc/kubernetes/node \
--license "Apache Software License 2.0" \
--maintainer "Kismatic, Inc. <info@kismatic.com>" \
--vendor "Kismatic, Inc." \
--description "Kubernetes node binaries and services" \
--url "https://www.kismatic.com" \
etc/kubernetes/node/config.conf \
etc/kubernetes/node/kubelet.conf \
etc/kubernetes/node/kube-proxy.conf \
services/systemd/kubelet.service=/lib/systemd/system/kubelet.service \
services/systemd/kube-proxy.service=/lib/systemd/system/kube-proxy.service \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kubelet=/usr/bin/kubelet \
../source/kubernetes/v$K8S_VERSION/kubernetes/server/bin/kube-proxy=/usr/bin/kube-proxy \
etc/kubernetes/manifests
