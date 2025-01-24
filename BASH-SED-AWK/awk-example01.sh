#!/bin/bash

TRANS_FILE="./Input/D-probe/Transport (FLU-013)/TRANSPORT_R1_20180718_1600.txt"
HTTP_FILE="./Input/D-probe/Http (FLU-013)/HTTP_R1_20180718_1600.txt"
DNS_FILE="./Input/D-probe/DNS (FLU-013)/DNS_R1_20180718_1600.txt"


function trans_pkts()
{
# extract transport xDR uplink/downlink packet sum
# column refs trans_in.txt
# $101 - Traffic.Total.Uplink.PacketCount
# $111 - Traffic.Total.Dnlink.PacketCount
awk -F\\t '
BEGIN {
    PKTS_UP = 0
    PKTS_DOWN = 0
}
{
    PKTS_UP += $101
    PKTS_DOWN += $111
}
END {
    printf("%d %d %d\n", (PKTS_UP + PKTS_DOWN), PKTS_UP, PKTS_DOWN)
}' "$TRANS_FILE"
}


function trans_proto_pkt_ratio()
{
# extract transport xDR uplink/downlink packet sum per protocols
# then sort, print only top 10 (sed '1,10p)
awk -F\\t '
BEGIN {
    for (i = 0; i < 256; i = i + 1) {
        PROTO_UP[i] = 0
        PROTO_DN[i] = 0
    }
    ALL_UP=0
    ALL_DN=0
    printf("Sum Uplink Downlink #Proto (Ratio%%)\n")
}
{
    PROTO_UP[$47] += $101
    PROTO_DN[$47] += $111
    ALL_UP += $101
    ALL_DN += $111
}
END {
    for (i = 0; i < 256; i = i + 1) {
        printf("%d %d %d %d (%5.02f)\n",
            (PROTO_UP[i] + PROTO_DN[i]),
            PROTO_UP[i],
            PROTO_DN[i],
            i,
            (PROTO_UP[i]+PROTO_DN[i])*100/(ALL_UP+ALL_DN))
        }
}' "$TRANS_FILE" | sort -nr | sed -ne '1,10p'
}


function trans_tcp_port_pkt_ratio()
{
# extract transport xDR TCP uplink/downlink packet sum per tcp port
# then sort, print only top 10 ports (sed '1,10p)
awk -F\\t '
BEGIN {
    for (i = 0; i < 65536; i = i + 1) {
        PORT_UP[i] = 0
        PORT_DN[i] = 0
    }
    ALL_UP=0
    ALL_DN=0
    printf("Sum Uplink Downlink #Port (Ratio%%)\n")
}
{
    if ($47 == 6) {
        PORT_UP[$51] += $101
        PORT_DN[$51] += $111
        ALL_UP += $101
        ALL_DN += $111
    }
}
END {
    for (i = 0; i < 65536; i = i + 1) {
        printf("%d %d %d %d (%5.02f)\n",
            (PORT_UP[i] + PORT_DN[i]),
            PORT_UP[i],
            PORT_DN[i],
            i,
            (PORT_UP[i]+PORT_DN[i])*100/(ALL_UP+ALL_DN))
        }
}' "$TRANS_FILE" | sort -nr | sed -ne '1,10p'
}


function trans_udp_port_pkt_ratio()
{
# extract transport xDR UDP uplink/downlink packet sum per tcp port
# then sort, print only top 10 ports (sed '1,10p)
awk -F\\t '
BEGIN {
    for (i = 0; i < 65536; i = i + 1) {
        PORT_UP[i] = 0
        PORT_DN[i] = 0
    }
    ALL_UP=0
    ALL_DN=0
    printf("Sum Uplink Downlink #Port (Ratio%%)\n")
}
{
    if ($47 == 17) {
        PORT_UP[$51] += $101
        PORT_DN[$51] += $111
        ALL_UP += $101
        ALL_DN += $111
    }
}
END {
    for (i = 0; i < 65536; i = i + 1) {
        printf("%d %d %d %d (%5.02f)\n",
            (PORT_UP[i] + PORT_DN[i]),
            PORT_UP[i],
            PORT_DN[i],
            i,
            (PORT_UP[i]+PORT_DN[i])*100/(ALL_UP+ALL_DN))
        }
}' "$TRANS_FILE" | sort -nr | sed -ne '1,10p'
}


function trans_proto_xdr_ratio()
{
# extract record which has both HTTP and TRANS has the same imsi(6)
awk -F\\t '
BEGIN {
    for (i = 0; i < 256; i = i + 1)
        TRANS_PROTO[i] = 0


    printf("#xDR Protocol Ratio(%%)\n")
}
{ TRANS_PROTO[$47]++; }
END {
    for (i = 0; i < 256; i = i + 1) {
        if (TRANS_PROTO[i] > 0)
            printf("%d: %d (%5.02f %%)\n", TRANS_PROTO[i], i, TRANS_PROTO[i]/NR * 100)
    }
}' "$TRANS_FILE" | sort -rn | sed -ne '1,10p'
}


