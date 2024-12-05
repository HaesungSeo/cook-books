#!/bin/bash

function usage()
{
  echo "Usage: $0 [gen_repo|check_media|gen_media|copy_repo [<src_ver> <dst_ver>]|build_repo|sync_repo <repo> <ver>|fix_perm]"
  echo
  echo "  gen_repo: create *.repo under /etc/yum.repos.d/"
  echo "  check_media: check repo with iso"
  echo "  gen_media: build repo with iso"
  echo "  sync_repo: syncrepo and create repo for ..."
  echo "    <repo>: use one of [$(find /var/www/html/repo/rocky8.7/ -type d -a -maxdepth 1 2>/dev/null \
    | awk -F/ '{print $NF}' | cut -d- -f1 | tr -s '\n' ' ' | sed -e 's/^ \+//g' -e 's/ \+$//g')]"
  echo "    <ver>: 8.7 8.8 8.9 8.10"
  echo "  copy_repo: hard copy repos"
  echo "    <src_ver>: 8.7 8.8 8.9"
  echo "    <dst_ver>: 8.8 8.9 8.10"
  echo "    <src_ver> MUST be greter or euqal to <dst_ver>"
  echo "  build_repo: syncrepo and create repo for all <ver>, <repo>"
  echo "  fix_perm: fixes permissions under /var/www"
}

function copy_media()
{
  # 원본 및 목적지 디렉토리 목록
  local sources=(
  "/media/Rocky8.7/AppStream"
  "/media/Rocky8.7/BaseOS"
  "/media/Rocky8.8/AppStream"
  "/media/Rocky8.8/BaseOS"
  "/media/Rocky8.9/AppStream"
  "/media/Rocky8.9/BaseOS"
  "/media/Rocky/AppStream"
  "/media/Rocky/BaseOS"
  )

  local destinations=(
  "/var/www/html/repo/media-rocky8.7/AppStream"
  "/var/www/html/repo/media-rocky8.7/BaseOS"
  "/var/www/html/repo/media-rocky8.8/AppStream"
  "/var/www/html/repo/media-rocky8.8/BaseOS"
  "/var/www/html/repo/media-rocky8.9/AppStream"
  "/var/www/html/repo/media-rocky8.9/BaseOS"
  "/var/www/html/repo/media-rocky8.10/AppStream"
  "/var/www/html/repo/media-rocky8.10/BaseOS"
  )

  declare -A file_map

  local i=""
  for i in "${!sources[@]}"; do
    local src_dir="${sources[$i]}"
    local dest_dir="${destinations[$i]}"

    echo
    echo "copy $src_dir to $dest_dir ..."

    # 목적지 디렉토리가 없으면 생성
    mkdir -p "$dest_dir"

    # 파일을 찾고 복사/링크
    local files=($(find "$src_dir" -type f))
    local nfile=0
    local src_file=""
    for src_file in "${files[@]}"; do
      let nfile=$nfile+1
      if [ $(("$nfile" % 100)) -eq 0 ]; then
        echo -ne "."
      fi

      # search key
      local file=$(basename $src_file)
      local ext=${file##*\.}
      # 상대 경로 생성
      local relative_path="${src_file#$src_dir/}"
      local dest_file="$dest_dir/$relative_path"

      case $ext in
        rpm)
          # 첫 번째로 발견된 파일은 복사하고 이후 발견된 파일은 하드 링크 생성
          if [ -z "${file_map[$file]}" ]; then
            mkdir -p "$(dirname "$dest_file")"

            if [ ! -f "$dest_file" ]; then sudo cp -f "$src_file" "$dest_file" ; fi

            file_map[$file]="$dest_file"
            #echo "RPM: copy $file to $dest_dir"
          else
            if [ ! -f "$dest_file" ]; then sudo rm -f "$dest_file" ;fi
            local src="${file_map[$file]}"
            sudo ln -f "$src" "$dest_file"
            #echo "RPM: ln -f $src to $dest_dir"
          fi
          ;;
        *)
          sudo cp -f "$src_file" "$dest_file"         # 첫 번째 파일 복사
          #echo "copy $file to $dest_dir"
          ;;
      esac
    done
  done
}

