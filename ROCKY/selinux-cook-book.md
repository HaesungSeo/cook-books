# selinux 권한문제 해결

## audit.log 에러 확인 및 조치

rocky 등의 리눅스는 selinux 가 기본적으로 활성화 되어 있다. <br>
root 권한을 필요로 하는 기능들은 이 selinux 에 적절한 권한을 설정하지 않으면 실행을 실패하는 경우가 있다. <br>
이 때 /var/log/audit/audit.log 를 살펴보자. <br>

```
type=SERVICE_START msg=audit(1734402445.514:2449): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=vpp comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'UID="root" AUID="unset"
```

audit 오류를 기반으로 selinux 정책을 생성할 수 있다. <br>
```
sudo ausearch -c "vpp_main" --raw | audit2allow -M vpp_policy
```
audit2allow -M vpp_policy 명령을 수행하면 vpp_policy.{te,pe} 파일이 생성된다. <br>


## vpp_policy 파일 확인

vpp_policy.te (텍스트포맷의 정책) <br>
vpp_policy.pp (바이너리포맷의 정책) <br>

```
$ cat vpp_policy.te

module vpp_policy 1.0;

require {
	type fs_t;
	type sysctl_fs_t;
	type vpp_t;
	class dir search;
	class filesystem getattr;
}

#============= vpp_t ==============
allow vpp_t fs_t:filesystem getattr;
allow vpp_t sysctl_fs_t:dir search;
$
```

vpp_policy.pp 파일로부터 텍스트포맷의 정책을 살펴보려면 아래의 명령어를 수행한다. <br>
```
sedismod vpp_policy.pp
```

실행하면 아래와 같이 실행 메뉴가 나타나는데 '1' 과 'a' 메뉴를 통해 내용을 확인할 수 있다. <br>
```
$ sedismod vpp_policy.pp
Reading policy...
libsepol.policydb_index_others: security:  0 users, 1 roles, 3 types, 0 bools
libsepol.policydb_index_others: security: 0 sens, 0 cats
libsepol.policydb_index_others: security:  2 classes, 0 rules, 0 cond rules
libsepol.policydb_index_others: security:  0 users, 1 roles, 3 types, 0 bools
libsepol.policydb_index_others: security: 0 sens, 0 cats
libsepol.policydb_index_others: security:  2 classes, 0 rules, 0 cond rules
Binary policy module file loaded.
Module name: vpp_policy
Module version: 1.0


Select a command:
1)  display unconditional AVTAB
2)  display conditional AVTAB
3)  display users
4)  display bools
5)  display roles
6)  display types, attributes, and aliases
7)  display role transitions
8)  display role allows
9)  Display policycon
0)  Display initial SIDs

a)  Display avrule requirements
b)  Display avrule declarations
c)  Display policy capabilities
l)  Link in a module
u)  Display the unknown handling setting
F)  Display filename_trans rules

f)  set output file
m)  display menu
q)  quit

Command ('m' for menu):
```

아래는 '1' 과 'a' 의 실행결과이다.<br>
vpp_policy.te 내용과 비교해보면 동일한 내용임을 알 수 있다.<br>
```
Command ('m' for menu):  1
unconditional avtab:
--- begin avrule block ---
decl 1:                                             ## vpp_policy.te 의 아래 내용을 확인할 수 있다.
  allow [vpp_t] [fs_t] : [filesystem] { getattr };  ## allow vpp_t fs_t:filesystem getattr;
  allow [vpp_t] [sysctl_fs_t] : [dir] { search };   ## allow vpp_t sysctl_fs_t:dir search;

Command ('m' for menu):  a
avrule block requirements:
--- begin avrule block ---
decl 1:
commons: <empty>                                    ## vpp_policy.te 의 아래 내용을 확인할 수 있다.
classes: dir{  search } filesystem{  getattr }      ## require {
roles  : <empty>                                    ## 	type fs_t;
types  : fs_t sysctl_fs_t vpp_t                     ## 	type sysctl_fs_t;
users  : <empty>                                    ## 	type vpp_t;
bools  : <empty>                                    ## 	class dir search;
levels : <empty>                                    ## 	class filesystem getattr;
cats   : <empty>                                    ## }

Command ('m' for menu):
```

## vpp_policy 파일 편집
   
추출한 .te 파일에 rule 을 추가하여 .pp 파일을 새로 생성할 수 있다. <br>

편집된 .te 파일을 컴파일할 도구를 설치한다. <br>

```
sudo dnf install selinux-policy-devel
```

예를 들어 .te 파일을 편집 후 아래와 같이 빌드 한다. <br>
아래의 순서대로 확장자를 가진 파일이 생성된다. <br>
. te -> .mod -> .pp 
```
RULE=vpp_fix10
```

```
checkmodule -M -m -o ${RULE}.mod ${RULE}.te
semodule_package -o ${RULE}.pp -m ${RULE}.mod
```

## vpp_policy 파일 적용

앞에서 생성된 정책을 적용한다.
```
sudo semodule -i vpp_policy.pp
```

정책이 성공적으로 적용되었는지 확인한다.
```
sudo semodule -l | grep vpp
```

정책 제거는 아래와 같다.
```
sudo semodule -r vpp_policy
```

## 기존의 selinux 정책 추출 및 내용 확인

.te 파일이 없는 selinux 의 기존의 정책을 확인하려면 아래와 같이 한다.
```
# 정책 추출
sudo semodule -E vpp_policy
```
명령이 성공적으로 완료되면 현재 디렉토리에 vpp_policy.pp 파일이 생성된다. <br>

