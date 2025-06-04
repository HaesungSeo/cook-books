<H1> trex v3.06 </H1>

- [빌드](#빌드)
- [ubuntu 22.04 LTS INTEL E810](#ubuntu-2204-lts-intel-e810)

# 빌드

소스 다운로드 
```
git clone https://github.com/cisco-system-traffic-generator/trex-core.git
cd ~/trex-core
git checkout v3.04
```

ubuntu 2204 LTS 에서 빌드 오류를 수정한 버전
```
git clone git@gitlab-ntels:SDV/trex.git
cd ~/trex
git checkout v304
```

의존성 패키지 설치
```
sudo apt update -y && \
sudo apt install g++ zlib1g-dev build-essential -y
```

빌드
```
cd ~/trex
cd linux_dpdk
./b configure
./b build
```

TRex Simulator 빌드
```
cd ~/trex
cd linux
./b configure
./b build
```

# ubuntu 22.04 LTS INTEL E810 
ubuntu 22.04 LTS 는 인텔 E810-XXV 디바이스 드라이버가 없다.

아래 링크로 E810 최신 드라이버를 다운로드 한다. <br>
[2025-02-27] 기준 최신 버전은 1.16.3
```
https://www.intel.co.kr/content/www/kr/ko/download/19630/intel-network-adapter-driver-for-e810-series-devices-under-linux.html
```

아래의 내용으로 패치파일을 생성한다.
```
cat<<'EOM' > fix.patch
diff -Naur ice-1.16.3/src/auxiliary.c ice-1.16.3-hsseo/src/auxiliary.c
--- ice-1.16.3/src/auxiliary.c	2024-12-09 14:45:14.000000000 +0000
+++ ice-1.16.3-hsseo/src/auxiliary.c	2025-02-27 04:54:27.740508188 +0000
@@ -78,7 +78,8 @@
 	return ret;
 }

-static int auxiliary_bus_remove(struct device *dev)
+//hsseo; static int auxiliary_bus_remove(struct device *dev)
+static void auxiliary_bus_remove(struct device *dev)
 {
 	struct auxiliary_driver *auxdrv = to_auxiliary_drv(dev->driver);
 	struct auxiliary_device *auxdev = to_auxiliary_dev(dev);
@@ -87,7 +88,8 @@
 		auxdrv->remove(auxdev);
 	dev_pm_domain_detach(dev, true);

-	return 0;
+	//return 0;
+	return;
 }

 static void auxiliary_bus_shutdown(struct device *dev)
diff -Naur ice-1.16.3/src/ice_hwmon.c ice-1.16.3-hsseo/src/ice_hwmon.c
--- ice-1.16.3/src/ice_hwmon.c	2024-12-09 14:44:31.000000000 +0000
+++ ice-1.16.3-hsseo/src/ice_hwmon.c	2025-02-27 05:00:54.905720885 +0000
@@ -124,6 +124,11 @@
 	if (!pf->hwmon_dev)
 		return;

+#if 1 /* hsseo */
 	hwmon_device_unregister(pf->hwmon_dev);
+#else
+	if (!IS_ERR_OR_NULL(adapter->hwmon_dev))
+		devm_hwmon_device_unregister(&adapter->pdev->dev, adapter->hwmon_dev);
+#endif
 }
 #endif /* HAVE_HWMON_DEVICE_REGISTER_WITH_INFO */
diff -Naur ice-1.16.3/src/kcompat-generator.sh ice-1.16.3-hsseo/src/kcompat-generator.sh
--- ice-1.16.3/src/kcompat-generator.sh	2024-12-09 14:45:15.000000000 +0000
+++ ice-1.16.3-hsseo/src/kcompat-generator.sh	2025-02-27 06:08:54.913501510 +0000
@@ -370,7 +370,9 @@
 	gen NEED_FIND_NEXT_BIT_WRAP if fun find_next_bit_wrap absent in include/linux/find.h
 	gen HAVE_FILE_IN_SEQ_FILE if struct seq_file matches 'struct file' in include/linux/fs.h
 	gen NEED_FS_FILE_DENTRY if fun file_dentry absent in include/linux/fs.h
-	gen HAVE_HWMON_DEVICE_REGISTER_WITH_INFO if fun hwmon_device_register_with_info in include/linux/hwmon.h
+    # hsseo disable it
+	#gen HAVE_HWMON_DEVICE_REGISTER_WITH_INFO if fun hwmon_device_register_with_info in include/linux/hwmon.h
+    #
 	gen NEED_HWMON_CHANNEL_INFO if macro HWMON_CHANNEL_INFO absent in include/linux/hwmon.h
 	gen NEED_ETH_TYPE_VLAN if fun eth_type_vlan absent in include/linux/if_vlan.h
 	gen HAVE_IOMMU_DEV_FEAT_AUX if enum iommu_dev_features matches IOMMU_DEV_FEAT_AUX in include/linux/iommu.h
EOM
```

드라이버 소스코드로 이동하여 패치를 수행한다.
```
cd ice-1.16.3
patch -p1 < ../fix.patch
```

빌드
```
cd ice-1.16.3/src
sudo make install
```

드라이버 로드/언로드 <br>
```
sudo modprobe ice
sudo modprobe -r ice
```

드라이버 확인 <br>
```
sudo lsmod | grep ice
```
