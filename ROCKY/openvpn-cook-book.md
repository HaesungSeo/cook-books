
# 목표
openvpn 을 리눅스 서버(ubuntu 24.04 LTS) 에 설치하고 <br>
윈도우 클라이언트에서 접속햅자.

# server 설치
OS: ubuntu 24.04 LTS

설치
```
sudo apt update
sudo apt install openvpn easy-rsa -y
```

## 초기화

참고: https://ubuntu.com/server/docs/how-to-install-and-use-openvpn <br>
이하 키 생성은 root 로 실행한다. <br>
클라이언트 키는 실제 vpn 서버로 접속할 클라이언트를 위해 필요하다. 일반 계정에서 키를 생성한다. <br>

### PKI 키 생성 (as root)


#### Certificate Authority (CA) 설정 (as root)
```
sudo make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
./easyrsa init-pki
./easyrsa build-ca nopass
```

실행예) <br>
중간에 Common Name 을 묻는데 'hsseo-vpn-ca' 로 입력하였다.
```
root@ip-172-31-12-169:/etc/openvpn/easy-rsa# ./easyrsa build-ca nopass
Using Easy-RSA 'vars' configuration:
* /etc/openvpn/easy-rsa/vars

Using SSL:
* openssl OpenSSL 3.0.13 30 Jan 2024 (Library: OpenSSL 3.0.13 30 Jan 2024)
.....+.....+.+........+.+.........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*..+...+...+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.+..+......+.........+...............+...+.+...........+................+...+...........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
..+...........+..........+...........+.+..+.......+...+.....+.+..+.......+...+.....+...+....+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*...+..+.+........+....+..+..........+.....+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*......+...+.........+.......+...+...+..+.+............+.................+......+....+..+....+.........+..+....+.........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:hsseo-vpn-ca

Notice
------
CA creation complete. Your new CA certificate is at:
* /etc/openvpn/easy-rsa/pki/ca.crt

root@ip-172-31-12-169:/etc/openvpn/easy-rsa#
```


### 서버(hsseo-vpn) 키 생성

```
cd /etc/openvpn/easy-rsa
./easyrsa gen-req hsseo-vpn nopass
./easyrsa gen-dh
./easyrsa sign-req server hsseo-vpn
sudo openvpn --genkey --secret ta.key
```
./easyrsa gen-dh 명령은 실행이 오래 걸림을 참고한다. <br>

실행예) <br>
중간에 Common Name 을 묻는데 'hsseo-vpn' 으로 입력하였다.
```
root@ip-172-31-12-169:/etc/openvpn/easy-rsa# ./easyrsa gen-req hsseo-vpn nopass
Using Easy-RSA 'vars' configuration:
* /etc/openvpn/easy-rsa/vars

Using SSL:
* openssl OpenSSL 3.0.13 30 Jan 2024 (Library: OpenSSL 3.0.13 30 Jan 2024)
.+.+.....+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*..+........+.+.....+.+..+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*............+.............+.....+.+..+...................+.......................+......+......+...+...+.........+.+...............+...+.....+.......+.....+.............+.....+.........+......+.......+.........+.....+..........+.....+..........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
..+.........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*..+.+.........+.................+......+....+.....+.+.....+.......+..+....+.....+......+...+...+.............+......+..............+.+.....+...+.+.....+.......+..+.+..+.........+......+...+.....................+...+.....................+.+......+...+.....+....+...........+.......+..+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.....+...+..+.+..+...+..........+............+..+..........+.....+....+.....+.+...+...+........+....+.....+......+.......+.....+..........+..............+.+.....+.........+...+.+..+.......+.....+......+.......+..+...+....+.....+...+.......+.....+...+.+.........+..+...................+..+.........+..........+...+......+..+....+...+.....+.+..+..................+.+......+..............+..........+..............+.......+..+............+....+......+...+............+.....+.+........+.+......+........+.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [hsseo-vpn]:hsseo-vpn

Notice
------
Private-Key and Public-Certificate-Request files created.
Your files are:
* req: /etc/openvpn/easy-rsa/pki/reqs/hsseo-vpn.req
* key: /etc/openvpn/easy-rsa/pki/private/hsseo-vpn.key

root@ip-172-31-12-169:/etc/openvpn/easy-rsa#
```

