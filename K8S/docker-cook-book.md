<H1>docker cook book</H1>

- [docker 설치](#docker-설치)
	- [설치 @centos7.4](#설치-centos74)
	- [설치 @rocky8.8](#설치-rocky88)
	- [설치 @ubuntu 22.04 TLS](#설치-ubuntu-2204-tls)
- [docker 명령어 예제](#docker-명령어-예제)
	- [docker image 로드하기 (파일)](#docker-image-로드하기-파일)
	- [docker image 확인하기](#docker-image-확인하기)
	- [docker image 로부터 instance 실행하기](#docker-image-로부터-instance-실행하기)
		- [아래 예제는 5G\_Probe 의 xdr 을 mysql db로 로드한 docker 이미지를 실행하는 예제](#아래-예제는-5g_probe-의-xdr-을-mysql-db로-로드한-docker-이미지를-실행하는-예제)
	- [docker image 의 instance 확인하기](#docker-image-의-instance-확인하기)
	- [docker instance 재시작 하기](#docker-instance-재시작-하기)
	- [docker 로 msyql 서비스를 로드한 경우 아래와 같이 접속 가능](#docker-로-msyql-서비스를-로드한-경우-아래와-같이-접속-가능)
- [multi-architecture](#multi-architecture)
	- [docker buildx](#docker-buildx)
		- [private registry 의 ca.crt 정보를 복사](#private-registry-의-cacrt-정보를-복사)
		- [buildkitd.toml 작성](#buildkitdtoml-작성)
		- [buildx 런타임 실행](#buildx-런타임-실행)
		- [buildx 런타임 상태 확인](#buildx-런타임-상태-확인)
		- [buildx 를 이용하여 build, push!](#buildx-를-이용하여-build-push)
		- [buildx 빌더 종료](#buildx-빌더-종료)
	- [containerd, nerdctl, buildit](#containerd-nerdctl-buildit)
		- [containerd 설치 @rocky 8.8](#containerd-설치-rocky-88)
		- [삭제](#삭제)
		- [private registry 를 위해 아래와 같이 입력한다.](#private-registry-를-위해-아래와-같이-입력한다)
		- [nerdctl 설치](#nerdctl-설치)
		- [buildkit 설치](#buildkit-설치)
		- [buildkit 서비스 등록 및 실행](#buildkit-서비스-등록-및-실행)


# docker 설치
## 설치 @centos7.4

기본 배포판의 버전을 삭제 후 아래와 같이 최신버전을 설치
```
yum erase docker docker-cli docker-common -y 
cd /etc/yum.repos.d/ 
wget https://download.docker.com/linux/centos/docker-ce.repo 
yum install docker-ce containerd.io -y
```

## 설치 @rocky8.8

그냥 아래와 같이 설치 명령을 수행하면 podman-docker 가 설치되므로 주의한다!
```
sudo yum install -y docker
```
- docker 서비스는 없음
- http 이거나 self-signed certificate 를 사용하는 경우는 아래 파일을 수정한다.
	- /etc/containers/registries.conf
	- 파일의 끝에 아래와 같이 [[registry]] 항목을 추가한다.
```
[[registry]]
location = "ntels.harbor.core"
insecure = true
```

https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-rocky-linux-8

저장소 등록
```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

설치
```
sudo dnf install docker-ce docker-ce-cli containerd.io
```

docker 데몬 시작
```
sudo systemctl start docker
sudo systemctl status docker
sudo systemctl enable docker
```

container registry 등록(http 또는 self-signed)
- http 이거나 self-signed certificate 를 사용하는 경우는 아래 파일을 수정한다.
  - /etc/docker/daemon.json
- 수정후 docker 데몬 재시작

```
cat<<EOM | sudo tee -a /etc/docker/daemon.json
{
        "insecure-registries" : ["ntels.harbor.core"]
}
EOM
sudo systemctl restart docker
```

none root 도 docker 명령어를 실행할 수 있도록 해당 사용자를 docker group 에 넣어준다.
(해당 사용자로 다시 로그인해야 적용된다.)
```
sudo usermod -aG docker $(whoami)
# login again, to take effect
```


## 설치 @ubuntu 22.04 TLS

apt-get 업데이트
```
sudo apt-get update -y
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
```

docker GPG 키 설치
```
mudo mkdir -p /etc/apt/keyrings 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

docker repository 설치
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

docker engine 설치
```
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
```

설치 후 버전 확인
```
docker compose version
```


# docker 명령어 예제

## docker image 로드하기 (파일)

```
docker load < skt_xdr_docker.tar.gz
```


## docker image 확인하기

```
docker images
```


## docker image 로부터 instance 실행하기

### 아래 예제는 5G_Probe 의 xdr 을 mysql db로 로드한 docker 이미지를 실행하는 예제
```
docker run --name xDR -p 3306:3306 -d -e MYSQL_ROOT_PASSWORD=1234 skt_xdr_docker
```

## docker image 의 instance 확인하기
```
docker container ls --all
```

## docker instance 재시작 하기
```
docker start xDR
```

## docker 로 msyql 서비스를 로드한 경우 아래와 같이 접속 가능
```
mysql -uxdr -p -h127.0.0.1 xDR
```

# multi-architecture 

Dockerfile 에 의해 바이너리를 container image 로 생성할 때 multi-architecture 를 지원할 수 있다.

## docker buildx

https://docs.docker.com/build/building/multi-platform/#cross-compilation <br>

docker 는 multi-architecture build 를 기본으로 지원한다. <br>
buildx 라는 명령어를 이용한다. <br>
buildx 는 기본적으로 public registry 와 연동하려고 하는데, <br>
tls privatge registry 를 이용하려면 해당 tls 를 등록해주어야 한다. <br>

### private registry 의 ca.crt 정보를 복사
* rocky
```
sudo cp ca.crt /etc/pki/ca-trust/source/anchors
sudo update-ca-trust extract
sudo systemctl restart docker
```

* ubuntu
```
sudo cp ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
sudo systemctl restart docker
```

### buildkitd.toml 작성

```
cat<<EOM > buildkitd.toml
debug = true
[registry."ntels.harbor.core"]
  insecure = true
  http = false
  ca=["ca.crt"]
EOM
```

### buildx 런타임 실행
```
docker buildx create --name mybuilder \
  --config buildkitd.toml \
  --driver-opt=network=host \
  --bootstrap --use
```

### buildx 런타임 상태 확인

```
docker buildx ls
docker exec -it buildx_buildkit_mybuilder0 sh
cat /etc/hosts # ntels.harbor.core 확인
```

### buildx 를 이용하여 build, push!
* ntels.harbor.core
```
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ntels.harbor.core/media-edge/march-test:latest \
  --push \
  .
```

### buildx 빌더 종료
```
docker buildx rm mybuilder
```



## containerd, nerdctl, buildit

container runtime 이 docker 에서 containerd 로 변경되었다.
새로운 명령어 세트를 사용하기 위한 설치 과정

### containerd 설치 @rocky 8.8

```
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y containerd.io --allowerasing
containerd config default | sudo tee /etc/containerd/config.toml 
sudo systemctl restart containerd
sudo systemctl status containerd
sudo systemctl enable containerd
```

### 삭제

```
sudo systemctl stop containerd 
sudo systemctl disable containerd
sudo dnf remove -y containerd.io
```

### private registry 를 위해 아래와 같이 입력한다.

configs 와 mirrors 설정을 입력한다.
[plugins."io.containerd.grpc.v1.cri".registry.configs] 
[plugins."io.containerd.grpc.v1.cri".registry.mirrors]
```
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
      [plugins."io.containerd.grpc.v1.cri".registry.configs."ntels.harbor.core".tls]
          insecure_skip_verify = true # ntels.harbor.core

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors."ntels.harbor.core"]
          endpoint = ["https://ntels.harbor.core"]
```

### nerdctl 설치

```
wget https://github.com/containerd/nerdctl/releases/download/v1.7.4/nerdctl-1.7.4-linux-amd64.tar.gz
sudo tar Cxzvvf /usr/bin nerdctl-1.7.4-linux-amd64.tar.gz
echo "source <(nerdctl completion bash)" >> ~/.bashrc
```


### buildkit 설치

```
wget https://github.com/moby/buildkit/releases/download/v0.12.5/buildkit-v0.12.5.linux-amd64.tar.gz
sudo tar xpf buildkit-v0.12.5.linux-amd64.tar.gz -C /usr
sudo nohup /usr/bin/buildkitd /var/log/buildkitd 2>&1 &
```


### buildkit 서비스 등록 및 실행

```
cat<<EOM > buildkitd.service
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
[Unit]
Description=buildkitd runtime
After=network.target local-fs.target
[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/buildkitd /var/log/buildkitd 2>&1
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
TasksMax=infinity
OOMScoreAdjust=-999
[Install]
WantedBy=multi-user.target
EOM
sudo cp buildkitd.service /usr/lib/systemd/system
sudo systemctl daemon-reload
systemctl start buildkitd.service
systemctl status buildkitd.service
```

buildctl 로 이미지를 빌드할 수는 있으나 빌드된 이미지가 nerdctl image ls 에서 보이지 않는 문제가 있다.
nerdctl 로 빌드한다.
