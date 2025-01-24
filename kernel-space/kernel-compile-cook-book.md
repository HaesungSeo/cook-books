<h1>kernel compile</h1>

# CentOS 7

https://wiki.centos.org/HowTos/I_need_the_Kernel_Source

## CentOS 7.2.11 커널소스 다운로드
http://vault.centos.org/7.2.1511/os/Source/SPackages/kernel-3.10.0-327.el7.src.rpm

컴파일 필요한 도구 설치
```
yum install rpm-build redhat-rpm-config asciidoc bison hmaccalc patchutils perl-ExtUtils-Embed xmlto
yum install audit-libs-devel binutils-devel elfutils-devel elfutils-libelf-devel
yum install newt-devel python-devel zlib-devel
```

src.rpm 풀리는 디렉토리 지정
```
cat > ~/.rpmmacros << EOM
%_topdir    $HOME/src/rpm
EOM
```

rpm 설치
```
'warning: user builder does not exist - using root' 경고 메시지는 무시가능
rpm -ivh kernel-3.10.0-327.el7.src.rpm
```


# ubuntu


## 위키
http://en.wikipedia.org/wiki/Multipath_TCP

## 커널 MPTCP 프로젝트
http://www.multipath-tcp.org

### 다운로드
```
git clone -b mptcp_v0.88 git://github.com/multipath-tcp/mptcp
wget https://github.com/multipath-tcp/mptcp/archive/mptcp_v0.88.zip
```

MPTCP 갤럭시S3 안드로이드 포팅
http://people.cs.umass.edu/~ylim/mptcp/

MPTCP 갤럭시S2 안드로이드 포팅
https://github.com/mptcp-galaxys2?tab=repositories

MPTCP 구글 넥서스 안드로이드 포팅
https://github.com/mptcp-nexus/android
https://github.com/mptcp-nexus/


# 개발도구
# vim 확장
sudo apt-get install cscope ctags



# 커널컴파일을 위한 준비작업
# http://blog.daum.net/bagjunggyu/138
# 커널업데이트후 라이브러리충돌 방지차원에서 실행
sudo apt-get update && sudo apt-get upgrade

# 커널 컴파일을 위해 필요한 도구들 설치
sudo apt-get install libncurses5-dev
sudo apt-get install make cscope ctags

# 커널 MPTCP 컴파일
# http://multipath-tcp.org/pmwiki.php/Users/DoItYourself
# 현재설정 복사
cp /boot/config-3.11.0-12-generic ./.config

# 현재커널설정중에 반영해야 할 것
# Device Drivers
# -> Graphics support
#    -> Support for frame buffer devices
#       -> VESA VGA graphics support
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_VESA=m

# 네트워킹 설정에 MPTCP 활성화
make menuconfig
# Networking support -> Networking options -> MPTCP protocol

# 아래는 mptcp-0.88 의 커널에서는 설정할 수 없음
HID_BATTERY_STRENGTH=y
AUFS_FS=m
AUFS_BRANCH_MAX_127=y
AUFS_SBILIST=y
AUFS_EXPORT=y
AUFS_INO_T_64=y
AUFS_BR_RAMFS=y
AUFS_BR_FUSE=y
AUFS_POLL=y
AUFS_BR_HFSPLUS=y
AUFS_BDEV_LOOP=y
OVERLAYFS_FS=m
SECURITY_APPARMOR_UNCONFINED_INIT=y
SECURITY_APPARMOR_HASH=y
CRYPTO_CRCT10DIF=y
CRYPTO_CRCT10DIF_PCLMUL=m


# 커널 컴파일
make

# 컴파일완료된 커널 인스톨
# INSTALL_MOD_STRIP=1 : 모듈을 인스톨할 때 스트립을 수행한다.
sudo make INSTALL_MOD_STRIP=1 modules_install
sudo make install

# mptcp-0.88 패치추출을 위한 베이스커널 준비작업(3.11.10)
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.11.10.tar.bz2


# mptcp 관련 툴 설치
# http://multipath-tcp.org/pmwiki.php/Users/AptRepository
wget -q -O - http://multipath-tcp.org/mptcp.gpg.key | sudo apt-key add -

# ubuntu-14.04 인경우 아래 입력
cat > /etc/apt/sources.list.d/mptcp.list << EOM
deb http://multipath-tcp.org/repos/apt/debian trusty main
EOM
cat /etc/apt/sources.list.d/mptcp.list

# 유틸리티 다운로드
sudo apt-get update
sudo apt-get install linux-mptcp



# 네트워크 인터페이스 사용량 확인
sudo apt-get install libpcap-dev
# http://ex-parrot.com/~pdw/iftop/
wget http://ex-parrot.com/~pdw/iftop/download/iftop-0.17.tar.gz

# MPTCP-0.88 조작
# display
sysctl net.mptcp.mptcp_enabled
sysctl net.mptcp.mptcp_path_manager
sysctl net.mptcp.mptcp_ndiffports

# MPTCP off
sysctl -w net.mptcp.mptcp_enabled=0

# MPTCP on @server
sysctl -w net.mptcp.mptcp_enabled=1
sysctl -w net.mptcp.mptcp_path_manager=default
ip link set dev eth0 multipath off
ip link set dev eth1 multipath off
ip link set dev eth2 multipath off
ip link set dev eth3 multipath on
ip link set dev eth4 multipath on

# MPTCP on @client
sysctl -w net.mptcp.mptcp_enabled=1
sysctl -w net.mptcp.mptcp_path_manager=fullmesh
sysctl -w net.mptcp.mptcp_ndiffports=2
ip link set dev eth0 multipath off
ip link set dev eth1 multipath off
ip link set dev eth2 multipath off
ip link set dev eth3 multipath on
ip link set dev eth4 multipath on

# on/off 조작
ip link set dev eth0 multipath off
ip link set dev eth1 multipath off
ip link set dev eth2 multipath off
ip link set dev eth3 multipath off
ip link set dev eth4 multipath off

# TSC 설정
cat /sys/devices/system/clocksource/clocksource0/current_clocksource
kvm-clock

# TCP 모니터링
netstat -an | awk '/^tcp/ {print $NF}' | sort | uniq -c | sort -rn

# IP별 커넥션 모니터링
netstat -natp | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n | tail


