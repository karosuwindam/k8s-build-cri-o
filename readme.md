CRI-Oを使用したKuberentetsの構築メモを残す

構築メモ

* VMware Playerのインストールについて

|ホスト名|CPU|Mem|ネットワーク|OS|
|--|--|--|--|--|
|host-pc|2|40GB|NAT+ブリッジ|Ubuntu 20.10|
|registory|2|20GB|NAT|Ubuntu 20.10|
|k8s-worker-1|2|20GB|NAT|Ubuntu 20.10|
|k8s-master-1|2|20GB|NAT|Ubuntu 20.10|


* IP設定

### ホスト別
|ホスト名|ブリッジ|NAT|
|--|--|--|
|host-pc|192.168.223.200/24|192.168.0.200/24|
|registory|192.168.223.201/24|-|
|k8s-master-1|192.168.223.210/24|-|
|k8s-worker-1|192.168.223.220/24|-|

### 共通設定
||Gateway|DNS|
|--|--|--|
|ブリッジ|192.168.0.1|192.168.0.1|
|NAT|192.168.223.2|192.168.223.2|


* 初回時の実行コマンド
```
sudo apt update && sudo apt upgrade -y && sudo apt install curl git ssh -y
```

* hosts設定
```:hosts

```