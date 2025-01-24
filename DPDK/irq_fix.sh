#!/bin/bash
# chkconfig: - 99 99
# VERSION 1.6
# - add print_affinity
# VERSION 1.5
# - fix vhost_corelist function
# VERSION 1.4

# - add show_irq_all
# VERSION 1.3
# - add virtio_irq
# VERSION 1.2
# - irq_affinity always print format as '%08x,%08x"
# - check existance of /sys/class/net/eth0/device/msi_irqs/
# VERSION 1.1
# - nic_irq_corelist -> nic_single_core_per_irq
# - add nic_coremask_per_irq
# VERSION 1.0

function usage()
{
  echo "Usage: $0 [help] (coremask ...|fix ...|hex <n>|int <n>|load ..."
  echo "        |nicfix ...|irqfix ...|nicshow|rr|virtfix ...|save ...|show ...)"
  echo
  echo "  corelist <core list>"
  echo "    <core list>: ' ' seperated integer list, e.g. '0 1 2 3'"
  echo "  fix <core list>, fix affinity of all irq(s) to <core list>"
  echo "  hex <n>, <n>: integer"
  echo "  int <n>, <n>: integer"
  echo "  irqfix <irq> <core list>, fix affinity of irq <irq> to <core list>"
  echo "  load [<file>], <file>: file producted by save [<file>]"
  echo "  rr <core list>, fix affinity of irq from the round robin core of <core-list>"
  echo "  rrnicfix <nic> <core list>, fix affinity of nic <nic> from the round robin core of <core-list>"
  echo "  nicfix <nic> <core list>, fix affinity of nic <vnic> to <core list>"
  echo "  nicfix, fix affinity of all nics to nic's local_cpulist"
  echo "  save [<file>], <file>: save file"
  echo "  show [<n>], <n>: irq number"
  echo "  virtfix <virtio nic> <core list>, fix affinity of nic <virtio nic> to <core list>"
}

VERBOSE=0
function quiet()
{
  if [ "$VERBOSE" -eq 0 ]; then
    $* > /dev/null
  else
    $*
  fi
}

# $1 = core numbers from 0
function hex_mask()
{
  local ii=0
  local val=1

  if [ "$1" -gt 62 2> /dev/null ]; then
    echo "ERROR: $1 too big"
    exit 1
  fi

  while [ "$ii" -lt "$1" ];
  do
    let val=$val*2;
    let ii=$ii+1
  done

  printf "%08x" $val
}

# convert bit pos to value
# $1 - bit pos from 0
function int_mask()
{
  local ii=0
  local val=1

  if [ "$1" -gt 62 2> /dev/null ]; then
    echo "ERROR: $1 too big"
    exit 1
  fi

  while [ "$ii" -lt "$1" ];
  do
    let val=$val*2;
    let ii=$ii+1
  done

  printf "%d" $val
}

