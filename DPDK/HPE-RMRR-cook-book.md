# HPE RMRR 문제 해결 방법

## 증상

KVM vm 이 PCI device 를 pci passthrough 를 하려고 하면 아래와 같이 에러 로그를 발생시키면서 실패한다.
```
Jan 23 17:54:48 dcache01 kernel: vfio-pci 0000:07:00.0: DMAR: Device is ineligible for IOMMU domain attach due to platform RMRR requirement.  Contact your platform vendor.
```


## 해결

### HPE script-tool 다운로드/설치

https://downloads.linux.hpe.com/SDR/repo/stk/RedHat/8/x86_64/current/

redhat8, rocky8 의 경우 아래를 다운로드 하고 설치한다.
```
wget https://downloads.linux.hpe.com/SDR/repo/stk/RedHat/8/x86_64/current/hp-scripting-tools-11.60-7.rhel8.x86_64.rpm
```

### 설정

RMRDS 에 대한 메타 데이타 입력

```
cd /opt/hp/hp-scripting-tools/etc/
```

conrep.xml 파일의 <Conrep> 섹션의 마지막에 아래를 추가
```
        <Section name="RMRDS_Slot1">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26A</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x01">Endpoints_Excluded</value>
             <mask>0x01</mask>
        </Section>
        <Section name="RMRDS_Slot2">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26A</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x02">Endpoints_Excluded</value>
             <mask>0x02</mask>
        </Section>
        <Section name="RMRDS_Slot3">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26A</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x04">Endpoints_Excluded</value>
             <mask>0x04</mask>
        </Section>
        <Section name="RMRDS_Slot4">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26A</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x08">Endpoints_Excluded</value>
             <mask>0x08</mask>
        </Section>
        <Section name="RMRDS_Slot5">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26A</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x10">Endpoints_Excluded</value>
             <mask>0x10</mask>
        </Section>
        <Section name="RMRDS_Slot6">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26A</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x20">Endpoints_Excluded</value>
             <mask>0x20</mask>
        </Section>
        <Section name="RMRDS_Slot7">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26A</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x40">Endpoints_Excluded</value>
             <mask>0x40</mask>
        </Section>
        <Section name="RMRDS_Slot8">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26A</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x80">Endpoints_Excluded</value>
             <mask>0x80</mask>
        </Section>
        <Section name="RMRDS_Slot9">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26B</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x01">Endpoints_Excluded</value>
             <mask>0x01</mask>
        </Section>
        <Section name="RMRDS_Slot10">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26B</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x02">Endpoints_Excluded</value>
             <mask>0x02</mask>
        </Section>
        <Section name="RMRDS_Slot11">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26B</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x04">Endpoints_Excluded</value>
             <mask>0x04</mask>
        </Section>
        <Section name="RMRDS_Slot12">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26B</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x08">Endpoints_Excluded</value>
             <mask>0x08</mask>
        </Section>
        <Section name="RMRDS_Slot13">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26B</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x10">Endpoints_Excluded</value>
             <mask>0x10</mask>
        </Section>
        <Section name="RMRDS_Slot14">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26B</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x20">Endpoints_Excluded</value>
             <mask>0x20</mask>
        </Section>
        <Section name="RMRDS_Slot15">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26B</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x40">Endpoints_Excluded</value>
             <mask>0x40</mask>
        </Section>
        <Section name="RMRDS_Slot16">
             <helptext><![CDATA[.]]></helptext>    
             <nvram>0x26B</nvram>
             <value id="0x00">Endpoints_Included</value>
             <value id="0x80">Endpoints_Excluded</value>
             <mask>0x80</mask>
        </Section>
```

추가된 메타 데이타를 이용하여 현재 bios 상태를 추출한다
```
mkdir hp-bios-config
cd hp-bios-config

hprcu -a -s -f hprcu_settings.xml
conrep -s -f conrep_settings.xml
```

conrep_settings.xml 파일의 RMRDS_Slot<n> 항목을 모두 Endpoints_Excluded 로 수정한다.
```
<Section name="RMRDS_Slot1" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot2" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot3" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot4" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot5" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot6" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot7" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot8" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot9" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot10" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot11" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot12" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot13" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot14" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot15" helptext=".">Endpoints_Excluded</Section>
<Section name="RMRDS_Slot16" helptext=".">Endpoints_Excluded</Section>
```

변경된 설정으로 업데이트 한다.
```
hprcu -l -f hprcu_settings.xml
conrep -l -f conrep_settings.xml
```

다시 추출해보자
```
hprcu -a -s -f hprcu_settings_after_fix.xml
conrep -s -f conrep_settings_after_fix.xml
```

리부팅한다.