생성된 서버키 복사
```
cp -dpRf pki/dh.pem pki/ca.crt pki/issued/hsseo-vpn.crt pki/private/hsseo-vpn.key /etc/openvpn/
```


#### https://hiteit.tistory.com/5


#### 서버(hsseo-vpn) 설정

아래 파일을 참고하여 /etc/openvpn/hsseo-vpn.conf 파일을 작성한다.
```
/usr/share/doc/openvpn/examples/sample-config-files/server.conf
```

수정사항 예)
```
root@ip-172-31-12-169:/etc/openvpn# diff -Naur server.conf hsseo-vpn.conf
--- server.conf	2024-12-17 14:01:29.719281736 +0900
+++ hsseo-vpn.conf	2024-12-17 14:13:42.542956840 +0900
@@ -29,11 +29,11 @@
 # on the same machine, use a different port
 # number for each one.  You will need to
 # open up this port on your firewall.
-port 1194
+port 443

 # TCP or UDP server?
-;proto tcp
-proto udp
+proto tcp
+;proto udp

 # "dev tun" will create a routed IP tunnel,
 # "dev tap" will create an ethernet tunnel.
@@ -84,13 +84,13 @@
 # See openvpn-examples man page for a
 # configuration example.
 ca ca.crt
-cert server.crt
-key server.key  # This file should be kept secret
+cert hsseo-vpn.crt
+key hsseo-vpn.key  # This file should be kept secret

 # Diffie hellman parameters.
 # Generate your own with:
 #   openssl dhparam -out dh2048.pem 2048
-dh dh2048.pem
+dh dh.pem

 # Allow to connect to really old OpenVPN versions
 # without AEAD support (OpenVPN 2.3.x or older)
@@ -307,4 +307,4 @@

 # Notify the client that when the server restarts so it
 # can automatically reconnect.
-explicit-exit-notify 1
\ No newline at end of file
+explicit-exit-notify 1
root@ip-172-31-12-169:/etc/openvpn#
```
- 포트는 1194 에서 443 으로 변경
- 프로토콜은 UDP 에서 TCP 로 변경
- 키파일 변경


```
cd /etc/openvpn
sudo openvpn --genkey --secret ta.key
```


### 서버(hsseo-vpn) 실행

아래 명령어로 openvpn 서버를 하나 실행하고 상태를 확인한다.
```
sudo systemctl start openvpn@hsseo-vpn.service
sudo systemctl status openvpn@hsseo-vpn.service
```

실행예)
```
root@ip-172-31-12-169:~# sudo systemctl status openvpn@hsseo-vpn.service
● openvpn@hsseo-vpn.service - OpenVPN connection to hsseo-vpn
     Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled-runtime; preset: enabled)
     Active: active (running) since Wed 2024-12-18 15:15:06 KST; 2min 0s ago
       Docs: man:openvpn(8)
             https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage
             https://community.openvpn.net/openvpn/wiki/HOWTO
   Main PID: 20365 (openvpn)
     Status: "Initialization Sequence Completed"
      Tasks: 1 (limit: 10)
     Memory: 1.4M (peak: 1.7M)
        CPU: 21ms
     CGroup: /system.slice/system-openvpn.slice/openvpn@hsseo-vpn.service
             └─20365 /usr/sbin/openvpn --daemon ovpn-hsseo-vpn --status /run/openvpn/hsseo-vpn.status 10 --cd /etc/openvpn --script-security 2 --config /etc/openvpn/hsseo-vpn.conf --writepid /run/openvpn/hsseo-vpn.pid

Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: Could not determine IPv4/IPv6 protocol. Using AF_INET
Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: Socket Buffers: R=[131072->131072] S=[16384->16384]
Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: Listening for incoming TCP connection on [AF_INET][undef]:443
Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: TCPv4_SERVER link local (bound): [AF_INET][undef]:443
Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: TCPv4_SERVER link remote: [AF_UNSPEC]
Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: MULTI: multi_init called, r=256 v=256
Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: IFCONFIG POOL IPv4: base=10.8.0.2 size=253
Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: IFCONFIG POOL LIST
Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: MULTI: TCP INIT maxclients=1024 maxevents=1029
Dec 18 15:15:06 ip-172-31-12-169 ovpn-hsseo-vpn[20365]: Initialization Sequence Completed
root@ip-172-31-12-169:~#
```

