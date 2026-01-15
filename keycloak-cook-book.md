<H1> Keycloak 26.0.7 설치 가이드 - Rocky Linux 8.10 </H1>

- [개요](#개요)
- [시스템 요구사항](#시스템-요구사항)
- [1. 시스템 준비](#1-시스템-준비)
  - [1.1 시스템 업데이트](#11-시스템-업데이트)
  - [1.2 방화벽 설정](#12-방화벽-설정)
- [2. Java 17 설치](#2-java-17-설치)
  - [2.1 OpenJDK 17 설치](#21-openjdk-17-설치)
  - [2.2 JAVA\_HOME 환경변수 설정](#22-java_home-환경변수-설정)
- [3. Keycloak 사용자 생성](#3-keycloak-사용자-생성)
- [4. Keycloak 26.0.7 다운로드 및 설치](#4-keycloak-2607-다운로드-및-설치)
  - [4.1 Keycloak 다운로드](#41-keycloak-다운로드)
  - [4.2 Keycloak 실행 권한 설정](#42-keycloak-실행-권한-설정)
- [5. 데이터베이스 설정 (PostgreSQL 권장)](#5-데이터베이스-설정-postgresql-권장)
  - [5.1 PostgreSQL 설치](#51-postgresql-설치)
  - [5.2 Keycloak 데이터베이스 생성](#52-keycloak-데이터베이스-생성)
  - [5.3 PostgreSQL JDBC 드라이버 설치](#53-postgresql-jdbc-드라이버-설치)
- [6. Keycloak 설정](#6-keycloak-설정)
  - [6.1 Keycloak 설정 파일 생성](#61-keycloak-설정-파일-생성)
  - [6.2 설정 파일 편집](#62-설정-파일-편집)
- [7. Keycloak 빌드 및 시작](#7-keycloak-빌드-및-시작)
  - [7.1 Keycloak 빌드](#71-keycloak-빌드)
  - [7.2 관리자 계정 생성](#72-관리자-계정-생성)
- [8. 시스템 서비스 설정](#8-시스템-서비스-설정)
  - [8.1 systemd 서비스 파일 생성](#81-systemd-서비스-파일-생성)
  - [8.2 서비스 활성화 및 시작](#82-서비스-활성화-및-시작)
- [9. 접속 확인](#9-접속-확인)
  - [9.1 웹 브라우저로 접속](#91-웹-브라우저로-접속)
  - [9.2 관리 콘솔 접속](#92-관리-콘솔-접속)
- [10. SSL/HTTPS 설정 (선택사항)](#10-sslhttps-설정-선택사항)
  - [10.1 SSL 인증서 생성 (자체 서명)](#101-ssl-인증서-생성-자체-서명)
  - [10.2 HTTPS 설정 추가](#102-https-설정-추가)
- [11. 로그 확인](#11-로그-확인)
  - [11.1 Keycloak 로그 확인](#111-keycloak-로그-확인)
- [12. 문제 해결](#12-문제-해결)
  - [12.1 일반적인 문제들](#121-일반적인-문제들)
    - [Java 버전 문제](#java-버전-문제)
    - [포트 충돌 문제](#포트-충돌-문제)
    - [메모리 부족 문제](#메모리-부족-문제)
  - [12.2 데이터베이스 연결 문제](#122-데이터베이스-연결-문제)
- [13. 보안 고려사항](#13-보안-고려사항)
  - [13.1 기본 설정 변경](#131-기본-설정-변경)
  - [13.2 정기 업데이트](#132-정기-업데이트)
- [14. 백업 및 복원](#14-백업-및-복원)
  - [14.1 데이터베이스 백업](#141-데이터베이스-백업)
  - [14.2 설정 파일 백업](#142-설정-파일-백업)
- [참고 자료](#참고-자료)


## 개요
이 문서는 Rocky Linux 8.10에 Keycloak 26.0.7을 설치하는 과정을 단계별로 설명합니다.

## 시스템 요구사항
- Rocky Linux 8.10
- Java 17 이상
- 최소 4GB RAM
- 최소 10GB 디스크 공간

## 1. 시스템 준비

### 1.1 시스템 업데이트
```bash
sudo dnf update -y
sudo dnf install -y wget curl unzip
```

### 1.2 방화벽 설정
```bash
# 방화벽에서 Keycloak 포트 열기
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8443/tcp
sudo firewall-cmd --reload
```

## 2. Java 17 설치

### 2.1 OpenJDK 17 설치
```bash
# OpenJDK 17 설치
sudo dnf install -y java-17-openjdk java-17-openjdk-devel

# Java 버전 확인
java -version
javac -version
```

### 2.2 JAVA_HOME 환경변수 설정
```bash
# JAVA_HOME 설정
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk' >> ~/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
source ~/.bashrc

# 환경변수 확인
echo $JAVA_HOME
```

## 3. Keycloak 사용자 생성

```bash
# keycloak 전용 사용자 생성
sudo useradd -r -s /bin/false keycloak
sudo mkdir -p /opt/keycloak
sudo chown keycloak:keycloak /opt/keycloak
```

## 4. Keycloak 26.0.7 다운로드 및 설치

### 4.1 Keycloak 다운로드
```bash
# 임시 디렉토리로 이동
cd /tmp

# Keycloak 26.0.7 다운로드
wget https://github.com/keycloak/keycloak/releases/download/26.0.7/keycloak-26.0.7.tar.gz

# 압축 해제
tar -xzf keycloak-26.0.7.tar.gz

# /opt/keycloak로 이동
sudo mv keycloak-26.0.7/* /opt/keycloak/
sudo chown -R keycloak:keycloak /opt/keycloak
```

### 4.2 Keycloak 실행 권한 설정
```bash
sudo chmod +x /opt/keycloak/bin/kc.sh
sudo chmod +x /opt/keycloak/bin/kcadm.sh
```

## 5. 데이터베이스 설정 (PostgreSQL 권장)

### 5.1 PostgreSQL 설치
```bash
# PostgreSQL 13 설치
sudo dnf install -y postgresql-server postgresql-contrib

# 데이터베이스 초기화
sudo postgresql-setup --initdb

# PostgreSQL 서비스 시작 및 활성화
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 5.2 Keycloak 데이터베이스 생성
```bash
# postgres 사용자로 전환
sudo -u postgres psql

# PostgreSQL에서 실행할 명령어들
CREATE DATABASE keycloak;
CREATE USER keycloak WITH ENCRYPTED PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
\q
```

### 5.3 PostgreSQL JDBC 드라이버 설치
```bash
cd /tmp
wget https://jdbc.postgresql.org/download/postgresql-42.7.1.jar
sudo mv postgresql-42.7.1.jar /opt/keycloak/providers/
sudo chown keycloak:keycloak /opt/keycloak/providers/postgresql-42.7.1.jar
```

## 6. Keycloak 설정

### 6.1 Keycloak 설정 파일 생성
```bash
sudo mkdir -p /opt/keycloak/conf
sudo touch /opt/keycloak/conf/keycloak.conf
sudo chown keycloak:keycloak /opt/keycloak/conf/keycloak.conf
```

### 6.2 설정 파일 편집
```bash
sudo vi /opt/keycloak/conf/keycloak.conf
```

다음 내용을 추가:
```properties
# Database settings
db=postgres
db-url=jdbc:postgresql://localhost:5432/keycloak
db-username=keycloak
db-password=your_password

# HTTP settings
http-enabled=true
http-port=8080
hostname=localhost

# HTTPS settings (선택사항)
https-port=8443

# 클러스터링 설정 (단일 인스턴스의 경우 비활성화)
cache=local
```

## 7. Keycloak 빌드 및 시작

### 7.1 Keycloak 빌드
```bash
# keycloak 사용자로 전환하여 빌드
sudo -u keycloak /opt/keycloak/bin/kc.sh build
```

### 7.2 관리자 계정 생성
```bash
# 관리자 사용자 생성
sudo -u keycloak /opt/keycloak/bin/kc.sh start-dev --http-enabled=true --http-port=8080 &

# 또는 환경변수로 설정
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=admin_password
sudo -E -u keycloak /opt/keycloak/bin/kc.sh start-dev
```

## 8. 시스템 서비스 설정

### 8.1 systemd 서비스 파일 생성
```bash
sudo vi /etc/systemd/system/keycloak.service
```

다음 내용을 추가:
```ini
[Unit]
Description=Keycloak Server
After=network.target

[Service]
Type=simple
User=keycloak
Group=keycloak
ExecStart=/opt/keycloak/bin/kc.sh start
Restart=always
RestartSec=10
Environment=KEYCLOAK_ADMIN=admin
Environment=KEYCLOAK_ADMIN_PASSWORD=admin_password

[Install]
WantedBy=multi-user.target
```

### 8.2 서비스 활성화 및 시작
```bash
# systemd 데몬 리로드
sudo systemctl daemon-reload

# Keycloak 서비스 활성화
sudo systemctl enable keycloak

# Keycloak 서비스 시작
sudo systemctl start keycloak

# 서비스 상태 확인
sudo systemctl status keycloak
```

## 9. 접속 확인

### 9.1 웹 브라우저로 접속
```
http://your-server-ip:8080
```

### 9.2 관리 콘솔 접속
```
http://your-server-ip:8080/admin
```

## 10. SSL/HTTPS 설정 (선택사항)

### 10.1 SSL 인증서 생성 (자체 서명)
```bash
# 키스토어 생성
sudo -u keycloak keytool -genkeypair -alias keycloak -keyalg RSA -keysize 2048 -validity 365 -keystore /opt/keycloak/conf/keycloak.keystore -storepass changeit -keypass changeit -dname "CN=localhost, OU=IT, O=Company, L=City, ST=State, C=US"
```

### 10.2 HTTPS 설정 추가
`/opt/keycloak/conf/keycloak.conf` 파일에 추가:
```properties
# HTTPS 설정
https-key-store-file=/opt/keycloak/conf/keycloak.keystore
https-key-store-password=changeit
```

## 11. 로그 확인

### 11.1 Keycloak 로그 확인
```bash
# 실시간 로그 확인
sudo journalctl -u keycloak -f

# 로그 파일 직접 확인
sudo tail -f /opt/keycloak/data/log/keycloak.log
```

## 12. 문제 해결

### 12.1 일반적인 문제들

#### Java 버전 문제
```bash
# Java 버전 확인
java -version

# 여러 Java 버전이 설치된 경우 대안 설정
sudo alternatives --config java
```

#### 포트 충돌 문제
```bash
# 포트 사용 상태 확인
sudo netstat -tlnp | grep :8080
sudo ss -tlnp | grep :8080
```

#### 메모리 부족 문제
`/etc/systemd/system/keycloak.service` 파일에서 JVM 옵션 추가:
```ini
Environment=JAVA_OPTS="-Xms512m -Xmx2g"
```

### 12.2 데이터베이스 연결 문제
```bash
# PostgreSQL 서비스 상태 확인
sudo systemctl status postgresql

# 데이터베이스 연결 테스트
psql -h localhost -U keycloak -d keycloak
```

## 13. 보안 고려사항

### 13.1 기본 설정 변경
- 기본 관리자 비밀번호 변경
- 데이터베이스 비밀번호 변경
- 방화벽 규칙 최소화

### 13.2 정기 업데이트
```bash
# Keycloak 업데이트 시 백업 생성
sudo systemctl stop keycloak
sudo cp -r /opt/keycloak /opt/keycloak.backup.$(date +%Y%m%d)
```

## 14. 백업 및 복원

### 14.1 데이터베이스 백업
```bash
# PostgreSQL 백업
sudo -u postgres pg_dump keycloak > keycloak_backup_$(date +%Y%m%d).sql
```

### 14.2 설정 파일 백업
```bash
# Keycloak 설정 디렉토리 백업
sudo tar -czf keycloak_config_backup_$(date +%Y%m%d).tar.gz /opt/keycloak/conf/
```

---

## 참고 자료
- [Keycloak 공식 문서](https://www.keycloak.org/documentation)
- [Keycloak Server Installation Guide](https://www.keycloak.org/server/installation)
- [Rocky Linux 공식 문서](https://docs.rockylinux.org/)
