<H1> Swagger to PDF </H1>

- [Intro](#intro)
- [python 버전](#python-버전)
  - [python 가상환경 설정](#python-가상환경-설정)
- [패키지 설치](#패키지-설치)
  - [python 패키지 설치](#python-패키지-설치)
- [빌드 (swagger to pdf)](#빌드-swagger-to-pdf)
  - [openapi](#openapi)
  - [index.rst](#indexrst)
  - [conf.py](#confpy)
  - [do build](#do-build)


# Intro

swagger 파일을 pdf 로 변환하는 가장 많이 쓰는 방법은 python tool (sphinx + sphinxcontrib-openapi) 을 사용하는 것이다.
이 경우, swagger 파일에 다국어(한국어) 를 포함하는 경우, 한글 폰트 설치와 추가적인 설정이 필요하다. <br>
한글 폰트는 .ttc 를 설치해야 한다. <br>

아래 패키지를 이용한다. <br>
google-noto-sans-cjk-ttc-fonts  <br>
google-noto-serif-cjk-ttc-fonts <br>

참고 [`hangul-font-cook-book.md`](hangul-font/hangul-font-cook-book.md)


# python 버전

python3.9 이상에서 정상동작함을 확인하였다. <br>
(<B>rocky 8.10 의 기본 버전(3.6) 에서는 정상적으로 동작하지 않음에 주의한다.</B>)

## python 가상환경 설정
```
cat<<'EOM' > py_env39.sh 
#!/bin/bash

os_distro_raw=`awk -F '=' '/^ID=/ { print $2 }' /etc/os-release`
os_distro="${os_distro_raw%\"}"
os_distro="${os_distro#\"}"

function usage() {
  echo "Usage: source $0 [-h] [<dir>]"
  echo ""
  echo "  -h:    display this help and exit"
  echo "  <dir>: directory to store python environment config"
  echo "       default: ~/.venv/default"
}

DEFAULT_ENV_DIR="$HOME/.venv/default"
while getopts ":h" opt; do
  case ${opt} in
    h)
      usage
      exit 0
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# check excuted as script or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This script must be sourced. Use 'source $0' or '. $0'" >&2
  exit 1
fi

if [ -n "$1" ]; then
  DEFAULT_ENV_DIR="$1"
fi

if [ $os_distro == "centos" ]; then
  /opt/rh/rh-python38/root/usr/bin/python -m venv "$DEFAULT_ENV_DIR"
  . "$DEFAULT_ENV_DIR/bin/activate"
else
  python3.9 -m venv "$DEFAULT_ENV_DIR"
  . "$DEFAULT_ENV_DIR/bin/activate"
fi
EOM
chmod +x py_env39.sh
```

적용예)
```
[hsseo-go1.24@hsseo-dev0 swagger-to-pdf]$ . ./py_env39.sh
(default) [hsseo-go1.24@hsseo-dev0 swagger-to-pdf]$
```

# 패키지 설치

시스템 패키지의 경우 root 권한이필요하다. 
```
# root 권한 필요
sudo yum install -y latexmk \
  texlive-scheme-basic \
  texlive-cmap \
  texlive-ec \
  texlive-euro \
  texlive-fancyvrb \
  texlive-geometry \
  texlive-hyperref \
  texlive-latex \
  texlive-latex-bin \
  texlive-latex-extra \
  texlive-latex-recommended \
  texlive-latexmk \
  texlive-mathspec \
  texlive-psnfss \
  texlive-science \
  texlive-xetex \
  texlive-zhnumber \
  texlive-zhmetrics \
  texlive-zhutils

# install hungul font
sudo yum install -y google-noto-sans-cjk-ttc-fonts
sudo yum install -y google-noto-serif-cjk-ttc-fonts

sudo yum install -y texlive-fontspec
sudo yum install -y texlive-xetex
sudo yum install -y texlive-luatex

sudo dnf install -y texlive-polyglossia
sudo dnf install -y texlive-xecjk
```

## python 패키지 설치
아래는 python 환경변수를 적용한 상태에서 실행해야 pip 가 정상적으로 동작한다.
```
cat<<'EOM > requirements.txt
sphinx>=5.3.0
sphinxcontrib-openapi>=0.2.1
EOM

pip install -U pip
pip install -r requirements.txt
```

# 빌드 (swagger to pdf) 

## openapi

swagger 파일들은 openapi 폴더 아래로 복사한다.
```
(default) [hsseo-go1.24@hsseo-dev0 swagger-to-pdf]$ tree openapi/
openapi/
├── bm-inventory-swagger.yaml
├── bm-provision-swagger.yaml
├── cnf-deplyment-swagger.yaml
├── firmware-api-swagger.yaml
├── job-control-swagger.yaml
├── ocp-provision-swaggerv2.yaml
├── ocp-provision-swagger.yaml
├── switch-control-swagger.yaml
└── switch-provision-swagger.yaml

0 directories, 9 files
(default) [hsseo-go1.24@hsseo-dev0 swagger-to-pdf]$
```

## index.rst

openapi 폴더 밑의 각 swagger 파일들을 등록한다.

```
API 문서
========

.. toctree::
   :maxdepth: 2
   :caption: API 문서


BM Inventory API
--------------------
.. openapi:: openapi/bm-inventory-swagger.yaml
   :encoding: utf-8
   :format: markdown
   :group:

BM Provision API
--------------------
.. openapi:: openapi/bm-provision-swagger.yaml
   :encoding: utf-8
   :format: markdown
   :group:

CNF Provision API
--------------------
.. openapi:: openapi/cnf-deplyment-swagger.yaml
   :encoding: utf-8
   :format: markdown
   :group:

Firmware API
--------------------
.. openapi:: openapi/firmware-api-swagger.yaml
   :encoding: utf-8
   :format: markdown
   :group:

Job Control API
--------------------
.. openapi:: openapi/job-control-swagger.yaml
   :encoding: utf-8
   :format: markdown
   :group:

OCP Provision v2 API
--------------------
.. openapi:: openapi/ocp-provision-swaggerv2.yaml
   :encoding: utf-8
   :format: markdown
   :group:

OCP Provision API
--------------------
.. openapi:: openapi/ocp-provision-swagger.yaml
   :encoding: utf-8
   :format: markdown
   :group:

Switch Control API
--------------------
.. openapi:: openapi/switch-control-swagger.yaml
   :encoding: utf-8
   :format: markdown
   :group:

Switch Provision API
--------------------
.. openapi:: openapi/switch-provision-swagger.yaml
   :encoding: utf-8
   :format: markdown
   :group:
```

## conf.py

한글문제깨짐 문제는 latex_elements 에 한글 폰트를 지정하여 해결한다.

```
project = 'API Documentation'
copyright = '2025'
author = 'API Team'

latex_engine = 'xelatex'

extensions = [
    "sphinxcontrib.openapi",
    "sphinxcontrib.httpdomain",
]

# The master document
master_doc = 'index'


latex_documents = [
    (master_doc, 'api-documentation.tex', 'API Documentation',
     'API Team', 'manual'),
]

# rocky 8.10 기본폰트 사용
# api-noto-sans-serif-cjk-kr.pdf
# latex_elements = {
#     'papersize': 'a4paper',
#     'pointsize': '14pt',
#     'fontpkg': r'''
# \setmainfont{Noto Serif CJK KR}
# \setsansfont{Noto Sans CJK KR}
# \setmonofont{Noto Sans Mono CJK KR}
# ''',
# }

# 나눔폰트사용
# api-namu-gothic-myeongjo-noto-mono-kr.pdf
latex_elements = {
    'papersize': 'a4paper',
    'pointsize': '14pt',
    'fontpkg': r'''
\setmainfont{Nanum Myeongjo}
\setsansfont{Nanum Gothic}
\setmonofont{Noto Sans Mono CJK KR}
''',
}
```

## do build 

아래 build.sh 를 실행한다.
```bash
cat<<'EOM' > build.sh
#!/bin/bash
set -oe pipefail

rm -rf _build

sphinx-build -b latex . _build/latex
# 생성된 .tex를 pdflatex 등으로 컴파일

MAKEFILE="_build/latex/Makefile"

if [ -f "$MAKEFILE" ]; then
  sed -i 's/^LATEX = latexmk/LATEX = latexmk -xelatex -dvi/' $MAKEFILE
  sed -i 's/^PDFLATEX = latexmk/PDFLATEX = latexmk -xelatex -pdf -dvi- -ps-/' $MAKEFILE
fi

pushd _build/latex
make
cp *.pdf ../..
popd

echo "OK"
EOM
chmod +x buld.sh
```