# yum goup 명령어

## yum group 조회

```
dnf group list
```

```
$ dnf group list
Last metadata expiration check: 23:23:28 ago on Tue 26 Aug 2025 01:57:52 PM KST.
Available Environment Groups:
   Server with GUI
   Server
   Minimal Install
   Workstation
   KDE Plasma Workspaces
   Custom Operating System
   Virtualization Host
Available Groups:
   Legacy UNIX Compatibility
   Container Management
   Development Tools
   .NET Core Development
   Graphical Administration Tools
   Headless Management
   Network Servers
   RPM Development Tools
   Scientific Support
   Security Tools
   Smart Card Support
   System Tools
   Fedora Packager
   Xfce
$
```

## yum group 의 패키지 조회 'Server with GUI'

```
dnf group info 'Server with GUI'
```

```
$ dnf group info 'Server with GUI'
Last metadata expiration check: 23:25:38 ago on Tue 26 Aug 2025 01:57:52 PM KST.
Environment Group: Server with GUI
 Description: An integrated, easy-to-manage server with a graphical interface.
 Mandatory Groups:
   Container Management
   GNOME
   Hardware Monitoring Utilities
   Headless Management
   Internet Browser
   Server product core
   base-x
   core
   fonts
   guest-desktop-agents
   hardware-support
   input-methods
   multimedia
   networkmanager-submodules
   print-client
   standard
 Optional Groups:
   Basic Web Server
   DNS Name Server
   Debugging Tools
   FTP Server
   File and Storage Server
   Guest Agents
   Infiniband Support
   Mail Server
   Network File System Client
   Network Servers
   Performance Tools
   Remote Desktop Clients
   Remote Management for Linux
   Virtualization Client
   Virtualization Hypervisor
   Virtualization Tools
   Windows File Server
$
```

## yum group 의 패키지 조회 'GNOME'

```
dnf group info 'GNOME'
```

```
$ dnf group info 'GNOME'
Last metadata expiration check: 23:27:53 ago on Tue 26 Aug 2025 01:57:52 PM KST.

Group: GNOME
 Description: GNOME is a highly intuitive and user-friendly desktop environment.
 Mandatory Packages:
   ModemManager
   NetworkManager-adsl
   PackageKit-command-not-found
   PackageKit-gtk3-module
   at-spi2-atk
   at-spi2-core
   avahi
   baobab
   cheese
   chrome-gnome-shell
   dconf
   eog
   evince
   evince-nautilus
   file-roller
   fprintd-pam
   gdm
   gedit
   glib-networking
   glibc-all-langpacks
   gnome-bluetooth
   gnome-boxes
   gnome-calculator
   gnome-characters
   gnome-classic-session
   gnome-color-manager
   gnome-control-center
   gnome-disk-utility
   gnome-font-viewer
   gnome-getting-started-docs
   gnome-initial-setup
   gnome-logs
   gnome-remote-desktop
   gnome-screenshot
   gnome-session-wayland-session
   gnome-session-xsession
   gnome-settings-daemon
   gnome-shell
   gnome-software
   gnome-system-monitor
   gnome-terminal
   gnome-terminal-nautilus
   gnome-themes-standard
   gnome-user-docs
   gvfs-afc
   gvfs-afp
   gvfs-archive
   gvfs-fuse
   gvfs-goa
   gvfs-gphoto2
   gvfs-mtp
   gvfs-smb
   initial-setup-gui
   libcanberra-gtk3
   librsvg2
   libsane-hpaio
   mesa-dri-drivers
   mousetweaks
   nautilus
   nautilus-sendto
   orca
   polkit
   sane-backends-drivers-scanners
   sushi
   totem
   totem-nautilus
   tracker
   tracker-miners
   vino
   xdg-desktop-portal
   xdg-desktop-portal-gtk
   xdg-user-dirs-gtk
   yelp
   yelp-tools
 Optional Packages:
   gedit-plugins
   gnome-backgrounds
   gnome-shell-extension-disable-screenshield
   gnome-shell-extension-horizontal-workspaces
   gnome-shell-extension-window-grouper
$
```

# yum group 패키지 추출 스크립트