# print comma seperated hexa decimal number
function print_affinity()
{
  local MASK="$*"
  local addr=""
  local RET=""
  local sep=""

  # e.g. 00,00007000 00000000,00007000
  MASK=${MASK//,/ }
  for addr in $MASK; do
    # remove leading 0, add 0x
    addr="${addr##0x}"
    addr="${addr##0X}"
    addr="${addr##0}"
    addr="0x$addr"

    RET="$RET$sep$(printf "%08x" $addr)"
    sep=","
  done
  echo "$RET"
}

# print irq affinity
# $1 - irq number (base10 integer)
function irq_affinity()
{
  local IRQN="$1"
  local IRQ_STR="`cat /proc/irq/$IRQN/smp_affinity`"

  print_affinity "$IRQ_STR"
}

# print hexa value for list of integers
# $1 - integer list. e.g. '0 1 3 5'
# e.g. print '2f' for '0 1 3 5'
function mask_from_core_list()
{
  local CORELIST="$*"
  local CORELIST_OLD
  local RCORELIST
  local cpu
  local MASK=()
  local idx
  local r
  local val
  local xval

  if [ ! -n "$CORELIST" ]; then
    return
  fi

  # sort
  CORELIST="$(echo "$CORELIST" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')"
  CORELIST_OLD="${CORELIST%% }"

  # initialize array MASK
  RCORELIST=$(echo "$CORELIST" | tr ' ' '\n' | sort -r | uniq | tr '\n' ' ')
  lval=$(($(echo $RCORELIST | cut -d ' ' -f1) / 32))
  for idx in $(seq 0 $lval)
  do
    MASK[$idx]=0
  done

  while [ -n "$CORELIST" ]; do
    cpu="`echo $CORELIST | cut -d ' ' -f 1`"
    CORELIST="`echo $CORELIST | cut -d ' ' -f 2-`"

    if [ ! -n "$cpu" ];then break; fi

    idx=$(($cpu / 32))
    r=$(($cpu % 32))
    MASK[$idx]=$((${MASK[$idx]} + $(int_mask $r)))

    if [ "$CORELIST" = "$CORELIST_OLD" ]; then
      break;
    fi
    CORELIST_OLD="${CORELIST%% }"
  done

  xval=""
  r=""
  for val in ${MASK[@]}
  do
    xval="$(printf "%08x" $val)$r$xval"
    r=","
  done
  xval=${xval##0}
  echo $xval

  #printf "%08x,%08x" $RET_L $RET_R
}

# set irq core mask from input core list
# $1 - irq number
# $2 - smp_affinity
function irq_fix()
{
  local IRQN="$1"
  shift
  local MASK_NEW="$*"
  local MASK_BEFORE
  local MASK_AFTER
  local IRQN

  if [ ! -n "$IRQN" ]; then
    return
  fi

  if [ -f /proc/irq/$IRQN/smp_affinity ]; then
    MASK_BEFORE=$(irq_affinity $IRQN)
    if [ "$MASK_NEW" != "$MASK_BEFORE" ]; then
      echo $MASK_NEW > /proc/irq/$IRQN/smp_affinity 2> /dev/null
      MASK_AFTER=$(irq_affinity $IRQN)
      if [ "$MASK_NEW" != "$MASK_AFTER" ]; then
        if [ "$MASK_BEFORE" != "$MASK_AFTER" ]; then
          echo "ERROR: IRQ $(printf "%4d" $IRQN) [$MASK_BEFORE -> $MASK_NEW, NOW $MASK_AFTER ] not work!" >&2
        else
          echo "ERROR: IRQ $(printf "%4d" $IRQN) [$MASK_BEFORE -> $MASK_NEW ] not work!" >&2
        fi
      else
        quiet echo "IRQ $(printf "%4d" $IRQN) [$MASK_BEFORE -> $MASK_AFTER]"
      fi
    else
      quiet echo "IRQ $(printf "%4d" $IRQN) [$MASK_BEFORE, no change]"
    fi
  fi
}

# set irq core mask from input core list
# $1 - integer list. e.g. '0 1 3 5'
function irq_fix_all()
{
  local CORELIST="$*"
  local IRQ_AFFINITY

  IRQ_AFFINITY=$(mask_from_core_list $CORELIST)

  for IRQN in $(ls /proc/irq/)
  do
    irq_fix $IRQN $IRQ_AFFINITY
  done
}

# set irq core mask from save file 
function irq_load()
{
  local IRQN
  local IRQ_AFFINITY
  while read IRQN IRQ_AFFINITY
  do
    if [ ! -f /proc/irq/$IRQN/smp_affinity ]; then
      continue
    fi
    irq_fix $IRQN $IRQ_AFFINITY
  done
}

# set virtio irq core mask from input core list
# $1 - virtio device name
# $2 - integer list. e.g. '0 1 3 5'
function virtio_irq()
{
  local VIRIO_NAME="$1"
  shift
  local CORELIST="$*"
  local IRQN
  local IRQ_AFFINITY

  IRQN="`cat /proc/interrupts 2>/dev/null | grep $VIRIO_NAME | tr -d ':' | cut -d ' ' -f 2`"
  if [ ! -n "$IRQN" ]; then
    return
  fi
  echo "$VIRIO_NAME IRQ=$IRQN"

  IRQ_AFFINITY=$(mask_from_core_list $CORELIST)

  irq_fix $IRQN $IRQ_AFFINITY
}

function show_irq_all()
{
  local CORELIST="$*"
  local IRQN
  local MASK_NOW

  for IRQN in $(ls /proc/irq/)
  do
    if [ -f /proc/irq/$IRQN/smp_affinity ]; then
      MASK_NOW=$(irq_affinity $IRQN)
      echo "IRQ $(printf "%4d" $IRQN) [$MASK_NOW]"
    fi
  done
}

# set single core for each irq core mask from input core list
# for each irq, 
# the core number is chosen round robin from the core list
# $1 - integer list. e.g. '0 1 3 5'
function single_core_per_irq()
{
  local CORELIST="$*"
  local CORELIST_OLD
  local CORELIST_SAVE
  local IRQ_AFFINITY
  local IRQN
  local cpu

  if [ ! -n "$CORELIST" ]; then
    return
  fi

  # sort
  CORELIST=$(echo "$CORELIST" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')
  CORELIST_OLD="${CORELIST%% }"
  CORELIST_SAVE="${CORELIST%% }"

  for IRQN in $(ls /proc/irq/)
  do
    cpu="`echo $CORELIST | cut -d ' ' -f 1`"
    CORELIST="`echo $CORELIST | cut -d ' ' -f 2-`"

    if [ ! -n "$cpu" ];then break; fi

    IRQ_AFFINITY="$(mask_from_core_list $cpu)"

    irq_fix $IRQN $IRQ_AFFINITY

    # wrap around CPUS
    if [ "$CORELIST" = "$CORELIST_OLD" ]; then
      CORELIST="$CORELIST_SAVE"
    fi
    CORELIST_OLD="${CORELIST%% }"
  done
}

# set single core for each nic irq core mask from input core list
# for each nic irq, 
# the core number is chosen round robin from the core list
# $1 - nic device name
# $2 - integer list. e.g. '0 1 3 5'
function nic_single_core_per_irq()
{
  # nic: ens1f0
  # CORELIST: 0 1 2
  local nic=$1
  shift
  local CORELIST="$*"
  local CORELIST_OLD
  local CORELIST_SAVE
  local IRQ_AFFINITY
  local IRQN
  local cpu

  if [ ! -n "$nic" ]; then
    return
  fi
  
  if [ ! -n "$CORELIST" ]; then
    return
  fi

  # sort
  CORELIST=$(echo "$CORELIST" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')
  CORELIST_OLD="${CORELIST%% }"
  CORELIST_SAVE="$CORELIST"

  echo "$nic CORES=$CORELIST"

  ip link set $nic up

  for IRQN in $(ls /sys/class/net/$nic/device/msi_irqs/ 2>/dev/null)
  do
    cpu="`echo $CORELIST | cut -d ' ' -f 1`"
    CORELIST="`echo $CORELIST | cut -d ' ' -f 2-`"

    if [ ! -n "$cpu" ];then break; fi

    IRQ_AFFINITY="$(mask_from_core_list $cpu)"

    irq_fix $IRQN $IRQ_AFFINITY

    # wrap around CPUS
    if [ "$CORELIST" = "$CORELIST_OLD" ]; then
      CORELIST="$CORELIST_SAVE"
    fi
    CORELIST_OLD="${CORELIST%% }"
  done
}

# set nic irq core mask from input core list
# $1 - nic device name
# $2 - integer list. e.g. '0 1 3 5'
function nic_coremask_per_irq()
{
  # nic: ens1f0
  # CORELIST: 0 1 2
  local nic=$1
  local NIC_EXIST
  shift
  local CORELIST="$*"
  local IRQ_AFFINITY
  local IRQN

  if [ ! -n "$nic" ]; then
    return
  fi
  NIC_EXIST=$(ip link list $nic 2>/dev/null)
  if [ ! -n "NIC_EXIST" ]; then
    echo "ERROR: $nic not found"
    return
  fi
  
  if [ ! -n "$CORELIST" ]; then
    return
  fi

  echo "$nic CORES=$CORELIST"

  # sort
  CORELIST=$(echo "$CORELIST" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')

  IRQ_AFFINITY=$(mask_from_core_list $CORELIST)

  ip link set $nic up

  for IRQN in $(ls /sys/class/net/$nic/device/msi_irqs/ 2>/dev/nul)
  do
    irq_fix $IRQN $IRQ_AFFINITY
  done
}

function irq_fix_for_all_nic()
{
  local nic
  local LOCAL_CPULIST
  local ARRAY
  local CORES
  local RANGE
  local FIRST_CORE

  for nic in $(ls /sys/class/net)
  do
    if [ ! -f /sys/class/net/$nic/device/local_cpulist ]; then
      continue;
    fi

    if [ ! -d /sys/class/net/$nic/device/msi_irqs ]; then
      continue;
    fi

    LOCAL_CPULIST="`cat /sys/class/net/$nic/device/local_cpulist | tr ' ' '-' | tr ',' ' '`"
    # LOCAL_CPULIST="0-11 24-35"
    ARRAY=( $LOCAL_CPULIST )
    CORES=""
    for RANGE in "${ARRAY[@]}"; do
      # RANGE="0-11"
      if [ -n "$CORES" ]; then
        CORES="$CORES $(seq `echo $RANGE | tr '-' ' '` | tr '\n' ' ')"
      else
        CORES="$(seq `echo $RANGE | tr '-' ' '` | tr '\n' ' ')"
      fi
    done
    FIRST_CORE="`echo $CORES | cut -d ' ' -f 1`"

    #nic_single_core_per_irq $nic "$CORES"
    nic_single_core_per_irq $nic "$FIRST_CORE"
  done
}

function show_irq_all_nic()
{
  local nic
  local IRQN
  local MASK_NOW

  for nic in $(ls /sys/class/net)
  do
    if [ ! -f /sys/class/net/$nic/device/local_cpulist ]; then
      continue;
    fi

    if [ ! -d /sys/class/net/$nic/device/msi_irqs ]; then
      continue;
    fi

    for IRQN in $(ls /sys/class/net/$nic/device/msi_irqs/ 2>/dev/null)
    do
      if [ -f /proc/irq/$IRQN/smp_affinity ]; then
        MASK_NOW=$(irq_affinity $IRQN)
        echo "NIC $nic IRQ $(printf "%4d" $IRQN) [$MASK_NOW]"
      fi
    done
  done
}

function vswitchd_corelist()
{
  local OVS_VSWITCHD_CORE="$1"
  local OPIN
  local NPIN
  local PID

  PID="`pidof ovs-vswitchd`"
  if [ -n "$PID" ]; then
    OPIN=$(printf "%08d" "`taskset -p $PID | awk '{print $6}'`")
    if [ $(hex_mask $OVS_VSWITCHD_CORE) != "$OPIN" ]; then
      taskset -pc $OVS_VSWITCHD_CORE $PID 2>&1 > /dev/null
      NPIN="`taskset -p $PID | awk '{print $6}'`"
      NPIN=$(printf "%08d" $NPIN)
      if [ $(hex_mask $OVS_VSWITCHD_CORE) != "$NPIN" ]; then
        echo "ERROR: ovs-vswitchd($PID) CPU $OVS_VSWITCHD_CORE [$NPIN -> " $(hex_mask $OVS_VSWITCHD_CORE)
      else
        echo "ovs-vswitchd($PID) CPU $OVS_VSWITCHD_CORE [$OPIN -> $NPIN]"
      fi
    else
      echo "ovs-vswitchd($PID) CPU $OVS_VSWITCHD_CORE [$OPIN]"
    fi

  else
    echo "ovs-vswitchd not running."
  fi
}

function vhost_corelist()
{
  # FIRST for kvm name
  # REST CORELIST for vhost-xxxx kernel threads
  # e.g. vm1-pmd 2 3
  # map vhost-xxxx kernel thread's cpu affinity to vm1-pmd's 2nd and 3rd cpu affinity
  local VM_NAME="$1"
  shift
  local CORELIST="$*"
  local CORELIST_OLD="$*"
  local CORELIST_SAVE="$*"
  local thiscore
  local HOST_CORE
  local OPIN
  local NPIN
  local PID
  local QEMU_PID

  QEMU_PID=`ps aux | grep "qemu-system-x86_64 \-name $VM_NAME" | cut -d ' ' -f 1`

  for PID in $(pidof vhost-$QEMU_PID)
  do
    thiscore="`echo $CORELIST | cut -d ' ' -f 1`"
    HOST_CORE=`virsh vcpupin $VM_NAME | grep "$thiscore:" | tr -s ' ' | cut -d ' ' -f 3`
    CORELIST="`echo $CORELIST | cut -d ' ' -f 2-`"

    OPIN="`taskset -p $PID | awk '{print $6}'`"
    taskset -pc $HOST_CORE $PID 2>&1 > /dev/null
    NPIN="`taskset -p $PID | awk '{print $6}'`"

    if [ "$OPIN" != "$NPIN" ]; then
      echo "vhost-$PID CPU $(printf "%2d" $HOST_CORE) [$OPIN -> $NPIN] not work!" >&2
    else
      echo "vhost-$PID CPU $(printf "%2d" $HOST_CORE) [$OPIN -> $NPIN]"
    fi

    # wrap around CPUS
    if [ "$CORELIST" = "$CORELIST_OLD" ]; then
      CORELIST="$CORELIST_SAVE"
    fi
    CORELIST_OLD="$CORELIST"
  done
}

CMD=$1
shift
case $CMD in
  c|corelist)
  mask_from_core_list $*
  ;;
  f|fix)
  irq_fix_all $*
  ;;
  hex)
  hex_mask $*
  ;;
  int)
  int_mask $*
  ;;
  irqfix)
  irq_fix $*
  ;;
  load)
  irq_load
  ;;
  ns|nicshow)
  show_irq_all_nic 
  ;;
  nf|nicfix)
  if [ -n "$1" ]; then
    nic_coremask_per_irq $*
  else
    irq_fix_for_all_nic
  fi
  ;;
  rrn|rrnicfix)
  nic_single_core_per_irq $*
  ;;
  r|rr)
  single_core_per_irq $*
  ;;
  save)
  show_irq_all | sed -e 's/^IRQ \|\[\|\]//g'
  ;;
  s|show)
  if [ -n "$1" ]; then
    irq_affinity $1
  else
    show_irq_all
  fi
  ;;
  v|virtfix)
  virtio_irq $*
  ;;
  h|help|-h|--h|--help)
  usage
  exit 1
  ;;
  *)
  ;;
esac
