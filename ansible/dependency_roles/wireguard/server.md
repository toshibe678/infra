# サーバー側での作業
このファイル内のキーの値は改変しているので実際とは違う
# サーバー用プライベートキー作成
```
root:~# wg genkey | tee /etc/wireguard/server.key
gCS9F2qcHIPyacpLd4z7wAqbXuaz99ts1RCDxP1ym3Y=
```
# サーバー用パブリックキー作成
```
root:~# cat /etc/wireguard/server.key | wg pubkey | tee /etc/wireguard/server.pub
ZLyTvWsPlly4vmqqLwXcQ19qE1xgBWGHb0+nd8RiSiM=
```
# クライアント用プライベートキー作成
```
root:~# wg genkey | tee /etc/wireguard/client.key
MDuvBHt99FI1jetfTCHqB1rmOTJRtPI9Xnu+FTk29m0=
```
# クライアント用パブリックキー作成
```
root:~# cat /etc/wireguard/client.key | wg pubkey | tee /etc/wireguard/client.pub
K03BktxiXod16UCF1zx8KfXu5Uhfd4IAGefrB9TkUAg=
``` 
# クライアント用preshared-key(事前共有鍵）作成
```
root:~# wg genkey | tee /etc/wireguard/client_preshared.key
MDuvBHt99FI1jetfTCHqB1rmOTJRtPI9Xnu+FTk29m0=
```