정상적으로 실행되었다면 아래와 같이 443 포트에서 클라이언트를 기다리고 있다.
```
root@ip-172-31-12-169:~# netstat -lnptua
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN      15600/systemd-resol
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      20365/openvpn        # hsseo-vpn 서버
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      15600/systemd-resol
tcp6       0      0 :::22                   :::*                    LISTEN      1/systemd
tcp6       0    152 172.31.12.169:22        218.36.252.5:63261      ESTABLISHED 19655/sshd: ubuntu
udp        0      0 127.0.0.1:323           0.0.0.0:*                           7016/chronyd
udp        0      0 127.0.0.54:53           0.0.0.0:*                           15600/systemd-resol
udp        0      0 127.0.0.53:53           0.0.0.0:*                           15600/systemd-resol
udp        0      0 172.31.12.169:68        0.0.0.0:*                           15623/systemd-netwo
udp6       0      0 ::1:323                 :::*                                7016/chronyd
root@ip-172-31-12-169:~#
```

### 클라이언트 키 생성

openvpn 은 접속할 클라이언트 마다 클라이언트 키를 생성한후 <br>
클라이언트에서 만들어진 클라이언트 키를 이용하여 서버에 접속해야 한다. <br>
처음 PKI 키를 만들었던 디렉토리에서 아래 작업을 수행한다. 
```
cd /etc/openvpn/easy-rsa
./easyrsa gen-req hsseo-office nopass
./easyrsa sign-req client hsseo-office
```


### 클라이언트 프로그램 설치

openvpn 은 윈도우 클라이언트를 제공한다. <br>
https://openvpn.net/client/client-connect-vpn-for-windows/


#### 클라이언트 프로파일 작성

openvpn connect 에서 사용할 .ovpn 파일을 작성한다.
```
client
auth-user-pass
dev tun
resolv-retry infinite

persist-key
persist-tun

ns-cert-type server
verb 3

route-metric 1

proto tcp

<ca>
</ca>

<cert>
</cert>

<key>
</key>

remote 3.35.48.13 443
```
<ca>, <cert>, <key> 항목은 앞에서 생성한 클라이언트 키 파일의 내용을 그대로 입력하면 된다. <br>


## 클라이언트의 모든 인터넷 트래픽을 vpn 을 거치도록 설정

### 서버 설정

#### 서버 트래픽 설정

클라이언트의 트래픽이 NAT 를 거쳐 인터넷으로 나가도록 설정한다. <br>
```
# sudo iptables -t nat -A POSTROUTING -s <VPN_SUBNET> -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o enX0 -j MASQUERADE
```

해당 설정이 리부팅시에도 적용되도록 아래를 실행한다
```
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

#### 서버 openvpn 데몬 설정

/etc/openvpn/hsseo-vpn.conf 파일에 아래 설정을 추가한다.
```
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
```

변경된 설정이 적용되도록 한다.
```
sudo systemctl restart openvpn@hsseo-vpn.service
sudo systemctl status openvpn@hsseo-vpn.service
```

### 클라이언트 설정

#### 클라이언트 프로파일 수정

openvpn connect 에서 사용할 .ovpn 파일에 다음 내용을 추가한다.
```
pull
```
