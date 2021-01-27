# cython: language_level=3, binding=True, wraparound=False, boundscheck=False, initializedcheck=False, unraisable_tracebacks=False, annotation_typing=False, cdivision=True

import sys
import math
import locale

from cython.view cimport array as cvarray
from libc.stdio cimport printf

from platform import system, release, version
from ctypes import WinDLL, wintypes, byref

locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')

# Types
ctypedef unsigned long long ull

# Imports kernel32.dll
kernel32 = WinDLL('kernel32', use_last_error=True)

# Globals
cdef ull pr = 0
cdef ull vr = -1

# Header

class Header:
    def __init__(self, qpf):
        self.OS = f'{system()} {release()}, Build {version()}'
        self.qpf = qpf

    def output(self):
        hpr = pr // 1000000
        ppr = "M"
        
        if hpr > 1024:
            hpr //= 1000
            ppr = "B"
    
        print(f"{85 * '-'}\n{35 * ' '}PYPrime 2.0 BenchMate{35 * ' '}\n{85 * '-'}\n\n" \
              f'OS    : {self.OS}\n' \
              f'Timer : {round(self.qpf / 1000000, 2)} MHz\n' \
              f'Prime : {hpr}{ppr} - up to {pr:n}\n', flush=True)

# Score

class Score:   
    def __init__(self, prime, valid, time):
        self.prime = prime
        self.valid = valid
        self.time = time

    def output(self):
        if not self.valid:
            print(f"\nINVALID: {self.prime}", flush=True)
        else:
            line1 = f"Prime number     : {self.prime:n} is VALID"
            line2 = f"Computation time : {round(self.time, 3):0.3f} s"

            print("\n".join(["", line1, line2]), flush=True)


# Benchmark

def print_memalloc(bytes):
    size = bytes / 1000000000
    name = "GB"

    if size < 1.0:
        size = bytes / 1000000
        name = "MB"
        
        if size < 1.0:
            size = bytes / 1000
            name = "KB"
    
    print("Sieve allocation: {:0.1f} {}".format(round(size, 1), name), flush=True)

cdef print_status(int loop, ull qpf, ull start_time):
    end_time = wintypes.LARGE_INTEGER()

    kernel32.QueryPerformanceCounter(byref(end_time))

    print("    Step {:} ....... {:0.3f} s".format(loop, round((end_time.value - start_time) / qpf, 3)), flush=True)

cdef ull calc(unsigned char [::1] sieve, ull limit, ull sqrtlimit, ull qpf, ull start_time) nogil:
    cdef ull limit1, sqrtlimit1, loopstep, nextstep, x, x2, x2b3, x2b4, y, y2, n, m, o, nd, md
    cdef int loop = 0

    # Calculation
    limit1 = limit + 1
    sqrtlimit1 = sqrtlimit + 1

    loopstep = sqrtlimit / 10
    nextstep = loopstep

    # for x in range(1, sqrtlimit + 1):
    x = 1
    while x < sqrtlimit1:
        x2 = x ** 2
        x2b3 = x2 * 3
        x2b4 = x2b3 + x2

        # for y in range(1, sqrtlimit + 1):
        y = 1
        while y < sqrtlimit1:
            y2 = y ** 2

            n = x2b4 + y2
            nd = n % 12

            if n <= limit and (nd == 1 or nd == 5):
                sieve[n / 8] ^= 1 << (n % 8)

            m = x2b3 + y2
            md = m % 12

            if m <= limit and md == 7:
                sieve[m / 8] ^= 1 << (m % 8)

            o = x2b3 - y2

            if x > y and o <= limit and o % 12 == 11:
                sieve[o / 8] ^= 1 << (o % 8)

            y += 1

        if loop < 9 and x > nextstep:
            nextstep += loopstep
            loop += 1

            with gil:
                print_status(loop, qpf, start_time)

        x += 1

    # for x in range(5, sqrtlimit):
    x = 5
    while x < sqrtlimit:
        if sieve[x]:
            x2 = x ** 2

            # for y in range(x2, limit + 1, x2):
            y = x2
            while y < limit1:
                sieve[y / 8] &= ~(1 << (y % 8));
                
                y += x2

        x += 1

    # for p in range(limit, 5, -1):
    x = limit // 8
    while x > 0:
        if sieve[x] == 0:
            x -= 1
            continue

        break

    return x

cdef benchmark(ull limit, ull qpf):
    cdef ull resultx, result
    cdef ull sieve_len = (limit // 8) + 1

    start_time = wintypes.LARGE_INTEGER()
    end_time = wintypes.LARGE_INTEGER()

    # Memory allocation
    print_memalloc(sieve_len)

    sieve_data = cvarray(shape=(sieve_len,), itemsize=sizeof(unsigned char), format="B")
    cdef unsigned char[::1] sieve = sieve_data

    print("Starting benchmark:\n", flush=True)

    # Start timestamp
    kernel32.QueryPerformanceCounter(byref(start_time))

    # Calculation
    resultx = calc(sieve, limit, int(math.sqrt(limit)), qpf, start_time.value)

    # End timestamp
    kernel32.QueryPerformanceCounter(byref(end_time))

    # Finish the calculation
    result = (sieve[resultx].bit_length() - 1) + resultx * 8
    time = round((end_time.value - start_time.value) / qpf, 3)

    # Output end time
    print("    Sieve Scan ... {:0.3f} s".format(time), flush=True)

    return [ result, result == vr, time ]


# Main

while True:
    # Command line parameters
    for i in sys.argv:
        if i == "1M":
            pr = 1000000
            vr = 999983
            break
        if i == "2M":
            pr = 2000000
            vr = 1999993
            break
        if i == "4M":
            pr = 4000000
            vr = 3999971
            break
        if i == "8M":
            pr = 8000000
            vr = 7999993
            break
        if i == "16M":
            pr = 20000000
            vr = 19999999
            break
        if i == "32M":
            pr = 32000000
            vr = 31999939
            break
        if i == "64M":
            pr = 64000000
            vr = 63999979
            break
        if i == "128M":
            pr = 128000000
            vr = 127999981
            break
        if i == "256M":
            pr = 256000000
            vr = 255999983
            break
        if i == "512M":
            pr = 512000000
            vr = 511999979
            break
        if i == "1024M" or i == "1B":
            pr = 1024000000
            vr = 1023999989
            break
        if i == "2048M" or i == "2B":
            pr = 2048000000
            vr = 2047999957
            break
        if i == "4096M" or i == "4B":
            pr = 4096000000
            vr = 4095999983
            break
        if i == "8192M" or i == "8B":
            pr = 8192000000
            vr = 8191999993
            break
        if i == "16384M" or i == "16B":
            pr = 16384000000
            vr = 16383999977
            break
        if i == "32768M" or i == "32B":
            pr = 32768000000
            vr = 32767999997
            break

    if pr == 0:
        print("Usage: PYPrime.exe [1-1024M, 1-32B]")
        break

    # Header
    qpf = wintypes.LARGE_INTEGER()

    kernel32.QueryPerformanceFrequency(byref(qpf))

    Header = Header(qpf.value)
    Header.output()

    # Benchmark
    run = benchmark(pr, qpf.value)
    #print(f"RUN: {run}")

    # Score
    Score = Score(run[0], run[1], run[2])
    Score.output()

    break
