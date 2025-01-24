#!/usr/bin/env python3

import sys

def cpu_list_to_hex_mask(cpu_list_str: str) -> str:
    """
    예: "1-8,10-11,100-112" -> "ffffffff,fffffff0,001fffff" (예시 형식)
    
    CPU 코어 목록을 파싱하여 bitmask(정수)로 만들고,
    이 bitmask를 32비트씩 잘라 16진수 형태로 콤마 구분하여 문자열로 반환한다.
    """
    bitmask = 0
    highest_bit = 0
    
    # "1-3,5,7-9" 형태를 파싱
    if not cpu_list_str.strip():
        # 빈 문자열인 경우(코어가 하나도 없다는 의미로 볼 수 있음)
        return "00000000"
    
    for part in cpu_list_str.split(','):
        part = part.strip()
        if '-' in part:
            start, end = part.split('-')
            start, end = int(start), int(end)
            if start > end:
                start, end = end, start
            for core_id in range(start, end + 1):
                bitmask |= (1 << core_id)
                highest_bit = max(highest_bit, core_id)
        else:
            core_id = int(part)
            bitmask |= (1 << core_id)
            highest_bit = max(highest_bit, core_id)
    
    # 몇 개의 32비트 덩어리가 필요한지 계산
    n_chunks = (highest_bit // 32) + 1 if highest_bit >= 0 else 1
    
    chunks = []
    for i in reversed(range(n_chunks)):
        val = (bitmask >> (32 * i)) & 0xffffffff
        # 8자리 16진수로 출력 (소문자)
        chunks.append(f"{val:08x}")
    
    # LSB(낮은 비트)부터 높은 비트 순으로 출력할 때, 왼쪽(문자열 첫 부분)이 가장 낮은 비트
    # 즉, chunks[0]은 코어 인덱스 0~31에 해당
    return ",".join(chunks)


def hex_mask_to_cpu_list(hex_mask_str: str) -> str:
    """
    예: "ffffffff,fffffff0,001fffff" -> "1-8,10-11,100-112" (예시 형식)
    
    콤마로 구분된 32비트 단위 16진수 문자열을 읽어 bitmask로 복원한 뒤,
    set된 비트들의 인덱스를 연속 구간으로 묶어서 "시작-끝" 형태 목록으로 반환한다.
    """
    if not hex_mask_str.strip():
        return ""
    
    chunks = hex_mask_str.split(',')
    bitmask = 0
    for i, chunk in enumerate(chunks):
        chunk = chunk.strip()
        val = int(chunk, 16)
        bitmask |= (val << (32 * i))
    
    # set된 비트(코어 인덱스) 찾기
    set_bits = []
    pos = 0
    temp_mask = bitmask
    while temp_mask > 0:
        if temp_mask & 1:
            set_bits.append(pos)
        temp_mask >>= 1
        pos += 1
    
    if not set_bits:
        # 모두 0이면 아무 코어도 없다는 의미
        return ""
    
    # 연속 구간으로 묶기
    ranges = []
    start = set_bits[0]
    prev = set_bits[0]
    for b in set_bits[1:]:
        if b == prev + 1:
            prev = b
        else:
            if start == prev:
                ranges.append(str(start))
            else:
                ranges.append(f"{start}-{prev}")
            start = b
            prev = b
    # 마지막 구간 처리
    if start == prev:
        ranges.append(str(start))
    else:
        ranges.append(f"{start}-{prev}")
    
    return ",".join(ranges)


def print_usage():
    print(f"Usage:")
    print(f"  {sys.argv[0]} list2hex <CPU_LIST>    # 예: {sys.argv[0]} list2hex 1-8,10-11,100-112")
    print(f"  {sys.argv[0]} hex2list <HEX_MASK>   # 예: {sys.argv[0]} hex2list ffffffff,fffffff0,001fffff")
    sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print_usage()
    
    mode = sys.argv[1]
    data = sys.argv[2]
    
    if mode == "list2hex":
        # "1-8,10-11,100-112" -> "ffffffff,fffffff0,001fffff"
        result = cpu_list_to_hex_mask(data)
        print(result)
    elif mode == "hex2list":
        # "ffffffff,fffffff0,001fffff" -> "1-8,10-11,100-112"
        result = hex_mask_to_cpu_list(data)
        print(result)
    else:
        print_usage()

