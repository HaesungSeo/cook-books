<h1>STP RSTP MSTP 표준</h1>


STP - IEEE 802.1D http://standards.ieee.org/about/get/802/802.1.html <br>
RSTP - IEEE 802.1s <br>
MSTP - IEEE 802.1w <br>
STP/RSTP/MSTP - IEEE 802.1Q-2014 <br>


## L2스위치가 MAC 주소를 가지는 이유

IEEE 802.1D-2014 9.2.5절 세번째 단락 (아래) <br>
NOTE 2 The number of bits that are considered to be part of the system ID (60 bits) differs in this version of the
standard from the 1998 and prior versions (formerly, the priority component was 16 bits and the system ID component
48 bits). This change was made in order to allow implementations of Multiple Spanning Trees (IEEE Std 802.1Q) to
make use of the 12-bit system ID extension as a means of generating a distinct Bridge Identifier per VLAN, rather than
forcing such implementations to allocate up to 4094 MAC addresses for use as Bridge Identifiers. To maintain
management compatibility with older implementations, the priority component is still considered, for management
purposes, to be a 16-bit value, but the values that it can be set to are restricted to only those values where the least
significant 12 bits are zero (i.e., only the most significant 4 bits are settable).

STP의 ID를 위해 최소한 1개의 MAC이 필요하다. (MSTP등은 4094개 VLAN별로 ID를 만들기 위해 MAC을 4094개 가지는것이 아니라
하나의 스위치 MAC으로부터 4094개를 고유하게 생성하는 방식이 있다.) <br>

https://learningnetwork.cisco.com/thread/15380
> Does every port of Switch has its own unique MAC address?

L2스위치가 포트별로 다른 MAC 주소를 가지는 이유
> https://en.wikipedia.org/wiki/MAC_address : BPDU의 소스맥?

IEEE 802.1AD-2004 7.12.3 마지막 단락 <br>
The source address field of MAC frames conveying BPDUs or GARP PDUs for GARP Applications
supported by the Bridge shall convey the individual MAC Address for the Bridge Port through which the
PDU is transmitted (7.12.2).

https://learningnetwork.cisco.com/thread/66346
> BPDU 같은데서 쓰이는건 맞지만.. 그건 PORT ID를 이용해도 된다. (일리가 있음..) 


