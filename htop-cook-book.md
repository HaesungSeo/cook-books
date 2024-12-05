
# htop 을 실행하면 화면에 아무것도 출력되지 않고 멈춰있는 경우가 있다.

## strace 로 분석

```
strace -o htop_debug.log htop
```

###  /proc 의 일부 파일에 접근이 되지 않는다.

```
[root@sdv-dl360 ~]# find /proc | wc -l
find: ‘/proc/3790448/task/3790448/net’: Invalid argument
find: ‘/proc/3790448/net’: Invalid argument
1968252
[root@sdv-dl360 ~]#
```

특정 프로세스의 /proc 구조가 이상하다. <br>
해당 프로세스는 좀비상태
```
[root@sdv-dl360 ~]# ps aux | grep 3790448
root     3055783  0.0  0.0 221940  1144 pts/1    S+   10:01   0:00 grep --color=auto 3790448
root     3790448  0.0  0.0      0     0 ?        Zsl  Oct29   0:06 [csi-provisioner] <defunct>
[root@sdv-dl360 ~]#
```

부모 프로세스를 찾아보자.
```
[root@sdv-dl360 ~]# ps -o ppid= -p 3790448
3773448
[root@sdv-dl360 ~]#
```

부모 프로세스에 또 다른 자식 프로세스중에 중요한 프로세스가 있나 확인<br>
뭔가 잔뜩 연결되어 있다.
```
[root@sdv-dl360 ~]# pstree -p 3773448
containerd-shim(3773448)─┬─csi-provisioner(3790448)───{csi-provisioner}(3790546)
                         ├─pause(3773489)
                         ├─{containerd-shim}(3773449)
                         ├─{containerd-shim}(3773450)
                         ├─{containerd-shim}(3773451)
                         ├─{containerd-shim}(3773452)
                         ├─{containerd-shim}(3773453)
                         ├─{containerd-shim}(3773454)
                         ├─{containerd-shim}(3773455)
                         ├─{containerd-shim}(3773456)
                         ├─{containerd-shim}(3773457)
                         ├─{containerd-shim}(3773539)
                         ├─{containerd-shim}(3776387)
                         ├─{containerd-shim}(3788175)
                         ├─{containerd-shim}(1374369)
                         └─{containerd-shim}(1217276)
[root@sdv-dl360 ~]#
```

