CRI-Oを使用したKuberentetsの構築メモを残す

構築メモ

* VMware Playerのインストールについて

|ホスト名|CPU|Mem|ネットワーク|OS|
|--|--|--|--|--|
|host-pc|2|40GB|NAT+ブリッジ|Ubuntu 20.10|
|registory|2|20GB|NAT|Ubuntu 20.10|
|k8s-worker-01|2|20GB|NAT|Ubuntu 20.10|
|k8s-master-1|2|20GB|NAT|Ubuntu 20.10|


* IP設定

### ホスト別
|ホスト名|ブリッジ|NAT|
|--|--|--|
|host-pc|192.168.223.200/24|192.168.0.200/24|
|registory|192.168.223.201/24|-|
|k8s-master-1|192.168.223.210/24|-|
|k8s-worker-01|192.168.223.220/24|-|

### 共通設定
||Gateway|DNS|
|--|--|--|
|ブリッジ|192.168.0.1|192.168.0.1|
|NAT|192.168.223.2|192.168.223.2|


* 初回時の実行コマンド

すべてのHOSTで実行する

```
sudo apt update && sudo apt upgrade -y && sudo apt install curl git ssh -y
```

# 個別作業前準備
* host-pc

ssh-key交換
```
ssh-keygen
ssh-copy-id karosu@host-pc.local
ssh-copy-id karosu@registory.local
ssh-copy-id karosu@k8s-master-1.local
ssh-copy-id karosu@k8s-worker-01.local
```

hostsファイルの追加
```
sudo sh -c "cat <<EOF >>/etc/hosts

192.168.223.200 host-pc
192.168.223.201 registory
192.168.223.210 k8s-master-1
192.168.223.220 k8s-worker-01
EOF
"
```


# 作業メモ

## hot-pc

dockerのインストール
```
sudo apt install docker
```

kubectlコマンドのインストール
```
sudo sh -c "curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo apt-key add -"
sudo sh -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kube.list'
sudo apt update
sudo apt install -y kubectl
```

## registory

dockerのインストール
```
sudo apt install docker
```

## k8s-master-1

cri-oのインストール
```
sudo modprobe overlay
sudo modprobe br_netfilter

sudo sh -c "cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
"

sudo sh -c "cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
"
sudo sysctl --system

sudo sh -c 'echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.10/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list'
sudo sh -c 'echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.21/xUbuntu_20.10/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:1.21.list'

sudo sh -c 'curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:1.21/xUbuntu_20.10/Release.key | apt-key add -'
sudo sh -c 'curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_20.10/Release.key | apt-key add -'

sudo apt-get update
sudo apt-get install cri-o cri-o-runc

sudo systemctl daemon-reload
sudo systemctl start crio -y
```

swapをOFFにする
```
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```
kubeコマンドのインストール
```
sudo sh -c "curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo apt-key add -"
sudo sh -c 'echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kube.list'
sudo apt update
sudo apt install -y kubelet kubectl kubeadm
```

cri-o用のkubelet設定ファイルを適応
```
sudo wget -O /etc/default/kubelet https://gist.githubusercontent.com/haircommander/2c07cc23887fa7c7f083dc61c7ef5791/raw/73e3d27dcd57e7de237c08758f76e0a368547648/cri-o-kubeadm
```

kubernetesの初期化
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

joinを調べるスクリプト
```
echo sudo kubeadm join $(hostname -I|awk '{print $1}'):6443 --token $(kubeadm token list |sed -n 2P|awk '{print $1}') --discovery-token-ca-cert-hash sha256:$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
```

## k8s-worker-01

```
sudo kubeadm join 192.168.223.210:6443 --token roodeq.5e15i0m9qgnox7k5 --discovery-token-ca-cert-hash sha256:c954f1bb27a4a085b5a1c3bf1ef60569e0226fba309fbe350d4bb660abbd817b
```

## kuberentes構築後

flannelのインストール
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

