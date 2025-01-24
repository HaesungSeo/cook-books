# rocky vnc 서버 설치

## 설치

https://www.tecmint.com/install-and-configure-vnc-server-in-centos-7/

```
yum install -y tigervnc-server
```

## 설정

### /etc/systemd/system/vncserver@:<n>.service 작성

/lib/systemd/system/vncserver@.service <br>
파일을 적당히 아래와 같이 @:x 파일로 변경한다. <br>
서버의 vnc 서비스를 위해 포트 5900+x 를 사용한다는 의미이다. <br>
아래의 경우는 5910 포트를 사용한다.<br>
```
cp /lib/systemd/system/vncserver@.service \
   /etc/systemd/system/vncserver@:10.service
```

### vncpasswd 실행

vnc 로 로그인할 계정으로 로그인한 후 아래 명령을 실행하여 vnc 에서 사용할 password 를 설정한다.
```
vncpasswd
```

실행예)<br>
view-only password 로 사용할 거냐는 질문에는 'n' 로 입력한다.<br>
```
[suser@dcache01 ~]$ vncpasswd
Password:
Verify:
Would you like to enter a view-only password (y/n)? n
A view-only password is not used
[suser@dcache01 ~]$
```

### /etc/tigervnc/vncserver.users 작성

위 접속포트 <n> 과 위 vncpasswd 를 실행한 사용자 계정을 조합하여 아래와 같이 추가한다.<br>
```
[root@dcache01 ~]# cat /etc/tigervnc/vncserver.users
# TigerVNC User assignment
#
# This file assigns users to specific VNC display numbers.
# The syntax is <display>=<username>. E.g.:
#
# :2=andrew
# :3=lisa
:10=suser
[root@dcache01 ~]#
```

### 방화벽 규칙 추가

위 vnc 포트를 방화벽 허용 규칙에 추가한다.
```
firewall-cmd --zone=public --add-port=5910/tcp
#firewall-cmd --zone=public --remove-port=5910/tcp
```

vnc 클라이언트로 접속이 성공하면 리부팅때도 반영되도록 아래 규칙을 추가한다.
```
firewall-cmd --permanent --zone=public --add-port=5910/tcp
#firewall-cmd --permanent --zone=public --remove-port=5910/tcp
```

## 실행


작성한 서비스를 시작하고 접속을 확인한다.
```
systemctl daemon-reload
systemctl stop vncserver@:10.service
systemctl start vncserver@:10.service
systemctl status vncserver@:10.service
systemctl enable vncserver@:10.service
```