function trans_tcp_port_xdr_ratio()
{
# extract record which has both HTTP and TRANS has the same imsi(6)
awk -F\\t '
BEGIN {
    TCP=0
    for (i = 0; i < 65536; i = i + 1)
        TRANS_PORT[i] = 0


    printf("#xDR Port Ratio(%%)\n")
}
{
    if ($47 == 6) {
        TRANS_PORT[$51]++;
        TCP++;
    }
}
END {
    for (i = 0; i < 65536; i = i + 1) {
        if (TRANS_PORT[i] > 0)
            printf("%d: %d (%5.02f %%)\n", TRANS_PORT[i], i, TRANS_PORT[i]/TCP * 100)
    }
}' "$TRANS_FILE" | sort -rn | sed -ne '1,10p'
}


function trans_udp_port_xdr_ratio()
{
# extract record which has both HTTP and TRANS has the same imsi(6)
awk -F\\t '
BEGIN {
    UDP=0
    for (i = 0; i < 65536; i = i + 1)
        TRANS_PORT[i] = 0


    printf("#xDR Port Ratio(%%)\n")
}
{
    if ($47 == 17) {
        TRANS_PORT[$51]++;
        UDP++;
    }
}
END {
    for (i = 0; i < 65536; i = i + 1) {
        if (TRANS_PORT[i] > 0)
            printf("%d: %d (%5.02f %%)\n", TRANS_PORT[i], i, TRANS_PORT[i]/UDP* 100)
    }
}' "$TRANS_FILE" | sort -rn | sed -ne '1,10p'
}




function http_pkts()
{
# extract transport xDR uplink/downlink packet sum
awk -F\\t '
BEGIN {
    PKTS_UP=0
    PKTS_DOWN=0
}
{
    PKTS_UP+=$101
    PKTS_DOWN+=$111
}
END {
    printf("%d %d %d\n", PKTS_UP+PKTS_DOWN, PKTS_UP, PKTS_DOWN)
}' "$HTTP_FILE"
}


function dns_pkts()
{
# extract transport xDR uplink/downlink packet sum
awk -F\\t '
BEGIN {
    PKTS_UP=0
    PKTS_DOWN=0
}
{
    PKTS_UP+=$101
    PKTS_DOWN+=$111
}
END {
    printf("%d %d %d\n", PKTS_UP+PKTS_DOWN, PKTS_UP, PKTS_DOWN)
}' "$DNS_FILE"
}


# ---------------------------------------------------------------------------


TRANS_NR=$(cat "$TRANS_FILE" | wc -l)
HTTP_NR=$(cat "$HTTP_FILE" | wc -l)
DNS_NR=$(cat "$DNS_FILE" | wc -l)
let TOTAL_NR=$TRANS_NR+$HTTP_NR+$DNS_NR


printf "XDR Records Statistics\n"
printf "TOTAL %d\n" $TOTAL_NR
printf "TRANS %d(%d %%)\n" $TRANS_NR $(($TRANS_NR*100/$TOTAL_NR))
printf "HTTP %d(%d %%)\n" $HTTP_NR $(($HTTP_NR*100/$TOTAL_NR))
printf "DNS %d(%d %%)\n" $DNS_NR $(($DNS_NR*100/$TOTAL_NR))
echo ""


echo "Trans Protocol XDR Statistics"
trans_proto_xdr_ratio
echo ""


echo "Trans/TCP Port XDR Statistics"
trans_tcp_port_xdr_ratio
echo ""


echo "Trans/UDP Port XDR Statistics"
trans_udp_port_xdr_ratio
echo ""


# ---------------------------------------------------------------------------


TRANS_PKTS=$(trans_pkts | cut -d ' ' -f 1)
HTTP_PKTS=$(http_pkts | cut -d ' ' -f 1)
DNS_PKTS=$(dns_pkts | cut -d ' ' -f 1)
let TOTAL_PKTS=$TRANS_PKTS+$HTTP_PKTS+$DNS_PKTS


printf "XDR Packet Statistics\n"
printf "TOTAL %d\n" $TOTAL_PKTS
printf "TRANS %d(%d %%)\n" $TRANS_PKTS $(($TRANS_PKTS*100/$TOTAL_PKTS))
printf "HTTP %d(%d %%)\n" $HTTP_PKTS $(($HTTP_PKTS*100/$TOTAL_PKTS))
printf "DNS %d(%d %%)\n" $DNS_PKTS $(($DNS_PKTS*100/$TOTAL_PKTS))
echo ""


printf "TRANS Top 10 Proto Packets\n"
trans_proto_pkt_ratio
echo ""


printf "TRANS/TCP Top 10 Port Packets\n"
trans_tcp_port_pkt_ratio
echo ""


printf "TRANS/UDP Top 10 Port Packets\n"
trans_udp_port_pkt_ratio
echo ""