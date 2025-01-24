# bash
## 공백이 포함된 문자열 for 처리

```
lines=("first line" "second line" "last line")
for f in "${lines[@]}"
do
  echo "f=$f"
done
```

실행결과
```
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

# sed
## 패턴 A로 특정 줄을 찾아서, 패턴 B를 패턴 C로 변경하는 기능
아래는 "ALLOWED_HOSTS" 로 시작하는 줄을 찾아서 <br>
'=.*' 패턴을 '= [ "*" ]' 으로 변경한다.
```
sed -i '/^ALLOWED_HOSTS/ s/=.*/= [ "*" ]/' \
   /etc/openstack-dashboard/local_settings
```

## 패턴 A로 특정 줄을 찾아서, 해당 줄 아래에 패턴 B를 추가하는 기능
아래는 'disable_all_services' 문자열을 찾아서 <br>
그 다음 줄에 'enable_service rabbitmq-server' 문자열을 추가한다.
```
sed -i '/disable_all_services/a enable_service rabbitmq-server' \
   local.conf
```

## 뉴라인(newline)을 포함한 문자열을 이전 문자열에 포함시키기
아래는 "^TCP" 문자열을 찾아서 이전 라인에 포함시키는 것
http://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed
```
cat FILENAME | sed -z 's/\nTCP/ TCP/g'
```

## 첫줄 제거
```
sed -i '1d'
```

## 첫줄에 문자열 $LINE 추가
```
sed -i "1a $LINE"
```

## 문자열 xyz 포함한 줄 제거
```
sed -i '/xyz/d'
```

## 8번째 줄에 한줄 추가
```
sed -i "8i$LINE" FILE
```

# awk
## 각 줄을 구분자 ' 를 이용하여 토큰을 만든 후 첫번째 항목이 menuentry 인 경우 {} 의 문구를 실행
```
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /boot/efi/EFI/centos/grub.cfg

```
