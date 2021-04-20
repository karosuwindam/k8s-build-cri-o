
nfsのセットアップ
```
sudo apt install nfs-kernel-server
```

nfsのエージェント導入
```
sudo apt install nfs-common
```

保存ディスクのフォルダの作成
```
sudo mkdir -p /var/nfs
sudo chmod 1777 /var/nfs/
for ((i=1; i < 10; i++)); do
sudo mkdir -p /var/nfs/pv$(printf %04d $i)
sudo chown nobody:nogroup /var/nfs/pv$(printf %04d $i)
done

sudo echo "/var/nfs 192.168.0.0/16(rw,async,no_root_squash) 127.0.0.1/32(rw,async,no_root_squash)" | sudo tee -a /etc/exports
sudo systemctl restart nfs-server rpcbind
sudo systemctl enable nfs-server rpcbind
```

## Kubernetesのセットアップ

nginxによる動作テスト

```
kubectl apply -f kubernetes/folder
kubectl apply -f nginx
```

nginxのpodには入って、`touch /home/test`のコマンドを実行すると
registory PCの/var/nfs/pv0001のフォルダ配下にtestのからファイルが存在する


kubernetesのテンプレートからpvファイルを作成
```
cd kubernetes/folder-temp
source create.sh  > ../nfs/nfs-create-pv.yaml
kubectl apply -f ../nfs/nfs-create-pv.yaml
```