일단 containerd-shim 들이 뭐하는 프로세스들인지 ps 에서 뭔가 찾을게 없나 보자. <br>
```
[root@sdv-dl360 ~]# ps aux | grep containerd-shim
root        3149  0.0  0.0 722748 18932 ?        Sl   Apr15 181:57 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 79f7b87a1a49128063192f59e6c7b8f9693322d1122b454d3b24b966cb22ff80 -address /run/containerd/containerd.sock
root        4046  0.0  0.0 722492 13940 ?        Sl   Nov06  16:48 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id f7116590d86263b0dd02f248ee53493fe1941e74086937ec4103eb073d9bd235 -address /run/containerd/containerd.sock
root        4539  0.0  0.0 722748 13028 ?        Sl   Nov06  16:47 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id a8bbada167b3cb3cc33d7f53759f14b5d399131e10f36bffefbc58acb3e046a0 -address /run/containerd/containerd.sock
root        4930  0.0  0.0 722492 14160 ?        Sl   Nov06  16:53 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id d75f31eebd03c8e96ec3b24acc886e7376933daac882c9474e0b7018b298d8ee -address /run/containerd/containerd.sock
root        5309  0.0  0.0 722492 14048 ?        Sl   Nov06  17:01 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id ed985e8037cbb32eb91bbb2744c1b668c899f5d2255c787c2fa2859d92965ec3 -address /run/containerd/containerd.sock
root        5401  0.0  0.0 722748 19412 ?        Sl   Apr15 178:30 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id d646db17b2999c3b169d77a3d5c013140b0cb96c72ceb3721cd18446a68e15c0 -address /run/containerd/containerd.sock
root        5861  0.0  0.0 722492 14140 ?        Sl   Nov06  16:55 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id efc52320beec02b75f511b5b43a1cb45ab17916eeaa0fb43615093629af37041 -address /run/containerd/containerd.sock
root        6524  0.0  0.0 722748 13904 ?        Sl   Nov06  16:49 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id fc29f1400cd732fc1706135e96f9b462c4df1e7305dbdf682ee3415560b0e0bb -address /run/containerd/containerd.sock
root        7308  0.0  0.0 722748 20788 ?        Sl   Apr15 213:06 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id cb121804cac2911567eb4af3640a98120448ed1cb3232d6f57b41c4649ab259c -address /run/containerd/containerd.sock
root        7632  0.0  0.0 722748 13616 ?        Sl   Nov06  16:50 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 445c15ca6aa1655a54e862e4ca5cda30bce05508aed27e3a3ca9b5e26825bd00 -address /run/containerd/containerd.sock
root        8010  0.0  0.0 722492 13736 ?        Sl   Nov06  16:57 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 24dcb80242abf82fe62e35282b188a825dce0c0ceb98239e8f847d0c792dbd06 -address /run/containerd/containerd.sock
root        8116  0.1  0.0 722748 20656 ?        Sl   Apr15 366:52 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 19fe6b8abf2444799cb19a8b1597609c3e9ddb1e90c8dab1a0f9ab895b5c4aa9 -address /run/containerd/containerd.sock
root        8151  0.0  0.0 722748 20908 ?        Sl   Apr15 219:51 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id e5bfc45c194c58e31253feca5e6cf462f6cf5280a5a76239b442cedc5d2330cf -address /run/containerd/containerd.sock
root        8471  0.0  0.0 722492 13388 ?        Sl   Nov06  16:51 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 7bc5ffcbe832298092aa4d17338438c3147576579d0453d338edd8ddf0f4b7d5 -address /run/containerd/containerd.sock
root        8601  0.1  0.0 722492 19376 ?        Sl   Apr15 538:57 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id a500278cb4e45dc8c1d1d8b442bd203418bb796b6e29c702af72cf912d8c4709 -address /run/containerd/containerd.sock
root        8875  0.2  0.0 722748 21740 ?        Sl   Apr15 665:25 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id e57a85f124d87a0ff1a83374d7fa4dbe6f3090792d60c39b52befa41a4286ec0 -address /run/containerd/containerd.sock
root        8946  0.0  0.0 722492 13372 ?        Sl   Nov06  16:43 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 53dbb50cf19a09b078e6fbad0417bc1da167576e8abe80a9ead4bba557af667f -address /run/containerd/containerd.sock
root       10937  0.0  0.0 722748 14120 ?        Sl   Nov06  16:50 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 21c2ec1a754abae92a36be3ada042db26b5e0960d35c1dd026f64c4d15f06164 -address /run/containerd/containerd.sock
root       11034  0.0  0.0 722492 19368 ?        Sl   Apr15 182:10 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 1f5a3ecfb95cbbdc340875ecbeb3459052befda3d8902ed63bea8031b909dfde -address /run/containerd/containerd.sock
root       13706  0.0  0.0 722748 21228 ?        Sl   Apr15 178:45 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 6bf71db75d6d35c4986fdd9edd0f7acee345031e37838243a0c00956b7584c31 -address /run/containerd/containerd.sock
root       19596  0.2  0.0 723004 20716 ?        Sl   Apr15 695:40 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id d2b2f9fe2478673eed02fdc7a341a1a0f19facbb8920ae62b7af997789f96cc8 -address /run/containerd/containerd.sock
root       19886  0.0  0.0 722492 18788 ?        Sl   Apr15 173:03 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 9232be02ce506c6307ca9e793617b7a701e82d5b9ea94d404ed99d478985d328 -address /run/containerd/containerd.sock
root       26226  0.1  0.0 722492 19964 ?        Sl   Apr15 360:03 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id d0ce9ba8d542a4c811480f0bb3eae81f2b9cd27bfb8931728830f297a3616fbe -address /run/containerd/containerd.sock
root       71757  0.0  0.0 722492 13684 ?        Sl   Nov13  11:48 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id f67e4304428ad16127501b56a87abcfd4955d5826f84518b2429da00de216635 -address /run/containerd/containerd.sock
root      278249  0.0  0.0 722492 19592 ?        Sl   Aug06  83:49 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 1e78aded97e047f9a18626f0f4e7e46da444296ece858731ddec4f46ee5843a2 -address /run/containerd/containerd.sock
root      286810  0.0  0.0 722748 19456 ?        Sl   Apr29  37:54 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 2f8627ca13896a609a561f5dbc4f6fea884a3ce455d413a9ed059e43a76f55ab -address /run/containerd/containerd.sock
root      287007  0.0  0.0 722556 18584 ?        Sl   Apr29 157:33 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id db7215fbb53c4e68b152690fd8cdbac0262d6e0ff09ada47bdcc98dbc81a95ed -address /run/containerd/containerd.sock
root      400658  0.0  0.0 722492 13420 ?        Sl   Nov11  13:17 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id ceed89d1e493627dc6f115a194791dcca8abfeac22cf49f11e070b44e9c881e7 -address /run/containerd/containerd.sock
root      426791  0.0  0.0 722748 12964 ?        Sl   Nov05  17:40 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id ec04ae93d2691ce4f18ca21e3dba5b55f988dc5cd5bc976c82375be3d0cee10a -address /run/containerd/containerd.sock
root     1589722  0.0  0.0 722492 14436 ?        Sl   Nov25   2:52 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 0a9496ce8b0e4037678bcca061b62b3f0dde4f32069ea1f05f562db0d130cbe3 -address /run/containerd/containerd.sock
root     2035296  0.0  0.0 722492 19536 ?        Sl   Sep10  58:17 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 0008ed4ccb80cea52dc3543dc1a320f56fc136ef0674c9ff125946b505238408 -address /run/containerd/containerd.sock
root     2035947  0.0  0.0 722748 19012 ?        Sl   Sep10  58:08 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 26dc40598cd6d39036e59a47f8f4ccef96f246230376d98f8b88816259f8af90 -address /run/containerd/containerd.sock
root     2072912  0.0  0.0 722748 19568 ?        Sl   Apr23 162:06 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 53f01ce2caf1046e8eadf2457aa015c48444c558d07270d5ff022e7b8ed19327 -address /run/containerd/containerd.sock
root     2075422  0.0  0.0 722492 18808 ?        Sl   Apr23 168:13 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 9852639e3507d3be206cc832e6c0d22292e17cbf193d59fcb3be9b9f24a1d619 -address /run/containerd/containerd.sock
root     2075879  0.0  0.0 722236 19652 ?        Sl   Apr23 163:49 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 63df77cb967bd3d27d1060c4dccae607b18e013af00e04cfa6caab1837fdc8bd -address /run/containerd/containerd.sock
root     2077880  0.0  0.0 722492 19264 ?        Sl   Apr23 168:42 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id b3ef0d8741353fbdc12c8b7b9afb51936f83a77372fa7d3c862567a4d9d323ef -address /run/containerd/containerd.sock
root     2081617  0.0  0.0 722492 18896 ?        Sl   Apr23 167:40 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 07af3d5a39c90742367ec92a925e18900f635b0c8b0ad547856f1c9d7c7f507f -address /run/containerd/containerd.sock
root     2599849  0.0  0.0 722748 19432 ?        Sl   Aug08  83:39 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id a04a11434340fb13d601f84c506e60a522675fccec93e40cc81486d2c11f9f14 -address /run/containerd/containerd.sock
root     2686502  0.0  0.0 722748 19440 ?        Sl   Apr23 172:23 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 0193b62ea5d1b88ee9be1a3e10606158d3c8fe694dad82c0faae14c9bdb4fecc -address /run/containerd/containerd.sock
root     2708349  0.1  0.0 722748 21376 ?        Sl   Sep24 141:13 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id cccf2e3c521bdda5347e3480476ee5c9ee54549770c705d34c81bc991dd4ca54 -address /run/containerd/containerd.sock
root     2708544  0.0  0.0 722492 18944 ?        Sl   Sep24  49:27 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id e5a89b506c3641e3a0f5872357ecc21c124bd0b26a9c27f3b0e1ded8158efaa5 -address /run/containerd/containerd.sock
root     2709029  0.0  0.0 722492 19720 ?        Sl   Sep24  50:01 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 26462349c621ed381810c9521fbf00f00a6f3c666ae22582382665d192e57c60 -address /run/containerd/containerd.sock
root     2732269  0.0  0.0 722748 19488 ?        Sl   Apr23 185:52 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 01ef809f07762d29cbe56de30415e700caf2b935dd50db22d774b8ca4fee0faf -address /run/containerd/containerd.sock
root     2733493  0.0  0.0 722492 19756 ?        Sl   Apr23 194:35 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 987e0d9b5aefebced7ca935f387f9652819d72924fdbad6f7e9520bc929db6a4 -address /run/containerd/containerd.sock
root     2733785  0.0  0.0 722748 18228 ?        Sl   Apr23 188:21 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 6c3a27db3701363cf8af7c9e4760d66885ae082c6f84160121fd55b98a8a7de5 -address /run/containerd/containerd.sock
root     2735431  0.0  0.0 722492 19472 ?        Sl   Apr23 191:28 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 055d85ee71180c1ee72adb3a0501d3f7feac6fdf227d2845fa2dad7189629430 -address /run/containerd/containerd.sock
root     2933502  0.0  0.0 722748 13672 ?        Sl   Oct30  23:21 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 9300a59fba05abdb67c25ccf753d0a0f595dfbd402bd9e1deca798c64e0fbbfe -address /run/containerd/containerd.sock
root     2933583  0.0  0.0 722236 13776 ?        Sl   Oct30  22:26 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 34c4f5c8660f457cb8fdf0a39ce448e28e5f9056776d9ac3800857ce1a2d2bd5 -address /run/containerd/containerd.sock
root     2933613  0.0  0.0 722492 13768 ?        Sl   Oct30  23:00 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id cd6066db9f822f06856e3c99fa9e6ca39929abfb6386b618697de4904333d183 -address /run/containerd/containerd.sock
root     2933644  0.0  0.0 722748 13176 ?        Sl   Oct30  22:15 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 8f39ec9e88e234342e77f506f44c3719b7f25bb00f24afa89fc56a00b0c10ccf -address /run/containerd/containerd.sock
root     2933687  0.0  0.0 722748 14056 ?        Sl   Oct30  23:06 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id e1b27d349d8a4ca8b6dd09ee3eda38294d70e2e142bc5f9aa00d36c635c63281 -address /run/containerd/containerd.sock
root     2936518  0.0  0.0 722236 13848 ?        Sl   Oct30  22:19 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 4f3b2c46b9c623cf143aee55a512e4bdc8daa12ea281a11f4327eb6f26a7f02f -address /run/containerd/containerd.sock
root     2936627  0.0  0.0 722748 13684 ?        Sl   Oct30  25:05 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 9a2036d691b54f11717084f6eedcde20a04925f011faed731f05d5ed55d83bae -address /run/containerd/containerd.sock
root     2941713  0.0  0.0 722492 13732 ?        Sl   Oct30  23:27 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 2d12210d92fb4e7d2eec9883282df96c0851151499077c0f0e4b9bc4de3d259c -address /run/containerd/containerd.sock
root     2941831  0.0  0.0 722748 14136 ?        Sl   Oct30  23:11 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id e7eaf0aadc6c4a8e3bf8db18dcec68af37a2e73cdb1633c0d369416d2edbd602 -address /run/containerd/containerd.sock
root     2941973  0.0  0.0 722748 13460 ?        Sl   Oct30  23:08 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 4f5e1066d057b09b12e8c183ebf16cb37dffd4850d3d9905ae2a1a02475ee332 -address /run/containerd/containerd.sock
root     2942251  0.0  0.0 722748 14236 ?        Sl   Oct30  23:09 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 85ec9696788257bcfd8a86f53912c1b9fe735e7321cf5441f98f8cb47ee86cfe -address /run/containerd/containerd.sock
root     2953224  0.2  0.0 722492 18372 ?        Sl   Oct30 115:56 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id e58b822118553c446105129ff463c1267a539621532bbdf2f8cabdf6867ce20d -address /run/containerd/containerd.sock
root     2956850  0.1  0.0 722492 13644 ?        Sl   Oct30  66:13 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id e1edb9e2ecaf7ce32b6e7446bf3d886852c92518d8e1d194bbef47537ccade59 -address /run/containerd/containerd.sock
root     2972287  0.0  0.0 722748 13848 ?        Sl   Nov07  16:12 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 724a7c608be0808a8b31eb2422b869052abf1a0178db55d241562d6fb584925d -address /run/containerd/containerd.sock
root     2993739  0.0  0.0 722748 13584 ?        Sl   Nov07  16:19 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 4fe245d2e539867b4baab5e02543d4976cecaf1b8810943cad7e8712fe7cfd7a -address /run/containerd/containerd.sock
root     3068013  0.0  0.0 221940  1144 pts/1    S+   10:06   0:00 grep --color=auto containerd-shim
root     3094133  0.0  0.0 722492 14020 ?        Sl   Nov21   6:04 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id f49caf3a87de9861fa89eb89b95d1eee56a61e84e7ffe7dcb0978ba140cad5fa -address /run/containerd/containerd.sock
root     3248500  0.0  0.0 722748 18928 ?        Sl   Oct29  23:52 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 3d638ca4dc1c06ca2033439e78293bf68c339c7b17f0011a98629b0467d70c2e -address /run/containerd/containerd.sock
root     3250205  0.0  0.0 722236 19112 ?        Sl   Oct29  23:20 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id c5d2dced5d24349cb65ddc1eda99c2dd13fca3c06253118fcc17bf5ca88c3f4c -address /run/containerd/containerd.sock
root     3250900  0.0  0.0 722492 20092 ?        Sl   Oct29  22:53 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 280210a8428bb3a83fe77093863722717a5e4b7ba8762d65ce599577c41e9700 -address /run/containerd/containerd.sock
root     3251259  0.0  0.0 722236 18916 ?        Sl   Oct29  22:58 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 93617e98da0e8d126d6c0db36f1c64cd146cda8b58424647b1e8714e50f76343 -address /run/containerd/containerd.sock
root     3253111  0.0  0.0 722492 19508 ?        Sl   Oct29  23:15 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 62c6486c087d9c2897e74b376f93bbc9dc565ee7e72409e2749f41cc2aefa072 -address /run/containerd/containerd.sock
root     3254125  0.0  0.0 722748 19576 ?        Sl   Oct29  23:06 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 3baa60a9874c5f55257f9c1276ca4f92f0f60f18f5140f6551cb13d58b140f9a -address /run/containerd/containerd.sock
root     3254795  0.0  0.0 722748 19120 ?        Sl   Oct29  23:15 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 0c58077fc296d4d9eaca179a468c78a69b078115dbbf6a2629c5750d6d82d4b0 -address /run/containerd/containerd.sock
root     3256622  0.0  0.0 722492 19724 ?        Sl   Oct29  23:23 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 1673c27ec14c61b7652a2383f382bfc536ee177f30481fd7ba8a8f542e7ae982 -address /run/containerd/containerd.sock
root     3258114  0.0  0.0 722492 19080 ?        Sl   Oct29  22:55 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 2902bb957e9cf1528908e4db8f28e95473d290e1fa956da7a17ad56f7d69623f -address /run/containerd/containerd.sock
root     3259222  0.0  0.0 722236 19352 ?        Sl   Oct29  23:06 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 28950bc20be9d8be185babc5d8a79c089312fc6e4ecf67dc08210dbe78895570 -address /run/containerd/containerd.sock
root     3259915  0.0  0.0 722748 19524 ?        Sl   Oct29  23:02 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 61fc2a7f6e948e31a00ad0a6a43a99e602ac4784289fd02a02455d3508b1bdd7 -address /run/containerd/containerd.sock
root     3260679  0.0  0.0 722492 19300 ?        Sl   Oct29  23:07 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 9385a2e2e008ab05ef615db6b546370bfdd4fd3d24040283122af603a1a943ce -address /run/containerd/containerd.sock
root     3313507  0.0  0.0 722492 19940 ?        Sl   Apr24 178:27 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 5c7abbf37854fdea277097a3e65093e692a8730ec0dbcf8c47b827acba31c9a6 -address /run/containerd/containerd.sock
root     3386490  0.0  0.0 722748 13900 ?        Sl   Oct30  22:49 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 9e11958d6d60b8c1aa1c407c14cc63d45b1f6af28e8e5f4c1367cdcb900ef973 -address /run/containerd/containerd.sock
root     3721350  0.0  0.0 722492 13976 ?        Sl   Nov06  16:57 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 19fc1051d0f3be387140851f5a3a8902c10362f72e44bebe0dd428702131b1aa -address /run/containerd/containerd.sock
root     3773448  0.0  0.0 722748 20172 ?        Sl   Oct29  23:58 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 98bdb3441e81c49c4fe8963ac4624a1e2309c9200b1dc12d995f0c071072cbfe -address /run/containerd/containerd.sock
root     4007078  0.0  0.0 722748 13372 ?        Sl   Nov06  17:29 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 9cbee8b4b3dc2472c7acd5bebc5417d165aa8df1482a0c61375de83aa5e2462c -address /run/containerd/containerd.sock
root     4009657  0.0  0.0 722492 13528 ?        Sl   Nov06   1:43 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id cce80bf6211d7bfecb3a4c2b7f76da085e4ec9c667885fb9787c5b749ddd7968 -address /run/containerd/containerd.sock
root     4017939  0.0  0.0 722492 13284 ?        Sl   Nov06  16:54 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 5eeb4e6e0bf10be1b2e57bb3137afb9d670378f60af19c180211a4ecd3d2ac4b -address /run/containerd/containerd.sock
root     4098874  0.0  0.0 722492 13816 ?        Sl   Nov06  16:57 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id c12d60acc9700242b83d8b17d94fc47412f6f068448972e4e550ab1c88d4895e -address /run/containerd/containerd.sock
root     4108810  0.0  0.0 722492 14108 ?        Sl   Nov06  16:53 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 421d697bc661d089f4293e53e75fc6b667e8a727b18f77c5989be309136057a0 -address /run/containerd/containerd.sock
root     4110020  0.0  0.0 722748 13424 ?        Sl   Nov06  16:48 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id b8e7e1334c497dcc454fa3a7bd64875b3509614ecff486ca7208a80cbf77c560 -address /run/containerd/containerd.sock
root     4188292  0.0  0.0 722492 13776 ?        Sl   Nov06  17:00 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id cffea0ccb6868eb4648ba5e62c7f7ee10c25fa84e787d03eb5ea86faada6466e -address /run/containerd/containerd.sock
[root@sdv-dl360 ~]#
```

