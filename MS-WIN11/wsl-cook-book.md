<p1> WSL Linux </p1>

# WSL2 설치
https://this-circle-jeong.tistory.com/187

CMD 를 관리자 권한으로 실행후 아래 입력
```
# WSL 설치명령 
wsl --install
# WSL 시스템 활성화 
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Virtual Machine 기능 활성화
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# WSL2 설정
wsl --set-default-version 2
```

# ubuntu 설치 (TODO)
