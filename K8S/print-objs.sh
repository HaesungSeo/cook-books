#!/bin/bash

function usage()
{
  echo "Usage: $0 [<namespace> ...]"
  echo "generate json file for k8s objects in <namespace>"
  echo "  path: <ns>/<obj>.json"
}

function get_k8s_crd()
{
  crds=$(kubectl get crd --show-kind -o name | cut -d'/' -f 2 | sort | uniq | tr '\n' ' ')
  # TOT <- get total number of crds
  read -r -a ncrds <<< "$crds"
  TOT="${#ncrds[@]}"
  NOW=0
  mkdir -p "./objs/crds/"
  for crd in $crds
  do
    let NOW=$NOW+1
    CRD="./objs/crds/${crd}.yaml"
    echo -n "extract crd $crd ($NOW/$TOT) ... "
    if [ -f "$CRD" ]; then
      echo -en ", already exists\n"
      continue
    fi
    echo -en ", generate\n"
    kubectl get crd $crd -o yaml > "$CRD"
  done
}

obj_exclude="customresourcedefinitions.apiextensions.k8s.io"
function get_k8s_objs()
{
  SAVE_SUFFIX="$1"
  NS_OPT="$2"
  otypes="$(kubectl api-resources --verbs=list -o name | grep -v "$obj_exclude" | tr '\n' ' ')"
  # TOT <- get total number of otypes
  read -r -a notypes <<< "$otypes"
  TOT="${#notypes[@]}"
  NOW=0
  mkdir -p "./objs${SAVE_SUFFIX}"
  for t in $otypes
  do
    let NOW=$NOW+1
    JSON="./objs${SAVE_SUFFIX}$t.json"
    YAML="./objs${SAVE_SUFFIX}$t.yaml"
    echo -n "extract $t ($NOW/$TOT) ..."
    if [ -f "$JSON" -a -f "$YAML" ]; then
      # skip, already exists!
      echo -en ", already exists\n"
      continue
    fi
    kubectl get "$NS_OPT" "$t" -o json 2>/dev/null > "$JSON"
    items=$(cat "$JSON" | jq -c -r '.items | length')
    if [ -n $items -a "$items" -eq "0" ]; then
      # remove empty
      echo -en ", empty\n"
      rm -f "$JSON"
    else
      echo -en ", generate yaml\n"
      kubectl get "$NS_OPT" "$t" -o yaml 2>/dev/null > "$YAML"
    fi
  done
}

## relocate the objects into corresponding namespace

function relocate_k8s_objs()
{
  cd "objs${1}"
  TOT=$(ls *.json | wc -l)
  NOW=0
  for j in $(ls *.json)
  do
    let NOW=$NOW+1
    name="${j%%\.json}"
    echo -n "Process $name ($NOW/$TOT) ... "
    ns="$(cat $j | jq -r -c '.items[] | .metadata.namespace' | sort | uniq | grep -v null | tr '\n' ' ')"
    if [ ! -n "$ns" ]; then
      echo -en " NO NS\n"
      continue
    fi
    echo -en "\n"
    for n in $ns
    do
      JSON="$n/${name}.json"
      YAML="$n/${name}.yaml"
      echo -en "  NS: $n ... "
      if [ -f "$JSON" ]; then
        echo -en " already done\n"
        continue
      fi
      mkdir -p "$n"
      kubectl get $name -n $n -o json > $JSON
      kubectl get $name -n $n -o yaml > $YAML
      # remove .items[] belongs to namespace $n
      rm -f .$j
      cp $j .$j
      cat .$j | jq -r -c "del(.items[] | select(.metadata.namespace == \"$n\"))" > $j
      echo -en " OK\n"
    done
    # check number of .items[]
    nitem=$(cat $j | jq -r -c ".items | length")
    if [ "$nitem" -eq 0 ]; then
      rm -f ${name}.json ${name}.yaml
    else
      cat $j | yamlconv -o yaml > ${name}.yaml
    fi
    # remove garbage
    rm -f .$j
  done
  cd -
}

function get_all_k8s_objs()
{
  SAVE_SUFFIX="/"
  NS_OPT="-A"
  get_k8s_objs "$SAVE_SUFFIX" "$NS_OPT"
  relocate_k8s_objs "$SAVE_SUFFIX"
}

function get_ns_k8s_objs()
{
  SAVE_SUFFIX="/$1/"
  NS_OPT="-n $1"
  get_k8s_objs "$SAVE_SUFFIX" "$NS_OPT"
  relocate_k8s_objs "$SAVE_SUFFIX"
}

case "$1" in
  -h|--help)
    usage
    exit 0
    ;;
  *)
    ;;
esac

get_k8s_crd
if [ -n "$1" ]; then
  while [ -n "$1" ]; do
    get_ns_k8s_objs "$1"
    shift
  done
else
  get_all_k8s_objs
fi
