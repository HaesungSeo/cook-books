<H1>ssh cook book</H1>

- [오래된 ssh client 에서 접속하지 못하는 문제](#오래된-ssh-client-에서-접속하지-못하는-문제)

# 오래된 ssh client 에서 접속하지 못하는 문제

XShell5 와 같은 프로그램에서 ssh publickey 인증시도시 아래와 같이 접속이 되지 않는 경우가 있다.
```
Connecting to 192.168.0.1:22...
Connection established.
To escape to local shell, press 'Ctrl+Alt+]'.
[14:03:45] Version exchange initiated...
[14:03:45] 	server: SSH-2.0-OpenSSH_8.9p1 Ubuntu-3ubuntu0.7
[14:03:45] 	client: SSH-2.0-nsssh2_5.0.0045 NetSarang Computer, Inc.
[14:03:45] 	SSH2 is selected.
[14:03:45] 		Outgoing packet message id: 20, length: 1533
[14:03:45] 		Incoming packet message id: 20
[14:03:45] Algorithm negotiation initiated... (Dialog mode)
[14:03:45] 	key exchange: ecdh-sha2-nistp256
[14:03:45] 	host key: ecdsa-sha2-nistp256
[14:03:45] 	outgoing encryption: aes256-gcm@openssh.com
[14:03:45] 	incoming encryption: aes256-gcm@openssh.com
[14:03:45] 	outgoing mac: hmac-sha1
[14:03:45] 	incoming mac: hmac-sha1
[14:03:45] 	outgoing compression: none
[14:03:45] 	incoming compression: none
[14:03:45] 		Outgoing packet message id: 30, length: 70
[14:03:45] 		Incoming packet message id: 31
[14:03:45] Host authentication initiated...
[14:03:45] 	Hostkey fingerprint:
[14:03:45] 	ssh-ecdsa 256 e8:ff:b7:ad:42:4a:01:5c:0c:03:35:94:a7:24:4d:eb
[14:03:45] 	Accepted. Verifying host key...
[14:03:45] 	Verified.
[14:03:45] 		Outgoing packet message id: 21, length: 1
[14:03:45] 		Incoming packet message id: 21
[14:03:45] 		Outgoing packet message id: 5, length: 17
[14:03:45] 		Incoming packet message id: 6
[14:03:45] User authentication initiated... (Dialog mode)
[14:03:45] 	Sent user name 'ubuntu'.
[14:03:45] 		Outgoing packet message id: 50, length: 37
[14:03:45] 		Incoming packet message id: 51
[14:03:45] 		Outgoing packet message id: 50, length: 337
[14:03:45] 	Sent public key blob.
[14:03:45] 		Incoming packet message id: 51
[14:03:45] 	Server rejected the public blob.
[14:04:09] 	Canceled.
[14:04:09] 		Outgoing packet message id: 1, length: 13
Connection closing...Socket close.
```

AWS 의 AMI 이미지의 경우는 아래와 같은 조치가 필요하다.
```
update-crypto-policies --show; 
update-crypto-policies --set LEGACY; 
systemctl restart sshd
```

ubuntu 이미지는 아래와 같이 조치해도 됨
```
cat<<EOM | sudo tee -a /etc/ssh/sshd_config
PubkeyAcceptedKeyTypes +ssh-rsa
EOM
sudo systemctl restart ssh
```
