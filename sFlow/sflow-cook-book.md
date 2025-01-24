<h1>slof</h1>


# sflow 참고 사이트

http://www.sflow.org/developers/tools.php
http://blog.sflow.com/2011/12/sflowtool.html
http://www.inmon.com/
http://www.sflow.org/developers/specifications.php

free software
https://community.spiceworks.com/topic/308491-best-netflow-sflow-analyzer
nfsen
Scrutinizer

sflow theory
http://www.inmon.com/pdf/sFlowBilling.pdf
sflow and billing

http://conferences.sigcomm.org/sigcomm/2003/papers/p325-duffield.pdf
> estimating flow distribution from sampled flow statistics
> OVS와 InMon sFlow-RT를 이용하여 elephant flow를 감지하고 OVS에 DSCP마킹하여 flow를 ratelimiting하는 예제



http://openvswitch.org/support/ovscon2014/17/1400-ovs-sflow.pdf
sFlow 기반 elephant flow 디텍션
> 링크 capacity별 elephant flow 정의, sFlow 샘플링 레이트 설정

# ovs slow config


http://openvswitch.org/support/config-cookbooks/sflow/

```
COLLECTOR_IP=192.168.70.100
COLLECTOR_PORT=6343
AGENT_IP=br0
HEADER_BYTES=1500
SAMPLING_N=1000
POLLING_SECS=1
BRIDGE_MON=ovs-br0
```

## 설정
```
ovs-vsctl -- --id=@sflow create sflow agent=${AGENT_IP} \
target=\"${COLLECTOR_IP}:${COLLECTOR_PORT}\" header=${HEADER_BYTES} \
sampling=${SAMPLING_N} polling=${POLLING_SECS} -- set bridge ${BRIDGE_MON} sflow=@sflow
```

## 조회
```
ovs-vsctl list sflow
```

## 해제
```
UUID="`ovs-vsctl list sflow | grep "^_uuid" | awk '{ print $3}'`"
ovs-vsctl remove bridge ${BRIDGE_MON} sflow $UUID
```