function check_media()
{
  # 원본 및 목적지 디렉토리 목록
  local sources=(
  "/media/Rocky8.7/AppStream"
  "/media/Rocky8.7/BaseOS"
  #"/media/Rocky8.8/AppStream"
  #"/media/Rocky8.8/BaseOS"
  #"/media/Rocky8.9/AppStream"
  #"/media/Rocky8.9/BaseOS"
  "/media/Rocky/AppStream"
  "/media/Rocky/BaseOS"
  )

  local destinations=(
  "/var/www/html/repo/media-rocky8.7/AppStream"
  "/var/www/html/repo/media-rocky8.7/BaseOS"
  #"/var/www/html/repo/media-rocky8.8/AppStream"
  #"/var/www/html/repo/media-rocky8.8/BaseOS"
  #"/var/www/html/repo/media-rocky8.9/AppStream"
  #"/var/www/html/repo/media-rocky8.9/BaseOS"
  "/var/www/html/repo/media-rocky8.10/AppStream"
  "/var/www/html/repo/media-rocky8.10/BaseOS"
  )

  declare -A file_map

  local i=""
  for i in "${!sources[@]}"; do
    local src_dir="${sources[$i]}"
    local dest_dir="${destinations[$i]}"

    # /media/Rocky8.7/AppStream -> Rocky8.7-AppStream
    local src1=$(echo $src_dir | cut -d'/' -f2- | sed -e 's/\//-/g')
    local dst1=$(echo $dest_dir | cut -d'/' -f2- | sed -e 's/\//-/g')
    local src_list="build/.$src1.list"
    local dst_list="build/.$dst1.list"
    local diff_list="build/$src1.diff"

    echo -ne "diff $src_dir $dest_dir > $diff_list ... "

    find "$src_dir" -type f -a -name "*.rpm" | awk -F/ '{print $NF}' | sort | uniq > "$src_list"
    find "$dest_dir" -type f -a -name "*.rpm" | awk -F/ '{print $NF}' | sort | uniq > "$dst_list"
    diff -Naur "$src_list" "$dst_list" > "$diff_list"
    rm -f "$src_list" "$dst_list"
    if [ ! -s "$diff_list" ]; then
      echo -ne "SAME\n"
    else
      echo -ne "DIFF\n"
      cat "$diff_list" | grep "^+\|^-"
      echo
    fi
  done
}

