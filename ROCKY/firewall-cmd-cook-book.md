# firewall-cmd 

## firewalld 상태 확인 (간략버전)

```
firewall-cmd --get-active-zone
```

public 과 trusted 를 사용하는 것이 일반적이다.
```
firewall-cmd --zone=public --list-all
firewall-cmd --zone=trusted --list-all
```

zone 에 서비스 확인
```
for zn in public trusted; do
  for svc in $(firewall-cmd --zone=$zn --list-services); do
    echo "PORTS in $svc / ZONE $zn"
    firewall-cmd --service=$svc --get-ports --permanent
  done
done
```

## zone 

zone 확인 명령어
```
firewall-cmd --list-all-zone
firewall-cmd --list-all-zone --permanent
firewall-cmd --get-zones
firewall-cmd --get-zones --permanent
```

기본 zone 확인
```
firewall-cmd --get-default-zone
```

특정 zone의 configuration 확인
```
firewall-cmd --zone=public --list-all
firewall-cmd --zone=public --list-all --permanent
firewall-cmd --zone=trusted --list-all
firewall-cmd --zone=trusted  --list-all --permanent
```

zone 에 서비스 추가/삭제/확인 확인
```
firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --zone=public --remove-service=ssh --permanent
firewall-cmd --zone=public --list-services --permanent
```

zone에 포트 추가/삭제/확인

```
firewall-cmd --zone=public --add-port=8080/tcp
firewall-cmd --zone=public --remove-port=8080/tcp
firewall-cmd --zone=public --list-ports

firewall-cmd --permanent --zone=public --add-port=8080/tcp
firewall-cmd --permanent --zone=public --remove-port=8080/tcp
firewall-cmd --permanent --zone=public --list-ports
```

## service 

service 목록 조회
```
firewall-cmd --get-services
```

service 서비스에 포트 추가/삭제/확인 <br>
--permanent 옵션을 꼭 붙여줘야 한다.
```
firewall-cmd --permanent --service=ssh --add-port=10000/tcp
firewall-cmd --permanent --service=ssh --remove-port=10000/tcp
firewall-cmd --permanent --service=ssh --get-ports
```

## permanent rule 로딩
--permanent 옵션을 붙인 경우, 바로 적용하려면 아래처럼 한다.
```
firewall-cmd --reload
```

## usecase

### 특정 IP 대역만 SSH 접속 허용하기

특정 IP 대역만 접속을 허용하는 규칙은 trusted zone 을 이용한다. <br>

ssh 서비스 zone 변경:  trusted zone 으로 옮기고 <br>
ssh 포트 변경:  22 -> 22222 <br>
```
firewall-cmd --permanent --service=ssh --remove-port=22/tcp
firewall-cmd --permanent --service=ssh --add-port=22222/tcp
semanage port -a -t ssh_port_t -p tcp 22222
sed -i 's/Port [0-9]\+/Port 22222/g' /etc/ssh/sshd_config
```

확인
```
firewall-cmd --permanent --service=ssh --get-ports
```

ssh 를 public -> trusted 로, 접속허용은 218.36.252.2/24 에서만 허용
```
firewall-cmd --permanent --zone=public  --remove-service=ssh
firewall-cmd --permanent --zone=trusted --add-service=ssh
firewall-cmd --permanent --zone=trusted --add-source=218.36.252.2/24
```

확인
```
firewall-cmd --permanent --zone=public  --list-services
firewall-cmd --permanent --zone=trusted --list-services
firewall-cmd --permanent --zone=public  --list-all
firewall-cmd --permanent --zone=trusted --list-all
```

복구
```
firewall-cmd --zone=public --add-service=ssh --permanent
firewall-cmd --zone=public --list-services --permanent
```

## direct 룰 설정

firewall 자체로는 입력에 한계가 존재한다. iptables rule을 RAW 하게 집어넣고 확인할 수도 있다. <br>

