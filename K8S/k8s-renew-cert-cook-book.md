
k8s 에서 사용되는 인증서는 1년짜리이다. 설치 후 1년이 지나면 아래와 같은 문구를 볼 수 있다.

```
[root@en-dev0-m01 ~]# kubectl get node 
Unable to connect to the server: x509: certificate has expired or is not yet valid: current time 2023-04-14T11:40:07+09:00 is after 2023-04-13T13:58:19Z 
[root@en-dev0-m01 ~]#
```

k8s 에서 사용되는 인증서 갱신 절차는 아래와 같다. <br>
https://danawalab.github.io/kubernetes/2022/03/28/Renew-Kubernates.html

kubectl 을 실행하는 (root) 계정으로 로그인

kubeconfig 백업
```
cp -dpRf .kube .kube.bak
```

k8s 인증서 백업
```
cp -dpRf /etc/kubernetes/pki /etc/kubernetes/pki-backup
```

인증서 갱신
```
kubeadm certs renew all
```

인증서 갱신 실행 dump
```
[root@en-dev0-m01 pki]# kubeadm certs renew all 
[renew] Reading configuration from the cluster... 
[renew] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml' 
[renew] Error reading configuration from the Cluster. Falling back to default configuration 
certificate embedded in the kubeconfig file for the admin to use and for kubeadm itself renewed 
certificate for serving the Kubernetes API renewed 
MISSING! certificate the apiserver uses to access etcd 
certificate for the API server to connect to kubelet renewed 
certificate embedded in the kubeconfig file for the controller manager to use renewed 
MISSING! certificate for liveness probes to healthcheck etcd 
MISSING! certificate for etcd nodes to communicate with each other 
MISSING! certificate for serving etcd 
certificate for the front proxy client renewed 
certificate embedded in the kubeconfig file for the scheduler manager to use renewed 
Done renewing certificates. You must restart the kube-apiserver, kube-controller-manager, kube-scheduler and etcd, so that they can use the new certificates. 
[root@en-dev0-m01 pki]#
```

갱신된 인증서 확인
```
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text |grep ' Not '
```

갱신된 인증서 확인 dump
```
[root@en-dev0-m01 pki]# openssl x509 -in apiserver.crt -noout -text |grep ' Not ' 
            Not Before: Apr 13 13:58:18 2022 GMT 
            Not After : Apr 13 04:20:38 2024 GMT 
[root@en-dev0-m01 pki]#
```

인증서만 갱신한 경우, kubectl 을 수행하면 아래와 같이 인증 실패가 발생한다.
```
[root@en-dev0-m01 ~]# kubectl get node 
error: You must be logged in to the server (Unauthorized) 
[root@en-dev0-m01 ~]#
```

사용자 구성 백업
```
cp -dpRf /etc/kubernetes /etc/kubernetes-backup
```

갱신된 인증서를 기반으로 사용자 구성을 갱신한다.
```
kubeadm kubeconfig user --client-name=admin \
  --config=/etc/kubernetes/kubeadm-config.yaml

kubeadm kubeconfig user --org system:masters --client-name kubernetes-admin \
  --config=/etc/kubernetes/kubeadm-config.yaml \
  > /etc/kubernetes/admin.conf 

kubeadm kubeconfig user --client-name system:kube-controller-manager \
  --config=/etc/kubernetes/kubeadm-config.yaml \
  > /etc/kubernetes/controller-manager.conf 

kubeadm kubeconfig user --org system:nodes --client-name system:node:$(hostname) \
  --config=/etc/kubernetes/kubeadm-config.yaml \
  > /etc/kubernetes/kubelet.conf 

kubeadm kubeconfig user --client-name system:kube-scheduler \
  --config=/etc/kubernetes/kubeadm-config.yaml \
  > /etc/kubernetes/scheduler.conf
```

/root/.kube/config 파일을 교체한다.
```
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

k8s 프로세스 재기동
```
systemctl daemon-reload && systemctl restart kubelet
```

kubectl 명령어가 정상 동작함을 확인한다.
```
[root@en-dev0-m01 ~]# kubectl get nodes 
NAME           STATUS   ROLES                  AGE    VERSION 
en-dev0-m01    Ready    control-plane,master   365d   v1.21.5 
en-dev0-w01    Ready    worker                 365d   v1.21.5 
flox           Ready    worker                 330d   v1.21.5 
panda          Ready    worker                 330d   v1.21.5 
sdv-dl360      Ready    worker                 352d   v1.21.5 
sdv-dl380-02   Ready    worker                 340d   v1.21.5 
sdv-dl380-03   Ready    worker                 339d   v1.21.5 
[root@en-dev0-m01 ~]#
```

백업 파일 삭제
```
rm -rf \
/etc/kubernetes/pki-backup \
/etc/kubernetes-backup \
.kube.bak
```