3773448 프로세스는 containerd-shim-runc-v2 로 실행된 컨테이너이고, <br>
id 는 98bdb3441e81c49c4fe8963ac4624a1e2309c9200b1dc12d995f0c071072cbfe 이다. <br>
아래 명령어중에 하나를 이용하여 해당 컨테이너 정보를 살펴본다.
```
ctr containers list | grep 98bdb3441e81
docker ps | grep 98bdb3441e81
nerdctl ps | grep 98bdb3441e81
```

```
[root@sdv-dl360 ~]# nerdctl ps | grep 98bdb3441e81
98bdb3441e81    registry.k8s.io/pause:3.9                                             "/pause"                  4 weeks ago     Up                 k8s://longhorn-system/csi-provisioner-68d785644d-jx7sg
[root@sdv-dl360 ~]#
```

longhorn-system/csi-provisioner 컨테이너이다. <br>
아래에서 보면, 이미 다른 인스턴스가 실행중임을 알 수 있다. 안전하게 삭제가 가능하다.
```
[root@sdv-dl360 ~]# nerdctl ps | grep csi-provisioner
32794c593197    docker.io/longhornio/csi-provisioner:v2.1.2                           "/csi-provisioner --…"    4 weeks ago     Up                 k8s://longhorn-system/csi-provisioner-68d785644d-jx7sg/csi-provisioner
98bdb3441e81    registry.k8s.io/pause:3.9                                             "/pause"                  4 weeks ago     Up                 k8s://longhorn-system/csi-provisioner-68d785644d-jx7sg
b5878d7c52e9    docker.io/longhornio/csi-provisioner:v2.1.2                           "/csi-provisioner --…"    4 weeks ago     Up                 k8s://longhorn-system/csi-provisioner-68d785644d-7jlbs/csi-provisioner
db15e58b2a82    k8s.gcr.io/sig-storage/csi-provisioner:v2.2.1                         "/csi-provisioner --…"    7 months ago    Up                 k8s://hostpath-provisioner/hostpath-provisioner-csi-scltz/csi-provisioner
e7eaf0aadc6c    registry.k8s.io/pause:3.9                                             "/pause"                  4 weeks ago     Up                 k8s://longhorn-system/csi-provisioner-68d785644d-7jlbs
[root@sdv-dl360 ~]#
```