direct 룰 확인
```
firewall-cmd --direct --get-all-rules
firewall-cmd --permanent --direct --get-all-rules
```

direct 룰 입력 (사설대역 접속허용)
```
firewall-cmd --permanent --direct --add-rule \
   ipv4 filter IN_public_allow 0 \
  -p tcp --source 192.168.0.0/16 --dport 22 \
  -m state --state NEW,UNTRACKED \
  -j ACCEPT
```

direct 룰 삭제
```
firewall-cmd --permanent --direct --remove-rule \
   ipv4 filter IN_public_allow 0 \
  -p tcp --source 192.168.0.0/16 --dport 22 \
  -m state --state NEW,UNTRACKED \
  -j ACCEPT
```

## 포트포워딩(port forwarding)

환경<br>
INTERNAL_NET=192.168.122.0/24 <br>
vm 에서 인터넷 접속은 host 의 NAT 를 이용하기 <br>
네트워크 연결: 외부 -- (eth0 - br0) 호스트 (br1 -- vm-eth0) vm <br>
```
HOST_IF=br0
HOST_IP=192.168.6.66
HOST_PORT=22010
VM_NET=192.168.100.0/24
VM_IP=192.168.100.10
VM_PORT=22
```

### SNAT
내부 클라이언트의 패킷을 NAT(SNAT)
vm 에서 인터넷 접근 (아래만 한다고 되는게 아니다, 그냥 virbr0 을 이용하는게 낫다) <br>

iptables 버전
```
# 설정
iptables -t nat -A POSTROUTING \
  -o $HOST_IF -s $VM_NET -j MASQUERADE
# 해제
iptables -t nat -D POSTROUTING \
  -o $HOST_IF -s $VM_NET -j MASQUERADE
```

firewall-cmd  버전<br>
```
# 설정
firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 \
  -o $HOST_IF -s $VM_NET -j MASQUERADE
# 해제
firewall-cmd --permanent --direct --remove-rule ipv4 nat POSTROUTING 0 \
  -o $HOST_IF -s $VM_NET -j MASQUERADE
```

룰 확인 <br>
iptables 버전
```
iptables -nvL --line
iptables -t nat -nvL --line
```

firewall-cmd  버전
```
firewall-cmd --direct --get-all-rules
firewall-cmd --permanent --direct --get-all-rules
```

### DNAT
외부에서 host 내부의 vm 으로 접속하기 위해 host 의 포트를 경유하기 <br>

iptables 버전
```
iptables -t nat -A PREROUTING \
  -p tcp -i $HOST_IF --destination $HOST_IP --dport $HOST_PORT \
  -j DNAT --to-destination $VM_IP:$VM_PORT
iptables -A FORWARD \
  -p tcp -d $VM_IP --dport $VM_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
```

firewall-cmd  버전<br>
```
firewall-cmd --permanent --direct --add-rule ipv4 nat PREROUTING 0 \
  -p tcp -i $HOST_IF --destination $HOST_IP --dport $HOST_PORT \
  -j DNAT --to-destination $VM_IP:$VM_PORT
firewall-cmd --permanent --direct --add-rule ipv4 filter FORWARD 0 \
  -p tcp -d $VM_IP --dport $VM_PORT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
```

### BLOCK IP

특성 서버/포트로부터 오는 패킷을 드롭 <br>
(이때는 -A가 아니라 -I <Chain> <rule_num> 으로 입력해야 drop rule 이 우선순위가 높아서 적용을 받게 된다.)

```
IP_TO_DROP=192.168.6.64
PORT_TO_DROP=9092
iptables -I INPUT 1 -p tcp -s $IP_TO_DROP --sport $PORT_TO_DROP -m state --state NEW,ESTABLISHED,RELATED -j REJECT
```

rule 삭제시에도 입력했던 위치를 알고 있으므로 위치를 입력한다.
```
iptables -D INPUT 1
```

