#!/bin/bash
# Script to install Microk8s on ubuntu
echo "***********************************************************************"
echo "Started installMicrok8s.sh"
echo "***********************************************************************"

export MICROK8S_CHANNEL=${MICROK8S_CHANNEL:-"1.19/stable"}
export USER=${USER:-"ubuntu"}

# Wrapper for runnig commands for the real owner and not as root
# thanks to keptn-in-a-box for this script which i have copied most of the commands from!

alias bashas="sudo -H -u ${USER} bash -c"
# Expand aliases for non-interactive shell
shopt -s expand_aliases

echo "Installing microk8s version: $MICROK8S_CHANNEL"
sudo snap install microk8s --classic --channel=$MICROK8S_CHANNEL

echo "allowing the execution of priviledge pods"
bash -c "echo \"--allow-privileged=true\" >> /var/snap/microk8s/current/args/kube-apiserver"

echo "Enable microk8s for user. User is $USER"
usermod -a -G microk8s $USER

#iptables -P FORWARD ACCEPT
#ufw allow in on cni0 && sudo ufw allow out on cni0
#ufw default allow routed

echo "Enable alias microk8s.kubectl kubectl"
snap alias microk8s.kubectl kubectl
echo "Add Snap to the system wide environment."
sed -i 's~/usr/bin:~/usr/bin:/snap/bin:~g' /etc/environment

homedirectory=$(eval echo ~$USER)
echo "homedirectory is $homedirectory"

bashas "mkdir $homedirectory/.kube"
bashas "microk8s.config > $homedirectory/.kube/config"


echo "Start MicroK8S"
microk8s.start
echo "Enable MicroK8S DNS"
microk8s.enable dns
echo "Enable MicroK8S Storage"
microk8s.enable storage
echo "Enable MicroK8S Ingress"
microk8s.enable ingress

echo "***********************************************************************"
echo "Finished installMicrok8s.sh"
echo "***********************************************************************"