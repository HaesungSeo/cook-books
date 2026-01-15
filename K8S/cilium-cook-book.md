<H1> Cilium Cookbook (Kubernetes) </H1>

> 목적: 설치/운영/트러블슈팅/관측/정책/네트워킹까지 “바로 써먹는” 명령 모음  
> 전제: kubeconfig 접근 가능, `kubectl` 사용 가능  
> 권장: 운영은 Helm 기반, 점검은 cilium-cli 기반

- [0) 빠른 체크리스트](#0-빠른-체크리스트)
  - [클러스터/노드 기본 확인](#클러스터노드-기본-확인)


## 0) 빠른 체크리스트

### 클러스터/노드 기본 확인
```bash
kubectl version --short
kubectl get nodes -o wide
kubectl -n kube-system get pods -o wide
