<H1> 한글 폰트 설치 </H1>

- [sphinx-build](#sphinx-build)
- [설치](#설치)
  - [폰트 목록 확인](#폰트-목록-확인)
  - [네이버 나눔폰트 설치](#네이버-나눔폰트-설치)
  - [구글 나눔폰트 설치](#구글-나눔폰트-설치)
  - [폰트캐시 갱신](#폰트캐시-갱신)
  - [폰트 목록 확인](#폰트-목록-확인-1)
  - [폰트 목록 확인 (.ttc)](#폰트-목록-확인-ttc)

# sphinx-build 

sphinx-build 프로그램에서 인식하는 폰트는 .ttc 파일의 폰트만 인식한다.

# 설치

## 폰트 목록 확인

```bash
fc-list | sort | uniq | grep -i nanum
fc-cache -v | sort | uniq | grep -i nanum
```bash

설치전)
```bash
$ fc-list | grep -i nanum
$ fc-cache -v | grep -i nanum
$

## 폰트 매니저 설치

fontconfig 툴을 먼저 설치한다.
```bash
sudo yum install fontconfig
```

## 네이버 나눔폰트 설치

```bash
sudo mkdir -p /usr/share/fonts/nanum

git clone https://github.com/ujuc/nanum-font.git

cd nanum-font/ttf
sudo cp *.ttc *.ttf /usr/share/fonts/nanum
```

## 구글 나눔폰트 설치

https://github.com/google/fonts

```bash
ARC="google-fonts-main.zip"
ARC_DIR="google-fonts-main"

if [ ! -f "$ARC" ]; then
  wget -O "$ARC" https://github.com/google/fonts/archive/main.zip
fi
unzip -l "$ARC" > google-fonts-main.txt 

if [ ! -d "$ARC_DIR" ]; then
  unzip -q "$ARC"
fi
```

폰트 명단을 보면 ttc 폰트는 없음을 유의한다.
```bash
(default) [hsseo-go1.24@hsseo-dev0 hangul-font]$ cat google-fonts-main.txt | grep -i nanum
        0  12-13-2025 00:24   fonts-main/ofl/nanumbrushscript/
      357  12-13-2025 00:24   fonts-main/ofl/nanumbrushscript/DESCRIPTION.en_us.html
       11  12-13-2025 00:24   fonts-main/ofl/nanumbrushscript/EARLY_ACCESS.category
      496  12-13-2025 00:24   fonts-main/ofl/nanumbrushscript/METADATA.pb
  3564804  12-13-2025 00:24   fonts-main/ofl/nanumbrushscript/NanumBrushScript-Regular.ttf
     4534  12-13-2025 00:24   fonts-main/ofl/nanumbrushscript/OFL.txt
       77  12-13-2025 00:24   fonts-main/ofl/nanumbrushscript/README
        0  12-13-2025 00:24   fonts-main/ofl/nanumgothic/
      349  12-13-2025 00:24   fonts-main/ofl/nanumgothic/DESCRIPTION.en_us.html
       10  12-13-2025 00:24   fonts-main/ofl/nanumgothic/EARLY_ACCESS.category
     1057  12-13-2025 00:24   fonts-main/ofl/nanumgothic/METADATA.pb
  2073868  12-13-2025 00:24   fonts-main/ofl/nanumgothic/NanumGothic-Bold.ttf
  2112720  12-13-2025 00:24   fonts-main/ofl/nanumgothic/NanumGothic-ExtraBold.ttf
  2054744  12-13-2025 00:24   fonts-main/ofl/nanumgothic/NanumGothic-Regular.ttf
     4534  12-13-2025 00:24   fonts-main/ofl/nanumgothic/OFL.txt
       77  12-13-2025 00:24   fonts-main/ofl/nanumgothic/README
        0  12-13-2025 00:24   fonts-main/ofl/nanumgothiccoding/
      367  12-13-2025 00:24   fonts-main/ofl/nanumgothiccoding/DESCRIPTION.en_us.html
        9  12-13-2025 00:24   fonts-main/ofl/nanumgothiccoding/EARLY_ACCESS.category
      867  12-13-2025 00:24   fonts-main/ofl/nanumgothiccoding/METADATA.pb
  2246240  12-13-2025 00:24   fonts-main/ofl/nanumgothiccoding/NanumGothicCoding-Bold.ttf
  2315924  12-13-2025 00:24   fonts-main/ofl/nanumgothiccoding/NanumGothicCoding-Regular.ttf
     4534  12-13-2025 00:24   fonts-main/ofl/nanumgothiccoding/OFL.txt
       77  12-13-2025 00:24   fonts-main/ofl/nanumgothiccoding/README
        0  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/
      346  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/DESCRIPTION.en_us.html
        5  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/EARLY_ACCESS.category
     1021  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/METADATA.pb
  3074720  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/NanumMyeongjo-Bold.ttf
  3180888  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/NanumMyeongjo-ExtraBold.ttf
  3058408  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/NanumMyeongjo-Regular.ttf
     4497  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/OFL.txt
       77  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/README
      809  12-13-2025 00:24   fonts-main/ofl/nanummyeongjo/hotfix-space.py
        0  12-13-2025 00:24   fonts-main/ofl/nanumpenscript/
      353  12-13-2025 00:24   fonts-main/ofl/nanumpenscript/DESCRIPTION.en_us.html
       11  12-13-2025 00:24   fonts-main/ofl/nanumpenscript/EARLY_ACCESS.category
      479  12-13-2025 00:24   fonts-main/ofl/nanumpenscript/METADATA.pb
  3201664  12-13-2025 00:24   fonts-main/ofl/nanumpenscript/NanumPenScript-Regular.ttf
     4534  12-13-2025 00:24   fonts-main/ofl/nanumpenscript/OFL.txt
       77  12-13-2025 00:24   fonts-main/ofl/nanumpenscript/README
(default) [hsseo-go1.24@hsseo-dev0 hangul-font]$
```

## 폰트캐시 갱신

```bash
fc-cache -f
```

## 폰트 목록 확인

설치후)
```bash
(default) [hsseo-go1.24@hsseo-dev0 ~]$ fc-list | sort | uniq | grep -i nanum
/usr/share/fonts/nanum/NanumBarunGothicBold.ttf: NanumBarunGothic,나눔바른고딕:style=Bold
/usr/share/fonts/nanum/NanumBarunGothicLight.ttf: NanumBarunGothic,나눔바른고딕,NanumBarunGothic Light,나눔바른고딕 Light:style=Light
/usr/share/fonts/nanum/NanumBarunGothic.ttf: NanumBarunGothic,나눔바른고딕:style=Regular
/usr/share/fonts/nanum/NanumBarunGothicUltraLight.ttf: NanumBarunGothic,나눔바른고딕,NanumBarunGothic UltraLight,나눔바른고딕 UltraLight:style=UltraLight
/usr/share/fonts/nanum/NanumBarunGothic-YetHangul.ttf: NanumBarunGothic YetHangul,나눔바른고딕 옛한글:style=Regular
/usr/share/fonts/nanum/NanumBarunpenB.ttf: NanumBarunpen,나눔바른펜,NanumBarunpen Bold:style=Bold,Regular
/usr/share/fonts/nanum/NanumBarunpenR.ttf: NanumBarunpen,나눔바른펜:style=Regular
/usr/share/fonts/nanum/NanumBrush.ttf: Nanum Brush Script,나눔손글씨 붓:style=Regular
/usr/share/fonts/nanum/NanumGothicBold.ttf: NanumGothic,나눔고딕:style=Bold
/usr/share/fonts/nanum/NanumGothicCoding-Bold.ttf: NanumGothicCoding,나눔고딕코딩:style=Bold
/usr/share/fonts/nanum/NanumGothicCoding.ttf: NanumGothicCoding,나눔고딕코딩:style=Regular
/usr/share/fonts/nanum/NanumGothicEcoBold.ttf: NanumGothic Eco,나눔고딕 에코:style=Bold
/usr/share/fonts/nanum/NanumGothicEcoExtraBold.ttf: NanumGothic Eco,나눔고딕 에코,NanumGothic Eco ExtraBold,나눔고딕 에코 ExtraBold:style=ExtraBold,Regular
/usr/share/fonts/nanum/NanumGothicEco.ttf: NanumGothic Eco,나눔고딕 에코:style=Regular
/usr/share/fonts/nanum/NanumGothicExtraBold.ttf: NanumGothic,나눔고딕,NanumGothicExtraBold,나눔고딕 ExtraBold:style=ExtraBold,Regular,Bold
/usr/share/fonts/nanum/NanumGothic.ttc: Nanum Gothic,나눔고딕,NanumGothic ExtraBold,나눔고딕 ExtraBold:style=ExtraBold
/usr/share/fonts/nanum/NanumGothic.ttc: Nanum Gothic,나눔고딕:style=Bold
/usr/share/fonts/nanum/NanumGothic.ttc: Nanum Gothic,나눔고딕:style=Regular
/usr/share/fonts/nanum/NanumGothic.ttf: NanumGothic,나눔고딕:style=Regular
/usr/share/fonts/nanum/NanumMyeongjoBold.ttf: NanumMyeongjo,나눔명조:style=Bold
/usr/share/fonts/nanum/NanumMyeongjoEcoBold.ttf: NanumMyeongjo Eco,나눔명조 에코:style=Bold
/usr/share/fonts/nanum/NanumMyeongjoEcoExtraBold.ttf: NanumMyeongjo Eco,나눔명조 에코,NanumMyeongjo Eco ExtraBold,나눔명조 에코 ExtraBold:style=ExtraBold,Regular
/usr/share/fonts/nanum/NanumMyeongjoEco.ttf: NanumMyeongjo Eco,나눔명조 에코:style=Regular
/usr/share/fonts/nanum/NanumMyeongjoExtraBold.ttf: NanumMyeongjo,나눔명조,NanumMyeongjoExtraBold,나눔명조 ExtraBold:style=ExtraBold,Regular
/usr/share/fonts/nanum/NanumMyeongjo.ttc: Nanum Myeongjo,나눔명조,NanumMyeongjoExtraBold,나눔명조 ExtraBold:style=ExtraBold,Regular
/usr/share/fonts/nanum/NanumMyeongjo.ttc: Nanum Myeongjo,나눔명조:style=Bold
/usr/share/fonts/nanum/NanumMyeongjo.ttc: Nanum Myeongjo,나눔명조:style=Regular
/usr/share/fonts/nanum/NanumMyeongjo.ttf: NanumMyeongjo,나눔명조:style=Regular
/usr/share/fonts/nanum/NanumMyeongjo-YetHangul.ttf: NanumMyeongjo YetHangul,나눔명조 옛한글:style=Regular
/usr/share/fonts/nanum/NanumPen.ttf: Nanum Pen Script,나눔손글씨 펜:style=Regular
/usr/share/fonts/nanum/NanumScript.ttc: Nanum Brush Script,나눔손글씨 붓:style=Regular
/usr/share/fonts/nanum/NanumScript.ttc: Nanum Pen Script,나눔손글씨 펜:style=Regular
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding ligature:style=Bold
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding ligature:style=Regular
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding:style=Bold
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding:style=Regular
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-ligature.ttc: D2Coding ligature:style=Bold
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-ligature.ttc: D2Coding ligature:style=Regular
(default) [hsseo-go1.24@hsseo-dev0 ~]$ fc-cache -v | sort | uniq | grep -i nanum
/usr/share/fonts/nanum: skipping, existing cache is valid: 32 fonts, 0 dirs
/usr/share/fonts/nanum: skipping, looped directory detected
/usr/share/fonts/naver-nanum: skipping, existing cache is valid: 6 fonts, 0 dirs
/usr/share/fonts/naver-nanum: skipping, looped directory detected
(default) [hsseo-go1.24@hsseo-dev0 ~]$
```

## 폰트 목록 확인 (.ttc)

sphinx-build 프로그램에서 인식하는 폰트는 .ttc 파일의 폰트만 인식한다.
```bash
(default) [hsseo-go1.24@hsseo-dev0 ~]$ fc-list | sort | uniq | grep -i nanum | grep -i ttc
/usr/share/fonts/nanum/NanumGothic.ttc: Nanum Gothic,나눔고딕,NanumGothic ExtraBold,나눔고딕 ExtraBold:style=ExtraBold
/usr/share/fonts/nanum/NanumGothic.ttc: Nanum Gothic,나눔고딕:style=Bold
/usr/share/fonts/nanum/NanumGothic.ttc: Nanum Gothic,나눔고딕:style=Regular
/usr/share/fonts/nanum/NanumMyeongjo.ttc: Nanum Myeongjo,나눔명조,NanumMyeongjoExtraBold,나눔명조 ExtraBold:style=ExtraBold,Regular
/usr/share/fonts/nanum/NanumMyeongjo.ttc: Nanum Myeongjo,나눔명조:style=Bold
/usr/share/fonts/nanum/NanumMyeongjo.ttc: Nanum Myeongjo,나눔명조:style=Regular
/usr/share/fonts/nanum/NanumScript.ttc: Nanum Brush Script,나눔손글씨 붓:style=Regular
/usr/share/fonts/nanum/NanumScript.ttc: Nanum Pen Script,나눔손글씨 펜:style=Regular
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding ligature:style=Bold
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding ligature:style=Regular
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding:style=Bold
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding:style=Regular
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-ligature.ttc: D2Coding ligature:style=Bold
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-ligature.ttc: D2Coding ligature:style=Regular
(default) [hsseo-go1.24@hsseo-dev0 ~]$ fc-list | sort | uniq | grep -i nanum | grep -i .ttc
/usr/share/fonts/nanum/NanumGothic.ttc: Nanum Gothic,나눔고딕,NanumGothic ExtraBold,나눔고딕 ExtraBold:style=ExtraBold
/usr/share/fonts/nanum/NanumGothic.ttc: Nanum Gothic,나눔고딕:style=Bold
/usr/share/fonts/nanum/NanumGothic.ttc: Nanum Gothic,나눔고딕:style=Regular
/usr/share/fonts/nanum/NanumMyeongjo.ttc: Nanum Myeongjo,나눔명조,NanumMyeongjoExtraBold,나눔명조 ExtraBold:style=ExtraBold,Regular
/usr/share/fonts/nanum/NanumMyeongjo.ttc: Nanum Myeongjo,나눔명조:style=Bold
/usr/share/fonts/nanum/NanumMyeongjo.ttc: Nanum Myeongjo,나눔명조:style=Regular
/usr/share/fonts/nanum/NanumScript.ttc: Nanum Brush Script,나눔손글씨 붓:style=Regular
/usr/share/fonts/nanum/NanumScript.ttc: Nanum Pen Script,나눔손글씨 펜:style=Regular
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding ligature:style=Bold
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding ligature:style=Regular
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding:style=Bold
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-all.ttc: D2Coding:style=Regular
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-ligature.ttc: D2Coding ligature:style=Bold
/usr/share/fonts/naver-nanum/D2Coding-Ver1.3.2-20180524-ligature.ttc: D2Coding ligature:style=Regular
(default) [hsseo-go1.24@hsseo-dev0 ~]$
```