function gen_media()
{
  echo "mount iso v8.10"
  sudo mkdir -p /media/Rocky
  local ISO="/opt/Rocky-8.10-x86_64-dvd1.iso"
  if [ ! -f "$ISO" ]; then echo "ERROR: $ISO: not found"; exit 1 ; fi
  sudo mount -t iso9660 "$ISO" /media/Rocky
  local ver=""
  for ver in "8.7" "8.8" "8.9"
  do
    echo "create iso repo v$ver"
    sudo mkdir -p /media/Rocky$ver
    ISO="/opt/Rocky-$ver-x86_64-dvd1.iso"
    if [ ! -f "$ISO" ]; then echo "ERROR: $ISO: not found"; exit 1 ; fi
    sudo mount -t iso9660 "$ISO" /media/Rocky$ver
  done

  echo "copy iso to /var/www/html/repo/"
  copy_media

  echo "createrepo"
  local COMPS_APPSTREAM=$(sudo find /media/Rocky/AppStream -name "*-comps-*.xml" | grep comps-AppStream)
  local COMPS_BASEOS=$(sudo find /media/Rocky/BaseOS -name "*-comps-*.xml" | grep comps-BaseOS)
  sudo createrepo_c --update --workers 5 --no-database \
    -g "$COMPS_APPSTREAM" \
    /var/www/html/repo/media-rocky8.10/AppStream
  sudo createrepo_c --update --workers 5 --no-database \
    -g "$COMPS_BASEOS" \
    /var/www/html/repo/media-rocky8.10/BaseOS

  for ver in "8.7" "8.8" "8.9"
  do
    echo "createrepo with comps.xml repo v$ver"
    COMPS_APPSTREAM=$(sudo find /media/Rocky$ver/* -name "*-comps-*.xml" | grep comps-AppStream)
    COMPS_BASEOS=$(sudo find /media/Rocky$ver/* -name "*-comps-*.xml" | grep comps-BaseOS)
    sudo createrepo_c --update --workers 5 --no-database \
      -g "$COMPS_APPSTREAM" \
      /var/www/html/repo/media-rocky$ver/AppStream
    sudo createrepo_c --update --workers 5 --no-database \
      -g "$COMPS_BASEOS" \
      /var/www/html/repo/media-rocky$ver/BaseOS
  done
}

function gen_repo()
{
  local ver=""
  for ver in "8.7" "8.8" "8.9"
  do
    echo "##### build appstream-$ver.repo"
    cat<<EOM > build/appstream-$ver.repo
[appstream-$ver]
name=Rocky Linux $ver - AppStream
baseurl=https://dl.rockylinux.org/vault/rocky/$ver/AppStream/\$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOM
    sudo cp build/appstream-$ver.repo /etc/yum.repos.d/

    echo "##### build baseos-$ver.repo"
    cat<<EOM > build/baseos-$ver.repo
[baseos-$ver]
name=Rocky Linux $ver - BaseOS
baseurl=https://dl.rockylinux.org/vault/rocky/$ver/BaseOS/\$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOM
    sudo cp build/baseos-$ver.repo /etc/yum.repos.d/

    echo "##### build extras-$ver.repo"
    cat<<EOM > build/extras-$ver.repo
[extras-$ver]
name=Rocky Linux $ver - extras
baseurl=https://dl.rockylinux.org/vault/rocky/$ver/extras/\$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOM
    sudo cp build/extras-$ver.repo /etc/yum.repos.d/

    echo "##### build powertools-$ver.repo"
    cat<<EOM > build/powertools-$ver.repo
[powertools-$ver]
name=Rocky Linux $ver - PowerTools
baseurl=https://dl.rockylinux.org/vault/rocky/$ver/PowerTools/\$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOM
    sudo cp build/powertools-$ver.repo /etc/yum.repos.d/
  done

  ver="8.10"

  cat<<EOM > build/appstream-$ver.repo
[appstream-$ver]
name=Rocky Linux $ver - AppStream
baseurl=http://dl.rockylinux.org/\$contentdir/8/AppStream/\$basearch/os/
gpgcheck=1
enabled=0
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOM
  sudo cp build/appstream-$ver.repo /etc/yum.repos.d/

  cat<<EOM > build/baseos-$ver.repo
[baseos-$ver]
name=Rocky Linux $ver - BaseOS
baseurl=http://dl.rockylinux.org/\$contentdir/8/BaseOS/\$basearch/os/
gpgcheck=1
enabled=0
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOM
  sudo cp build/baseos-$ver.repo /etc/yum.repos.d/

  cat<<EOM > build/extras-$ver.repo
[extras-$ver]
name=Rocky Linux $ver - Extras
baseurl=http://dl.rockylinux.org/\$contentdir/8/extras/\$basearch/os/
gpgcheck=1
enabled=0
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOM
  sudo cp build/extras-$ver.repo /etc/yum.repos.d/

  cat<<EOM > build/powertools-$ver.repo
[powertools-$ver]
name=Rocky Linux $ver - Extras
baseurl=http://dl.rockylinux.org/\$contentdir/8/PowerTools/\$basearch/os/
gpgcheck=1
enabled=0
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOM
  sudo cp build/powertools-$ver.repo /etc/yum.repos.d/

  cat<<EOM > build/local-epel.repo
[local-epel]
name=Extra Packages for Enterprise Linux 8.10 - Local repo
baseurl=file:///var/www/html/repo/epel
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOM
  sudo cp build/local-epel.repo /etc/yum.repos.d/
}

function sync_repo()
{
  REPO="$1"
  VER="$2"
  case $REPO in
    epel)
      REPOID="$REPO"
      REPO_TOP="/var/www/html/repo"
      ;;
    appstream|baseos|extras|powertools)
      if [ ! -n "$VER" ]; then
        usage 
        exit 1
      fi
      REPO_TOP="/var/www/html/repo/rocky$VER"
      REPOID="$REPO-$VER"
      ;;
    *)
      usage 
      exit 1
      ;;
  esac

  # e.g. 
  # VER=8.7
  # REPO=appstream
  # REPO_TOP="/var/www/html/repo/rocky8.7"
  # FINAL_DIR="/var/www/html/repo/rocky8.7/appstream-8.7"

  mkdir -p "$REPO_TOP"
  mkdir -p "build"

  echo "reposync $REPOID"
  sudo reposync --repoid=$REPOID --delete --downloadcomps --download-metadata --download-path="$REPO_TOP"

  FILE_COMPS=$(find $REPO_TOP/$REPO -name "*$REPO-comps.xml" 2>/dev/null)
  if [ -n "$FILE_COMPS" ]; then
    OPT_GRP="-g $FILE_COMPS"
    echo "createrepo $REPO, with [$OPT_GRP]"
  else
    OPT_GRP=""
    echo "createrepo $REPO"
  fi
  sudo createrepo_c --update --workers 5 --no-database \
    $OPT_GRP "$REPO_TOP/$REPOID"
}

function ver_cmp()
{
  v1="$1"
  v2="$2"
  v1mar="$(echo $v1 | cut -d'.' -f1)"
  v1min="$(echo $v1 | cut -d'.' -f2)"
  v2mar="$(echo $v2 | cut -d'.' -f1)"
  v2min="$(echo $v2 | cut -d'.' -f2)"
  if [ "$v1mar" -lt "$v2mar" ]; then
    echo "-1"
  elif [ "$v1mar" -gt "$v2mar" ]; then
    echo "1"
  else
    if [ "$v1min" -lt "$v2min" ]; then
      echo "-1"
    elif [ "$v1min" -eq "$v2min" ]; then
      echo "0"
    elif [ "$v1min" -gt "$v2min" ]; then
      echo "1"
    fi
  fi
}

function hard_copy()
{
  # e.g. 
  # sources=(
  # "/var/www/html/repo/rocky$src_ver/appstream-$src_ver"
  # "/var/www/html/repo/rocky$src_ver/baseos-$src_ver"
  # "/var/www/html/repo/rocky$src_ver/epel-$src_ver"
  # "/var/www/html/repo/rocky$src_ver/extras-$src_ver"
  # )
  # destinations=(
  # "/var/www/html/repo/rocky$dst_ver/appstream-$dst_ver"
  # "/var/www/html/repo/rocky$dst_ver/baseos-$dst_ver"
  # "/var/www/html/repo/rocky$dst_ver/epel-$dst_ver"
  # "/var/www/html/repo/rocky$dst_ver/extras-$dst_ver"
  # )
  local -n src1=$1
  local -n dst1=$2

  local i=""
  for i in "${!src1[@]}"; do
    local src_dir="${src1[$i]}"
    local dest_dir="${dst1[$i]}"

    echo "hard copy $src_dir to $dest_dir ..."
    sudo find "$src_dir/" -type d -exec sudo sh -c 'mkdir -p "$0/${1#"$2/"}"' "$dest_dir" '{}' "$src_dir" \;
    echo "  remove first ..."
    sudo find "$src_dir/" -type f -a -name "*.rpm" -exec sudo sh -c 'rm -f "$0/${1#"$2/"}"' "$dest_dir" '{}' "$src_dir" \;
    echo "  hard copy ..."
    sudo find "$src_dir/" -type f -a -name "*.rpm" -exec sudo sh -c 'ln "$1" "$0/${1#"$2/"}"' "$dest_dir" '{}' "$src_dir" \;
  done
}

function build_repo()
{
  gen_repo

  sync_repo epel

  local src_ver=""
  local dst_ver=""
  #run out of disk free spaces
  #for src_ver in "8.7" "8.8" "8.9"
  for src_ver in "8.7" "8.10"
  do
    sync_repo appstream  $src_ver
    sync_repo baseos     $src_ver
    sync_repo extras     $src_ver
    sync_repo powertools $src_ver

    local sources=(
    "/var/www/html/repo/rocky$src_ver/appstream-$src_ver"
    "/var/www/html/repo/rocky$src_ver/baseos-$src_ver"
    "/var/www/html/repo/rocky$src_ver/extras-$src_ver"
    "/var/www/html/repo/rocky$src_ver/powertools-$src_ver"
    )

    for dst_ver in "8.10"
    do

      # break, if src_ver >= dst_ver
      RET="$(ver_cmp $src_ver $dst_ver)"
      case "$RET" in
        "0"|"1")
          continue
          ;;
        *)
          ;;
      esac

      local destinations=(
      "/var/www/html/repo/rocky$dst_ver/appstream-$dst_ver"
      "/var/www/html/repo/rocky$dst_ver/baseos-$dst_ver"
      "/var/www/html/repo/rocky$dst_ver/extras-$dst_ver"
      "/var/www/html/repo/rocky$dst_ver/powertools-$dst_ver"
      )

      echo "copy_repo $src_ver $dst_ver"
      hard_copy sources destinations

      # do hard copy only to the very next version only
      break;
    done
  done
}

function copy_repo()
{
  local src_ver="$1"
  local dst_ver="$2"

  if [ -n "$src_ver" -a -n "$dst_ver" ]; then

    # return, if src_ver >= dst_ver
    RET="$(ver_cmp $src_ver $dst_ver)"
    case "$RET" in
      "0"|"1")
        return
        ;;
      *)
        ;;
    esac

    local sources=(
    "/var/www/html/repo/rocky$src_ver/appstream-$src_ver"
    "/var/www/html/repo/rocky$src_ver/baseos-$src_ver"
    "/var/www/html/repo/rocky$src_ver/extras-$src_ver"
    "/var/www/html/repo/rocky$src_ver/powertools-$src_ver"
    )

    local destinations=(
    "/var/www/html/repo/rocky$dst_ver/appstream-$dst_ver"
    "/var/www/html/repo/rocky$dst_ver/baseos-$dst_ver"
    "/var/www/html/repo/rocky$dst_ver/extras-$dst_ver"
    "/var/www/html/repo/rocky$dst_ver/powertools-$dst_ver"
    )

    echo "copy_repo $src_ver $dst_ver"
    hard_copy sources destinations

    return
  fi

  for src_ver in "8.7" "8.8" "8.9"
  do
    local sources=(
    "/var/www/html/repo/rocky$src_ver/appstream-$src_ver"
    "/var/www/html/repo/rocky$src_ver/baseos-$src_ver"
    "/var/www/html/repo/rocky$src_ver/extras-$src_ver"
    "/var/www/html/repo/rocky$src_ver/powertools-$src_ver"
    )

    for dst_ver in "8.8" "8.9" "8.10"
    do

      # break, if src_ver >= dst_ver
      RET="$(ver_cmp $src_ver $dst_ver)"
      case "$RET" in
        "0"|"1")
          continue
          ;;
        *)
          ;;
      esac

      local destinations=(
      "/var/www/html/repo/rocky$dst_ver/appstream-$dst_ver"
      "/var/www/html/repo/rocky$dst_ver/baseos-$dst_ver"
      "/var/www/html/repo/rocky$dst_ver/extras-$dst_ver"
      "/var/www/html/repo/rocky$dst_ver/powertools-$dst_ver"
      )

      echo "copy_repo $src_ver $dst_ver"
      hard_copy sources destinations
    done
  done
}


function fix_perm()
{
  sudo chown -R apache:apache /var/www
  sudo restorecon -Rv /var/www/html/repo/
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

CMD="$1"
shift

case $CMD in
  b*|build_repo)
    build_repo
    ;;
  ch*|check_media)
    check_media
    ;;
  co*|copy_repo)
    copy_repo $*
    ;;
  f*|fix_perm)
    fix_perm
    ;;
  gen_m*|gen_media)
    gen_media
    ;;
  gen_r*|gen_repo)
    gen_repo
    ;;
  s*|sync_repo)
    sync_repo $*
    ;;
  *)
    usage
    exit 1
    ;;
esac
