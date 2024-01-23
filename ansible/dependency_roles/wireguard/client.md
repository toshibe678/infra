# クライアントの設定ファイル例
```
[Interface]
PrivateKey = クライアント用PrivateKey(client_private.key)
Address = 192.168.101.11/24
DNS = 172.16.1.1 8.8.8.8

[Peer]
PublicKey = VPNサーバー用のPublicKey（server_public.key）
PresharedKey = クライアント用のpreshared-key(client_preshared.key)
EndPoint = home.toshi.click:51820
# AllowedIPsに0.0.0.0/0を指定することで、Web閲覧などのすべての通信をVPN経由にする
AllowedIPs = 0.0.0.0/0 
```

# QRコードの生成
```
# rasdev
mkdir -p /tmp/wireguard
qrencode -o /tmp/wireguard/rasdev.test_toshipc01.png -t png < /etc/wireguard/rasdev.test_toshipc01.conf
qrencode -o /tmp/wireguard/rasdev.test_toshipc02.png -t png < /etc/wireguard/rasdev.test_toshipc02.conf
qrencode -o /tmp/wireguard/rasdev.test_smartphone01.png -t png < /etc/wireguard/rasdev.test_smartphone01.conf
qrencode -o /tmp/wireguard/rasdev.test_smartphone02.png -t png < /etc/wireguard/rasdev.test_smartphone02.conf
qrencode -o /tmp/wireguard/rasdev.test_other01.png -t png < /etc/wireguard/rasdev.test_other01.conf
# raspi
mkdir -p /tmp/wireguard
qrencode -o /tmp/wireguard/raspi.test_toshipc01.png -t png < /etc/wireguard/raspi.test_toshipc01.conf
qrencode -o /tmp/wireguard/raspi.test_toshipc02.png -t png < /etc/wireguard/raspi.test_toshipc02.conf
qrencode -o /tmp/wireguard/raspi.test_smartphone01.png -t png < /etc/wireguard/raspi.test_smartphone01.conf
qrencode -o /tmp/wireguard/raspi.test_smartphone02.png -t png < /etc/wireguard/raspi.test_smartphone02.conf
qrencode -o /tmp/wireguard/raspi.test_other01.png -t png < /etc/wireguard/raspi.test_other01.conf
```


### linuxクライアントの設定
各サーバー用のconfファイルを転送
```
scp /etc/wireguard/vpn.toshi.click_mayu.conf toshi@mayu.test:/tmp
mv /tmp/vpn.toshi.click_mayu.conf /etc/wireguard/wg0.conf
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
```
