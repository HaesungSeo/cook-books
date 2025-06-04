<H1>kubernetes(k8s) cook book</H1>

- [Print k8s objects](#print-k8s-objects)
	- [print all k8s objects](#print-all-k8s-objects)
	- [Print node lables](#print-node-lables)
	- [print cluster info](#print-cluster-info)
	- [print pod](#print-pod)
		- [print pod not running](#print-pod-not-running)
		- [print pod evicted](#print-pod-evicted)
		- [print message of evicted pod](#print-message-of-evicted-pod)
		- [print reason of pods not running](#print-reason-of-pods-not-running)
	- [print service](#print-service)
	- [print deployment](#print-deployment)
		- [expose deployment as service NodePort](#expose-deployment-as-service-nodeport)
	- [print replcation](#print-replcation)
	- [print replicaset](#print-replicaset)
	- [print host files used as k8s pod,pv](#print-host-files-used-as-k8s-podpv)
	- [print persistent volume(pv)](#print-persistent-volumepv)
	- [print persistent volume claim(pvc)](#print-persistent-volume-claimpvc)
	- [print all objects into file](#print-all-objects-into-file)
- [trouble shooing commands](#trouble-shooing-commands)
	- [create and connect to pod](#create-and-connect-to-pod)
	- [copy files inside pod to master node](#copy-files-inside-pod-to-master-node)
- [garbase collection](#garbase-collection)
	- [force delete namespace hanging](#force-delete-namespace-hanging)
	- [containerd prune](#containerd-prune)


# Print k8s objects 

## print all k8s objects 

모든 자원 출력

```
kubectl api-resources
```

example)
```
$ kubectl api-resources
NAME                              SHORTNAMES           APIVERSION                                  NAMESPACED   KIND
bindings                                               v1                                          true         Binding
componentstatuses                 cs                   v1                                          false        ComponentStatus
configmaps                        cm                   v1                                          true         ConfigMap
endpoints                         ep                   v1                                          true         Endpoints
events                            ev                   v1                                          true         Event
limitranges                       limits               v1                                          true         LimitRange
namespaces                        ns                   v1                                          false        Namespace
nodes                             no                   v1                                          false        Node
persistentvolumeclaims            pvc                  v1                                          true         PersistentVolumeClaim
persistentvolumes                 pv                   v1                                          false        PersistentVolume
pods                              po                   v1                                          true         Pod
podtemplates                                           v1                                          true         PodTemplate
replicationcontrollers            rc                   v1                                          true         ReplicationController
resourcequotas                    quota                v1                                          true         ResourceQuota
secrets                                                v1                                          true         Secret
serviceaccounts                   sa                   v1                                          true         ServiceAccount
services                          svc                  v1                                          true         Service
challenges                                             acme.cert-manager.io/v1                     true         Challenge
orders                                                 acme.cert-manager.io/v1                     true         Order
mutatingwebhookconfigurations                          admissionregistration.k8s.io/v1             false        MutatingWebhookConfiguration
validatingwebhookconfigurations                        admissionregistration.k8s.io/v1             false        ValidatingWebhookConfiguration
customresourcedefinitions         crd,crds             apiextensions.k8s.io/v1                     false        CustomResourceDefinition
apiservices                                            apiregistration.k8s.io/v1                   false        APIService
controllerrevisions                                    apps/v1                                     true         ControllerRevision
daemonsets                        ds                   apps/v1                                     true         DaemonSet
deployments                       deploy               apps/v1                                     true         Deployment
replicasets                       rs                   apps/v1                                     true         ReplicaSet
statefulsets                      sts                  apps/v1                                     true         StatefulSet
clusterworkflowtemplates          clusterwftmpl,cwft   argoproj.io/v1alpha1                        false        ClusterWorkflowTemplate
cronworkflows                     cwf,cronwf           argoproj.io/v1alpha1                        true         CronWorkflow
workfloweventbindings             wfeb                 argoproj.io/v1alpha1                        true         WorkflowEventBinding
workflows                         wf                   argoproj.io/v1alpha1                        true         Workflow
workflowtaskresults                                    argoproj.io/v1alpha1                        true         WorkflowTaskResult
workflowtasksets                  wfts                 argoproj.io/v1alpha1                        true         WorkflowTaskSet
workflowtemplates                 wftmpl               argoproj.io/v1alpha1                        true         WorkflowTemplate
tokenreviews                                           authentication.k8s.io/v1                    false        TokenReview
localsubjectaccessreviews                              authorization.k8s.io/v1                     true         LocalSubjectAccessReview
selfsubjectaccessreviews                               authorization.k8s.io/v1                     false        SelfSubjectAccessReview
selfsubjectrulesreviews                                authorization.k8s.io/v1                     false        SelfSubjectRulesReview
subjectaccessreviews                                   authorization.k8s.io/v1                     false        SubjectAccessReview
horizontalpodautoscalers          hpa                  autoscaling/v2                              true         HorizontalPodAutoscaler
metrics                                                autoscaling.internal.knative.dev/v1alpha1   true         Metric
podautoscalers                    kpa,pa               autoscaling.internal.knative.dev/v1alpha1   true         PodAutoscaler
cronjobs                          cj                   batch/v1                                    true         CronJob
jobs                                                   batch/v1                                    true         Job
images                                                 caching.internal.knative.dev/v1alpha1       true         Image
certificaterequests               cr,crs               cert-manager.io/v1                          true         CertificateRequest
certificates                      cert,certs           cert-manager.io/v1                          true         Certificate
clusterissuers                                         cert-manager.io/v1                          false        ClusterIssuer
issuers                                                cert-manager.io/v1                          true         Issuer
certificatesigningrequests        csr                  certificates.k8s.io/v1                      false        CertificateSigningRequest
leases                                                 coordination.k8s.io/v1                      true         Lease
bgpconfigurations                                      crd.projectcalico.org/v1                    false        BGPConfiguration
bgppeers                                               crd.projectcalico.org/v1                    false        BGPPeer
blockaffinities                                        crd.projectcalico.org/v1                    false        BlockAffinity
caliconodestatuses                                     crd.projectcalico.org/v1                    false        CalicoNodeStatus
clusterinformations                                    crd.projectcalico.org/v1                    false        ClusterInformation
felixconfigurations                                    crd.projectcalico.org/v1                    false        FelixConfiguration
globalnetworkpolicies                                  crd.projectcalico.org/v1                    false        GlobalNetworkPolicy
globalnetworksets                                      crd.projectcalico.org/v1                    false        GlobalNetworkSet
hostendpoints                                          crd.projectcalico.org/v1                    false        HostEndpoint
ipamblocks                                             crd.projectcalico.org/v1                    false        IPAMBlock
ipamconfigs                                            crd.projectcalico.org/v1                    false        IPAMConfig
ipamhandles                                            crd.projectcalico.org/v1                    false        IPAMHandle
ippools                                                crd.projectcalico.org/v1                    false        IPPool
ipreservations                                         crd.projectcalico.org/v1                    false        IPReservation
kubecontrollersconfigurations                          crd.projectcalico.org/v1                    false        KubeControllersConfiguration
networkpolicies                                        crd.projectcalico.org/v1                    true         NetworkPolicy
networksets                                            crd.projectcalico.org/v1                    true         NetworkSet
authcodes                                              dex.coreos.com/v1                           true         AuthCode
authrequests                                           dex.coreos.com/v1                           true         AuthRequest
connectors                                             dex.coreos.com/v1                           true         Connector
devicerequests                                         dex.coreos.com/v1                           true         DeviceRequest
devicetokens                                           dex.coreos.com/v1                           true         DeviceToken
oauth2clients                                          dex.coreos.com/v1                           true         OAuth2Client
offlinesessionses                                      dex.coreos.com/v1                           true         OfflineSessions
passwords                                              dex.coreos.com/v1                           true         Password
refreshtokens                                          dex.coreos.com/v1                           true         RefreshToken
signingkeies                                           dex.coreos.com/v1                           true         SigningKey
endpointslices                                         discovery.k8s.io/v1                         true         EndpointSlice
brokers                                                eventing.knative.dev/v1                     true         Broker
eventtypes                                             eventing.knative.dev/v1beta1                true         EventType
triggers                                               eventing.knative.dev/v1                     true         Trigger
events                            ev                   events.k8s.io/v1                            true         Event
wasmplugins                                            extensions.istio.io/v1alpha1                true         WasmPlugin
flowschemas                                            flowcontrol.apiserver.k8s.io/v1beta3        false        FlowSchema
prioritylevelconfigurations                            flowcontrol.apiserver.k8s.io/v1beta3        false        PriorityLevelConfiguration
parallels                                              flows.knative.dev/v1                        true         Parallel
sequences                                              flows.knative.dev/v1                        true         Sequence
istiooperators                    iop,io               install.istio.io/v1alpha1                   true         IstioOperator
experiments                                            kubeflow.org/v1beta1                        true         Experiment
mpijobs                                                kubeflow.org/v1                             true         MPIJob
mxjobs                                                 kubeflow.org/v1                             true         MXJob
notebooks                                              kubeflow.org/v1                             true         Notebook
paddlejobs                                             kubeflow.org/v1                             true         PaddleJob
poddefaults                                            kubeflow.org/v1alpha1                       true         PodDefault
profiles                                               kubeflow.org/v1                             false        Profile
pvcviewers                                             kubeflow.org/v1alpha1                       true         PVCViewer
pytorchjobs                                            kubeflow.org/v1                             true         PyTorchJob
scheduledworkflows                swf                  kubeflow.org/v1beta1                        true         ScheduledWorkflow
suggestions                                            kubeflow.org/v1beta1                        true         Suggestion
tfjobs                                                 kubeflow.org/v1                             true         TFJob
trials                                                 kubeflow.org/v1beta1                        true         Trial
viewers                           vi                   kubeflow.org/v1beta1                        true         Viewer
xgboostjobs                                            kubeflow.org/v1                             true         XGBoostJob
channels                          ch                   messaging.knative.dev/v1                    true         Channel
subscriptions                     sub                  messaging.knative.dev/v1                    true         Subscription
compositecontrollers              cc,cctl              metacontroller.k8s.io/v1alpha1              false        CompositeController
controllerrevisions                                    metacontroller.k8s.io/v1alpha1              true         ControllerRevision
decoratorcontrollers              dec,decorators       metacontroller.k8s.io/v1alpha1              false        DecoratorController
certificates                      kcert                networking.internal.knative.dev/v1alpha1    true         Certificate
clusterdomainclaims               cdc                  networking.internal.knative.dev/v1alpha1    false        ClusterDomainClaim
ingresses                         kingress,king        networking.internal.knative.dev/v1alpha1    true         Ingress
serverlessservices                sks                  networking.internal.knative.dev/v1alpha1    true         ServerlessService
destinationrules                  dr                   networking.istio.io/v1beta1                 true         DestinationRule
envoyfilters                                           networking.istio.io/v1alpha3                true         EnvoyFilter
gateways                          gw                   networking.istio.io/v1beta1                 true         Gateway
proxyconfigs                                           networking.istio.io/v1beta1                 true         ProxyConfig
serviceentries                    se                   networking.istio.io/v1beta1                 true         ServiceEntry
sidecars                                               networking.istio.io/v1beta1                 true         Sidecar
virtualservices                   vs                   networking.istio.io/v1beta1                 true         VirtualService
workloadentries                   we                   networking.istio.io/v1beta1                 true         WorkloadEntry
workloadgroups                    wg                   networking.istio.io/v1beta1                 true         WorkloadGroup
ingressclasses                                         networking.k8s.io/v1                        false        IngressClass
ingresses                         ing                  networking.k8s.io/v1                        true         Ingress
networkpolicies                   netpol               networking.k8s.io/v1                        true         NetworkPolicy
runtimeclasses                                         node.k8s.io/v1                              false        RuntimeClass
blockdeviceclaims                 bdc                  openebs.io/v1alpha1                         true         BlockDeviceClaim
blockdevices                      bd                   openebs.io/v1alpha1                         true         BlockDevice
poddisruptionbudgets              pdb                  policy/v1                                   true         PodDisruptionBudget
clusterrolebindings                                    rbac.authorization.k8s.io/v1                false        ClusterRoleBinding
clusterroles                                           rbac.authorization.k8s.io/v1                false        ClusterRole
rolebindings                                           rbac.authorization.k8s.io/v1                true         RoleBinding
roles                                                  rbac.authorization.k8s.io/v1                true         Role
priorityclasses                   pc                   scheduling.k8s.io/v1                        false        PriorityClass
authorizationpolicies                                  security.istio.io/v1                        true         AuthorizationPolicy
peerauthentications               pa                   security.istio.io/v1beta1                   true         PeerAuthentication
requestauthentications            ra                   security.istio.io/v1                        true         RequestAuthentication
configurations                    config,cfg           serving.knative.dev/v1                      true         Configuration
domainmappings                    dm                   serving.knative.dev/v1beta1                 true         DomainMapping
revisions                         rev                  serving.knative.dev/v1                      true         Revision
routes                            rt                   serving.knative.dev/v1                      true         Route
services                          kservice,ksvc        serving.knative.dev/v1                      true         Service
clusterservingruntimes                                 serving.kserve.io/v1alpha1                  false        ClusterServingRuntime
clusterstoragecontainers                               serving.kserve.io/v1alpha1                  false        ClusterStorageContainer
inferencegraphs                   ig                   serving.kserve.io/v1alpha1                  true         InferenceGraph
inferenceservices                 isvc                 serving.kserve.io/v1beta1                   true         InferenceService
servingruntimes                                        serving.kserve.io/v1alpha1                  true         ServingRuntime
trainedmodels                     tm                   serving.kserve.io/v1alpha1                  true         TrainedModel
apiserversources                                       sources.knative.dev/v1                      true         ApiServerSource
containersources                                       sources.knative.dev/v1                      true         ContainerSource
pingsources                                            sources.knative.dev/v1                      true         PingSource
sinkbindings                                           sources.knative.dev/v1                      true         SinkBinding
csidrivers                                             storage.k8s.io/v1                           false        CSIDriver
csinodes                                               storage.k8s.io/v1                           false        CSINode
csistoragecapacities                                   storage.k8s.io/v1                           true         CSIStorageCapacity
storageclasses                    sc                   storage.k8s.io/v1                           false        StorageClass
volumeattachments                                      storage.k8s.io/v1                           false        VolumeAttachment
telemetries                       telemetry            telemetry.istio.io/v1alpha1                 true         Telemetry
tensorboards                                           tensorboard.kubeflow.org/v1alpha1           true         Tensorboard
$
```

## Print node lables 

노드의 레이블 출력

```
kubectl get nodes --show-labels
```

example)
```
 hsseo@instance-6:~$ kubectl get nodes --show-labels
 NAME         STATUS   ROLES    AGE   VERSION    LABELS
 instance-1   Ready    master   20d   v1.18.10   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=instance-1,kubernetes.io/os=linux,node-role.kubernetes.io/master=
 instance-2   Ready    master   20d   v1.18.10   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=instance-2,kubernetes.io/os=linux,node-role.kubernetes.io/master=
 instance-3   Ready    master   20d   v1.18.10   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=instance-3,kubernetes.io/os=linux,node-role.kubernetes.io/master=
 instance-4   Ready    <none>   20d   v1.18.10   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=instance-4,kubernetes.io/os=linux
 instance-5   Ready    <none>   20d   v1.18.10   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=instance-5,kubernetes.io/os=linux
 hsseo@instance-6:~$
```


## print cluster info 

```
kubectl cluster-info
```

example)
```
hsseo@instance-6:~$ kubectl cluster-info
Kubernetes master is running at https://10.128.0.9:6443
 To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
hsseo@instance-6:~$
```


## print pod 

```
kubectl get pods
```

example)
```
hsseo@instance-6:~$ kubectl get pods 
NAME                                READY   STATUS    RESTARTS   AGE 
netshoot                            1/1     Running   0          8m45s 
nginx-deployment-6c7959dbbc-b6fsh   1/1     Running   0          14d 
nginx-deployment-6c7959dbbc-stgkh   1/1     Running   0          14d 
nginx-deployment-6c7959dbbc-ztpqp   1/1     Running   0          14d 
hsseo@instance-6:~$
```

### print pod not running

print pod as json text
```
kubectl get pod -A -o json > pod.json
```

then, filter and so on
```
cat pod.json \
  | jq -r '[.items[] | select(.status.phase != "Running")]' \
  > pod.not-running.json

cat pod.not-running.json \
  | gron | grep "status.phase\|reason\|metadata.name"
```

example)
```
json[0].metadata.name = "registry-harbor-registry-587f59899c-nf8bz";
json[0].metadata.namespace = "harbor";
json[0].status.conditions[1].reason = "ContainersNotReady";
json[0].status.conditions[2].reason = "ContainersNotReady";
json[0].status.containerStatuses[0].state.waiting.reason = "ContainerCreating";
json[0].status.containerStatuses[1].state.waiting.reason = "ContainerCreating";
json[0].status.phase = "Pending";
json[1].metadata.name = "registry-harbor-trivy-0";
json[1].metadata.namespace = "harbor";
json[1].status.conditions[1].reason = "ContainersNotReady";
json[1].status.conditions[2].reason = "ContainersNotReady";
json[1].status.containerStatuses[0].state.waiting.reason = "ContainerCreating";
json[1].status.phase = "Pending";
json[2].metadata.name = "virt-controller-85bfb448b-gg5p7";
json[2].metadata.namespace = "kubevirt";
```

### print pod evicted
See https://stackoverflow.com/questions/26701538/how-to-filter-an-array-of-objects-based-on-values-in-an-inner-array-with-jq

```
cat pod.json \
  | jq -r '[.items[] | select(.status.reason == "Evicted")]' \
  > pod.evicted.json

cat pod.evicted.json \
  | gron | grep "status.phase\|reason\|metadata.name"
```

```
# release-2.20 ??
cat pod.json \
  | jq -r '[.items[] | select(.status.containerStatuses != null) 
  | select(.status.containerStatuses[].state.waiting.reason == "Evicted")]' \
  > pod.evicted.json

cat pod.evicted.json \
  | gron | grep "status.phase\|reason\|metadata.name"
```

### print message of evicted pod
See https://cloudaffaire.com/faq/how-to-display-multiple-fields-in-jq-output/
```
cat pod.evicted.json \
  | jq -r '[.[] | {ns: .metadata.namespace, name: .metadata.name, reason: .status.message}]' \
  > pod.evicted.name-reason.json
```

delete pods evicted
```
cat pod.evicted.json \
  | kubectl delete -f -
```

delete pods with pending status
```
kubectl get pods -A \
  --field-selector=status.phase=Pending \
  -o yaml | kubectl delete -f -
```

delete pods with Completed status
```
kubectl get pods -A \
  --field-selector=status.phase=Completed \
  -o yaml | kubectl delete -f -
```

### print reason of pods not running 

```
cat pod.json \
  | jq -r '[.items[] | select(.status.reason=="Shutdown") 
  | [.metadata.name, .status.message]]' > pod.shutdown.json
cat pod.json \
  | jq -r '[.items[] | select(.status.containerStatuses[].state.waiting.reason=="CrashLoopBackOff") 
  | [.metadata.name, .status.containerStatuses[].state.waiting.message]]' > pod.crash.json
cat pod.json \
  | jq -r '[.items[] | select(.status.reason=="Terminating") 
  | [.metadata.name, .status.message]]' > pod.term.json
```

```
for j in $(ls pod.*.json)
do
  sed -zi 's/\n//g' $j
  sed -zi 's/],/],\n/g' $j
done
```


## print service 

```
kubectl get service
```

example)
```
hsseo@instance-6:~$ kubectl get service 
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE 
kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP   20d 
s1           ClusterIP   10.233.44.151   <none>        80/TCP    14d 
hsseo@instance-6:~$
```


## print deployment 

```
kubectl get deployments
```

print deployment rollout history 

```
kubectl rollout history deployment
```

### expose deployment as service NodePort 

```
kubectl expose deploy <instance> --name <name> --type=<NodePort>
```

```
$ kubectl expose deploy nginx-deployment --name s1 --type=NodePort
 service/s1 exposed
$
```


## print replcation

```
kubectl get rc
```


## print replicaset 

```
kubectl get rs
```



## print host files used as k8s pod,pv 

```
find /var -size +1G 2>/dev/null| xargs ls -alh
find /var/lib/kubelet -size +1G | xargs ls -alh
find /var/lib/docker -size +1G | xargs ls -alh
find /var/lib/openebs -size +1G | xargs ls -alh
```


## print persistent volume(pv) 

```
kubectl get pv -o json > pv.json
```


## print persistent volume claim(pvc)

```
kubectl get pvc -A -o json > pvc.json
```

## print all objects into file

```
cat<<'EOM' > print-obj.sh
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

# relocate the objects into corresponding namespace
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
EOM
chmod +x print-obj.sh
```

# trouble shooing commands

## create and connect to pod 

exec and connect in a siggle command

```
kubectl run --rm -i --tty ubuntu --image=ubuntu --restart=Never -- bash
```

create once, and connect as needed 

execute it once,
```
kubectl run ubuntu --image=ubuntu --restart=Never -- sleep inf
```

then connect as needed
```
kubectl exec -it ubuntu -- bash
```


## copy files inside pod to master node
https://medium.com/@nnilesh7756/copy-directories-and-files-to-and-from-kubernetes-container-pod-19612fa74660

```
kubectl cp <file-spec-src> <file-spec-dest>
```

example)
```
kubectl cp <some-namespace>/<some-pod>:/tmp/foo /tmp/bar
```


# garbase collection 

## force delete namespace hanging 
skip finalize 

```
cat<<'EOM' > remove-terminating-stucked-namespace.sh
#!/bin/bash
# See https://togomi.tistory.com/7
NS_TERMINATING=$(kubectl get ns -o jsonpath="{.items[?(@.status.phase == 'Terminating')].metadata.name}")
for NS in $NS_TERMINATING
do
  echo ""
  echo "RUN: kubectl get namespace \"$NS\" -o json \\
    | tr -d \"\n\" | sed \"s/\\\"finalizers\\\": \[[^]]\+\]/\\\"finalizers\\\": []/\" \\
    | kubectl replace --raw /api/v1/namespaces/\"$NS\"/finalize -f -"
  echo ""
  kubectl get namespace "$NS" -o json \
    | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
    | kubectl replace --raw /api/v1/namespaces/"$NS"/finalize -f -
done
EOM
chmod +x remove-terminating-stucked-namespace.sh
```

```
./remove-terminating-stucked-namespace.sh
```

## containerd prune
delete unused container images
```
nerdctl image prune
```
