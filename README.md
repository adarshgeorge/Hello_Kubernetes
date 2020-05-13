
**Kubernetes Initial Setup for Master server and Worker Node**

```
#!/bin/bash
swapoff -a
yum install iptables-services.x86_64 -y
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl mask firewalld.service
systemctl start iptables
systemctl enable iptables
systemctl unmask iptables
iptables -F
service iptables save

yum install docker -y
systemctl enable docker && systemctl start docker

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable kubelet && systemctl start kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
```

**Now initialize the Master Node, replace the public IP**


```
kubeadm init --apiserver-advertise-address=199.127.62.9 --pod-network-cidr=10.244.0.0/16 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Now checking active node


```
[root@master ~]# kubectl get nodes
NAME                     STATUS     ROLES    AGE     VERSION
master.adamzgeorge.com   NotReady   master   3h26m   v1.18.2
[root@master ~]#
```
The status is not ready

**Now join the WorkerNode**


On Worker node1


```
kubeadm join 199.127.62.9:6443 --token 8fe7s3.hpl05o7o8x0o98ld \
    --discovery-token-ca-cert-hash sha256:4cd31240ae44451f31c2bb18237d8b9924c4a08c7ad2216900df56097a9c40c9
```

On Worker node2

```
kubeadm join 199.127.62.9:6443 --token 8fe7s3.hpl05o7o8x0o98ld \
    --discovery-token-ca-cert-hash sha256:4cd31240ae44451f31c2bb18237d8b9924c4a08c7ad2216900df56097a9c40c9
```

Now checking active node

```
[root@master ~]# kubectl get nodes
NAME                     STATUS     ROLES    AGE     VERSION
master.adamzgeorge.com   NotReady   master   3h50m   v1.18.2
node1.adamzgeorge.com    NotReady   <none>   8m10s   v1.18.2
node2.adamzgeorge.com    NotReady   <none>   13s     v1.18.2
[root@master ~]#

```

The status is not ready


Network Setup


One final step on the master node is to install Flannel. Run the following command.

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```