<H1>script cook book</H1>

- [bash](#bash)
  - [공백이 포함된 문자열 for 처리(feat mapfile)](#공백이-포함된-문자열-for-처리feat-mapfile)
- [sed](#sed)
  - [패턴 A로 특정 줄을 찾아서, 패턴 B를 패턴 C로 변경하는 기능](#패턴-a로-특정-줄을-찾아서-패턴-b를-패턴-c로-변경하는-기능)
  - [패턴 A로 특정 줄을 찾아서, 해당 줄 아래에 패턴 B를 추가하는 기능](#패턴-a로-특정-줄을-찾아서-해당-줄-아래에-패턴-b를-추가하는-기능)
  - [뉴라인(newline)을 포함한 문자열을 이전 문자열에 포함시키기](#뉴라인newline을-포함한-문자열을-이전-문자열에-포함시키기)
  - [첫줄 제거](#첫줄-제거)
  - [첫줄에 문자열 $LINE 추가](#첫줄에-문자열-line-추가)
  - [문자열 xyz 포함한 줄 제거](#문자열-xyz-포함한-줄-제거)
  - [8번째 줄에 한줄 추가](#8번째-줄에-한줄-추가)
  - [여러줄의 패턴 작업](#여러줄의-패턴-작업)
- [awk](#awk)
  - [각 줄을 구분자 ' 를 이용하여 토큰을 만든 후 첫번째 항목이 menuentry 인 경우 {} 의 문구를 실행](#각-줄을-구분자--를-이용하여-토큰을-만든-후-첫번째-항목이-menuentry-인-경우--의-문구를-실행)
- [vim](#vim)
  - [vim 버퍼에 문자열 넣기](#vim-버퍼에-문자열-넣기)
  - [vim 버퍼의 문자열 붙여넣기](#vim-버퍼의-문자열-붙여넣기)
- [TERM](#term)
  - [ANSI color 출력](#ansi-color-출력)
  - [커서 초기화](#커서-초기화)
  - [커서 보이기](#커서-보이기)
  - [마우스 리포트 모드 해제](#마우스-리포트-모드-해제)


# bash
## 공백이 포함된 문자열 for 처리(feat mapfile)

```bash
lines=("first line" "second line" "last line")
for f in "${lines[@]}"
do
  echo "f=$f"
done
```

실행결과
```bash
$ lines=("first line" "second line" "last line")
$ for f in "${lines[@]}"
> do
>   echo "f=$f"
> done
f=first line
f=second line
f=last line
$
```

```bash
STR="
a1 a2 a3
b1 b2 b3
"

mapfile -t lines <<< "$STR"
for line in "${lines[@]}"
do
  echo "line=[$line]"
done
```

실행결과
```bash
line=[]
line=[a1 a2 a3]
line=[b1 b2 b3]
line=[]
```

# sed
## 패턴 A로 특정 줄을 찾아서, 패턴 B를 패턴 C로 변경하는 기능
아래는 "ALLOWED_HOSTS" 로 시작하는 줄을 찾아서 <br>
'=.*' 패턴을 '= [ "*" ]' 으로 변경한다.
```bash
sed -i '/^ALLOWED_HOSTS/ s/=.*/= [ "*" ]/' \
   /etc/openstack-dashboard/local_settings
```

## 패턴 A로 특정 줄을 찾아서, 해당 줄 아래에 패턴 B를 추가하는 기능
아래는 'disable_all_services' 문자열을 찾아서 <br>
그 다음 줄에 'enable_service rabbitmq-server' 문자열을 추가한다.
```bash
sed -i '/disable_all_services/a enable_service rabbitmq-server' \
   local.conf
```

## 뉴라인(newline)을 포함한 문자열을 이전 문자열에 포함시키기
아래는 "^TCP" 문자열을 찾아서 이전 라인에 포함시키는 것
http://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed
```bash
cat FILENAME | sed -z 's/\nTCP/ TCP/g'
```

## 첫줄 제거
```bash
sed -i '1d'
```

## 첫줄에 문자열 $LINE 추가
```bash
sed -i "1a $LINE"
```

## 문자열 xyz 포함한 줄 제거
```bash
sed -i '/xyz/d'
```

## 8번째 줄에 한줄 추가
```bash
sed -i "8i$LINE" FILE
```

## 여러줄의 패턴 작업
```bash
# 연속된 \r\n(빈 줄) 제거
# 아래 명령이 왜 동작하지 않는가?
# sed -i 's/\r\n\r\n/\r\n/g' all_cmd.txt
# 원인은 sed의 's' 명령이 한 줄에서 한 번만 치환하기 때문입니다.
# 따라서 연속된 빈 줄을 모두 제거하려면 다음 명령을 사용해야 합니다.
# ':a;N;$!ba;' : 전체 파일을 패턴 공간으로 읽어들입니다
# 's/\r\n\r\n*/\r\n/g' : 연속된 \r\n을 하나의 \r\n으로 치환합니다
sed -i ':a;N;$!ba;s/\r\n\r\n/\r\n/g' all_cmd.txt
```

# awk
## 각 줄을 구분자 ' 를 이용하여 토큰을 만든 후 첫번째 항목이 menuentry 인 경우 {} 의 문구를 실행
```bash
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /boot/efi/EFI/centos/grub.cfg

```

# vim
## vim 버퍼에 문자열 넣기
v 또는 CTRL+v 키를 눌러 VISUAL 모드로 진입한 후 문자열을 선택한다. <br>
선택된 문자열을 vim 버퍼에 넣으려면 'y' 키를 누른다. <br>
vim 은 다중버퍼를 지원한다. 아래와 같이 버퍼를 선택한 후 'y' 를 누르면 해당 키에 문자열이 저장된다. <br>

```bash
'"', <char>, 'y'
```

## vim 버퍼의 문자열 붙여넣기
vim 의 명령행 모드(: 또는 / 로 진입) 에서 vim 버퍼의 문자열을 입력하는 방법
vim 버퍼에 문자열을 이미 복사했다면, 아래와 같이 입력한다.
```bash
CTRL+R, '"'
```

# TERM
## ANSI color 출력

16 color
```bash
cat<<'EOM' > print-16-color.sh
#!/bin/bash
cat<<'EOL'
3         4         5
012345678901234567890
EOL
echo "ANSI 16 Color"
for ((i=0;i<16;i++))
do
  CC=$((30+$i))
  echo -ne "\\033[${CC}m▒\\033[0m"
  NL=$(($i % 80))
  if [ $i -ne 0 -a $NL -eq 0 ]; then
    echo
  fi
done
echo
EOM
chmod +x print-16-color.sh
./print-16-color.sh
```

16 color (BOLD)
```bash
cat<<'EOM' > print-16-color-style.sh
#!/bin/bash
cat<<'EOL'
3         4         5
012345678901234567890
EOL
codes="\033[1m \033[22m set bold mode.
\033[2m \033[22m set dim/faint mode.
\033[3m \033[23m set italic mode.
\033[4m \033[24m set underline mode.
\033[5m \033[25m set blinking mode
\033[7m \033[27m set inverse/reverse mode
\033[8m \033[28m set hidden/invisible mode
\033[9m \033[29m set strikethrough mode."
mapfile -t lines <<< "$codes"

style() {
for line in "${lines[@]}"
do
  setup=$(echo $line | cut -d' ' -f1)
  restr=$(echo $line | cut -d' ' -f2)
  desc=$(echo $line | cut -d' ' -f3-)
  echo "##### $desc #####"
  echo -en "$setup"
  $*
  echo -en "$restr"
done
}

ansi16() {
echo "ANSI 16 Color"
for ((i=0;i<16;i++))
do
  CC=$((30+$i))
  echo -ne "\\033[${CC}m▒\\033[0m"
  NL=$(($i % 80))
  if [ $i -ne 0 -a $NL -eq 0 ]; then
    echo
  fi
done
echo
}

# style 은 잘동작하지 않는것 같다.
# style ansi16
ansi16
EOM
chmod +x print-16-color-style.sh
./print-16-color-style.sh
```

## 커서 초기화

```bash
# 커서 속성(색/강조/밑줄/반전) 초기화
echo -e '\033[0m\033[?5l'
```

```bash
# 커서 색 초기화
echo -e '\033]112\007'
```

## 커서 보이기

```bash
# 커서 다시 보이게 하기
echo -e '\033[?25h'
```

## 마우스 리포트 모드 해제

```bash
# 마우스 리포트 모드 해제
echo -ne '\e[?1000l\e[?1015l\e[?1006l'
```