```
cat<<'EOM' > print_grp.sh
#!/bin/bash

set -euo pipefail
LC_ALL=C

# ===== 설정 =====
OUTDIR="groups"
MASTER_OUT="group_rpms.txt"
mkdir -p "$OUTDIR"
: > "$MASTER_OUT"   # 마스터 파일 비우기

# 파일명 안전하게 변환: 소문자, 공백→_, 특수문자 제거, 연속 _ 정리
sanitize() {
  local s="$1"
  s="${s,,}"                       # lower
  s="${s// /_}"                    # spaces -> _
  printf '%s' "$s"
}

# dnf group info에서 패키지 라인만 추출
extract_all_pkgs() {
  # Mandatory / Default / Optional 블록만 켜서, 앞 공백 제거 후 첫 필드 출력
  awk '
    /Mandatory Packages:/ {mode=1; next}
    /Default Packages:/   {mode=1; next}
    /Optional Packages:/  {mode=1; next}
    /[[:alpha:]][^:]*:$/  {mode=0}           # 다음 섹션 헤더(콜론) 만나면 끔
    mode && $0 ~ /^[[:space:]]+/ {
      gsub(/^[ \t]+/, "", $0)
      # 패키지명에 버전/주석이 붙는 경우 대비: 첫 필드만
      split($0, a, /[[:space:]]+/)
      if (a[1] != "") print a[1]
    }
  '
}

extract_pkgs() {
  # Mandatory / Default / Optional 블록만 켜서, 앞 공백 제거 후 첫 필드 출력
  awk '
    /Mandatory Packages:/ {mode=1; next}
    /Default Packages:/   {mode=1; next}
    /[[:alpha:]][^:]*:$/  {mode=0}           # 다음 섹션 헤더(콜론) 만나면 끔
    mode && $0 ~ /^[[:space:]]+/ {
      gsub(/^[ \t]+/, "", $0)
      # 패키지명에 버전/주석이 붙는 경우 대비: 첫 필드만
      split($0, a, /[[:space:]]+/)
      if (a[1] != "") print a[1]
    }
  '
}

extract_all_grps() {
  # Mandatory / Default / Optional 블록만 켜서, 앞 공백 제거 후 첫 필드 출력
  awk '
    /Available Environment Groups:/ {mode=1; next}
    /Installed Groups:/ {mode=1; next}
    /Available Groups:/ {mode=1; next}
    /Mandatory Groups:/ {mode=1; next}
    /Default Groups:/   {mode=1; next}
    /Optional Groups:/  {mode=1; next}
    /[[:alpha:]][^:]*:$/  {mode=0}           # 다음 섹션 헤더(콜론) 만나면 끔
    mode && $0 ~ /^[[:space:]]+/ {
      gsub(/^[ \t]+/, "", $0)
      if ($0 != "") print "GRP:" $0
    }
  '
}

extract_grps() {
  # Mandatory / Default / Optional 블록만 켜서, 앞 공백 제거 후 첫 필드 출력
  awk '
    /Mandatory Groups:/ {mode=1; next}
    /Default Groups:/   {mode=1; next}
    /[[:alpha:]][^:]*:$/  {mode=0}           # 다음 섹션 헤더(콜론) 만나면 끔
    mode && $0 ~ /^[[:space:]]+/ {
      gsub(/^[ \t]+/, "", $0)
      if ($0 != "") print "GRP:" $0
    }
  '
}

# ===== 실행 =====
if [ ! -f "group.txt" ]; then
  dnf group list --hidden | extract_all_grps | sort -u > group.txt
fi
SUB_GRP_LINES=$(cat group.txt | sed -e 's/^GRP://g')

# mapfile 사용
mapfile -t SUB_GRPS <<< "$SUB_GRP_LINES"

for grp in "${SUB_GRPS[@]}"; do
  [[ -n "$grp" ]] || continue

  safe="$(sanitize "$grp")"
  out="$OUTDIR/${safe}.txt"
  echo ">>> [$grp] -> $out"

  # 그룹 정보 가져오기 (일반 그룹이므로 기본적으로 --hidden 불필요하지만 안전하게 시도)
  if [ -f "$out" ]; then
    echo "DEBUG: skip $grp" >&2
    continue
  fi

  if ! info="$(dnf group info "$grp" 2>/dev/null || dnf group info "$grp" --hidden 2>/dev/null)"; then
    echo "WARN: 그룹 정보를 가져올 수 없음: $grp" >&2
    continue
  fi
  : > "$out"

  # 패키지 추출
  pkgs="$(printf '%s\n' "$info" | extract_pkgs | sort -u)"

  if [[ -z "$pkgs" ]]; then
    echo "WARN: 패키지 목록이 비어 있음: $grp" >&2
  else
    printf '%s\n' "$pkgs" >> "$out"
    # 마스터에 누적
    printf '%s\n' "$pkgs" >> "$MASTER_OUT"
  fi

  # 그룹 추출
  pkgs="$(printf '%s\n' "$info" | extract_grps | sort -u)"

  if [[ -z "$pkgs" ]]; then
    echo "WARN: 그룹 목록이 비어 있음: $grp" >&2
    : >> "$out"
  else
    printf '%s\n' "$pkgs" >> "$out"
    # 마스터에 누적
    printf '%s\n' "$pkgs" >> "$MASTER_OUT"
  fi

done

# 마스터 중복 제거
sort -u -o "$MASTER_OUT" "$MASTER_OUT"

echo
echo "완료:"
echo " - 그룹별 파일: $OUTDIR/*.txt"
EOM
```
