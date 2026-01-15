<H1>mariadb on rocky8 quick start guide</H1>

- [설치](#설치)
  - [yum repo 설치](#yum-repo-설치)
  - [설치](#설치-1)
  - [실행, 리부팅시 자동 실행](#실행-리부팅시-자동-실행)
  - [방화벽 설정 추가](#방화벽-설정-추가)
  - [포트 변경](#포트-변경)
- [초기 설정](#초기-설정)
  - [root 원격 접속 제한](#root-원격-접속-제한)
  - [root 암호 설정](#root-암호-설정)
- [데이타베이스 생성 및 초기화](#데이타베이스-생성-및-초기화)
  - [DB 생성 (ex nsdi)](#db-생성-ex-nsdi)
  - [사용자 생성 (ex sdi)](#사용자-생성-ex-sdi)
  - [DB에 대한 모든 권한 부여](#db에-대한-모든-권한-부여)
  - [DB 스키마 로드](#db-스키마-로드)

## 설치 

### yum repo 설치

rocky 포함된 버전이 아닌 최신 mariadb 를 설치하고 싶다면...

```
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup \
  | sed -e 's/^skip_tools=1/skip_tools=0/g' \
  | sudo bash
```

위 명령이 잘 안될때가 있다...
```
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
cat mariadb_repo_setup \
  | sed -e 's/^skip_tools=1/skip_tools=0/g' \
  | sudo bash
```

### 설치

```
# 서버
sudo yum install -y mariadb-server

# 백업툴 (mariadb-dump)
sudo yum install -y mariadb-tools
```

### 실행, 리부팅시 자동 실행
```
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

### 방화벽 설정 추가

방화벽 서비스에 mysql 확인
```
firewall-cmd --get-services | grep mysql
```

서비스 mysql 에 포트(3306) 확인
```
firewall-cmd --permanent --service=mysql --get-ports
```

방화벽 존(public) 에 mysql 서비스 추가
```
firewall-cmd --zone=public --add-service=mysql --permanent
firewall-cmd --zone=public --add-service=mysql
```

방화벽 존(public) 에 mysql 서비스 확인
```
firewall-cmd --zone=public --list-services --permanent | grep mysql
```

### 포트 변경

예) 기본포트3306 에서 3307로 변경 <br>

설정 변경<br>
/etc/my.cnf 파일의 
**[client-server]** 항목 아래에 설정 추가
```
[client-server]
port=3307
```

selinux 규칙 추가<br>
```
# 3307을 mysqld 허용 포트로 등록
sudo semanage port -a -t mysqld_port_t -p tcp 3307 2>/dev/null || \
sudo semanage port -m -t mysqld_port_t -p tcp 3307

# 확인
sudo semanage port -l | grep -w mysqld_port_t
```

방화벽 규칙 추가<br>
```
# 3307을 mysqld 허용 포트로 등록
sudo firewall-cmd --permanent --service mysql --add-port=3307/tcp
sudo firewall-cmd --reload
```

서비스 재시작<br>
```
sudo systemctl restart mariadb   # 또는: sudo systemctl restart mysqld
sudo systemctl status mariadb
```


## 초기 설정

### root 원격 접속 제한

설치후 아래와 같이 root 의 접속 경로중 localhost 를 제외한 나머지를 삭제한다.
```
MariaDB [mysql]> select host,user from user;
+------------+------+
| host       | user |
+------------+------+
| 127.0.0.1  | root |
| ::1        | root |
| hsseo-dev0 | root |
| localhost  | root |
+------------+------+
4 rows in set (0.001 sec)

MariaDB [mysql]>
```

아래 SQL 문을 실행하여 localhost 가 아닌 접속경로는 모두 제거한다.
```
DELETE FROM mysql.user WHERE User='root' AND Host!='localhost';
```

권한 적용
```
FLUSH PRIVILEGES;
```

확인
```
SELECT User, Host FROM mysql.user WHERE User='root';
```

예)
```
MariaDB [mysql]> SELECT User, Host FROM mysql.user WHERE User='root';
+------+-----------+
| User | Host      |
+------+-----------+
| root | localhost |
+------+-----------+
1 row in set (0.001 sec)

MariaDB [mysql]>
```

### root 암호 설정

암호를 'newpassword' 로 설정하는 경우
```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'newpassword';
FLUSH PRIVILEGES;
```

## 데이타베이스 생성 및 초기화

### DB 생성 (ex nsdi)

```
CREATE DATABASE `nsdi` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```

### 사용자 생성 (ex sdi)

```
CREATE USER 'sdi'@'%' IDENTIFIED BY 'StrongPassword!';
```

### DB에 대한 모든 권한 부여

```
GRANT ALL PRIVILEGES ON `nsdi`.* TO 'sdi'@'%';
```

권한 적용
```
FLUSH PRIVILEGES;
```

권한 확인
```
SHOW GRANTS FOR 'sdi'@'%';
```

### DB 스키마 로드

*.sql 파일들을 이용하여 DB 스키마 로드

```
cat *.sql | mysql -u sdi -p -D nsdi
```