일단 좀비상태인 자식 프로세스를 회수하는 방식으로 프로세스를 정리한다.<br>
그게 안되면 부모 프로세스를 종료하여 INIT 프로세스가 처리하도록 한다.

```
sudo kill -s SIGCHLD 3773448
```

해당 자식 프로세스(3790448)가 회수되는지 확인한다 

```
pstree -p 3773448 | grep 3790448
```

```
[root@sdv-dl360 ~]# sudo kill -s SIGCHLD 3773448
[root@sdv-dl360 ~]# pstree -p 3773448 | grep 3790448
containerd-shim(3773448)-+-csi-provisioner(3790448)---{csi-provisioner}(3790546)
[root@sdv-dl360 ~]#
```

부모 프로세스를 제거한다.
```
sudo kill 3773448
```

부모 프로세스는 죽었지만, 해당 좀비는 그대로 남아 있다.
```
[root@sdv-dl360 ~]# ps aux | grep 3790448
root     3128977  0.0  0.0 221940  1144 pts/1    S+   10:30   0:00 grep --color=auto 3790448
root     3790448  0.0  0.0      0     0 ?        Zsl  Oct29   0:06 [csi-provisioner] <defunct>
[root@sdv-dl360 ~]#
```

init(PID 1) 프로세스에게 인계되었지만, 삭제되지 않는다. <br>
리부팅이 필요해 보인다.
```
[root@sdv-dl360 ~]# ps -o ppid= -p 3790448
      1
[root@sdv-dl360 ~]#
```

