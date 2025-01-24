#!/usr/bin/env bash

###############################################################################
# isolcpus에 명시된 CPU 번호를 가져와 각 CPU 번호로 확장하는 함수
# 예: "0,2-4,6" -> "0 2 3 4 6"
###############################################################################
parse_cpu_list() {
  local cpulist="$1"
  local cpus=()
  IFS=',' read -ra parts <<< "$cpulist"
  for part in "${parts[@]}"; do
    # 범위 지정(예: 2-4)
    if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      start=${BASH_REMATCH[1]}
      end=${BASH_REMATCH[2]}
      for ((cpu=$start; cpu<=$end; cpu++)); do
        cpus+=("$cpu")
      done
    else
      # 단일 CPU 번호(예: 0, 6 등)
      cpus+=("$part")
    fi
  done
  echo "${cpus[@]}"
}

###############################################################################
# /proc/cmdline에서 isolcpus 파라미터 추출
###############################################################################
ISOLCPUS="$(sed -n 's/.*isolcpus=\([^ ]*\).*/\1/p' /proc/cmdline)"
if [ -z "$ISOLCPUS" ]; then
  echo "ERROR: /proc/cmdline 내에 isolcpus= 설정이 없습니다."
  exit 1
fi

echo "Found isolcpus: $ISOLCPUS"

# isolcpus 파라미터를 실제 CPU 번호 배열로 확장
ISOLCPUS_ARR=( $(parse_cpu_list "$ISOLCPUS") )
echo "Expanded isolcpus: ${ISOLCPUS_ARR[@]}"

###############################################################################
# 모든 프로세스(PID)에 대해 CPU Affinity 확인 후, isolcpus에 해당하는 태스크 출력
###############################################################################
for pid in $(ls /proc | grep -E '^[0-9]+$'); do
  # /proc/<pid> 디렉토리가 실제 프로세스인지 확인
  if [ -d "/proc/$pid" ]; then
    # taskset을 통해 Affinity 목록을 CPU 번호 리스트 형태로 가져오기
    # 예: "pid 1234's current affinity list: 0-2" -> "0-2"
    AFFINITY="$(taskset -c -p "$pid" 2>/dev/null | awk -F': ' '{print $2}')"

    if [ -n "$AFFINITY" ]; then
      AFFINITY_ARR=( $(parse_cpu_list "$AFFINITY") )

      # 두 리스트의 교집합(공통되는 CPU 번호)이 있는지 확인
      INTERSECT=false
      for iso_cpu in "${ISOLCPUS_ARR[@]}"; do
        for aff_cpu in "${AFFINITY_ARR[@]}"; do
          if [ "$iso_cpu" -eq "$aff_cpu" ]; then
            INTERSECT=true
            break 2
          fi
        done
      done

      # 교집합이 있다면, 해당 PID 및 커맨드 라인 등 정보를 출력
      if $INTERSECT; then
        # /proc/<pid>/cmdline 파일을 통해 커맨드 라인 추출
        CMDLINE="$(tr '\0' ' ' < /proc/$pid/comm 2>/dev/null)"
        echo "PID=$pid, Affinity=$AFFINITY, CMD=$CMDLINE"
      fi
    fi
  fi
done
