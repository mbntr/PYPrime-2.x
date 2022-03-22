# cython: language_level=3, binding=True, boundscheck=False, initializedcheck=False, unraisable_tracebacks=False, annotation_typing=False, cdivision=True

import sys
import os
import math
import locale
import subprocess

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
runs = 7
results = []
corr_results = []
primes = []


pr = 2048000000
vr = 2047999957

os.system("color")

COLOR = {
    "GREEN": "\033[92m",
    "RED": "\033[91m",
    "ENDC": "\033[0m"
}

memorytypes = {
    1: 'Other',
    2: 'Unknown',
    20: 'DDR',
    21: 'DDR2',
    22: 'DDR2 FB-DIMM',
    24: 'DDR3',
    26: 'DDR4',
    34: 'DDR5',
    27: 'LPDDR',
    28: 'LPDDR2',
    29: 'LPDDR3',
    30: 'LPDDR4',
    35: 'LPDDR5'
}

# Header

class Header:
    def __init__(self, qpf):
        command = "powershell.exe (Get-WMIObject win32_processor).name; " \
          "(Get-WMIObject win32_operatingsystem).name; " \
          "(Get-WmiObject Win32_PhysicalMemory Capacity, Speed, TotalWidth, SMBIOSMemoryType)"
        
        OSver = subprocess.run(command, shell=True, stdout=subprocess.PIPE, universal_newlines=True).stdout.split('\n')

        self.memspeed = list(filter(lambda a: 'Speed' in a, OSver))[0].split(': ')[1] 
        self.memcap = sum(int(item.split(':')[1]) for item in list(filter(lambda a: 'Capacity' in a, OSver))) // 1024 // 1024 // 1024
        self.buswidth = sum(int(item.split(':')[1]) for item in list(filter(lambda a: 'TotalWidth' in a, OSver)))
        try:
            self.memtype = memorytypes[int(list(filter(lambda a: 'SMBIOSMemoryType' in a, OSver))[0].split(': ')[1])]
        except KeyError:
            self.memtype = 'Unknown'
        self.OS = OSver[1].split('|')[0].split('\n')[-1]
        self.CPU = f"{OSver[0]}"
        self.qpf = qpf
        
	
    def output(self):
        hpr = pr // 1000000
        ppr = "M"
        
        if hpr > 1024:
            hpr //= 1024
            ppr = "B"
            
        if pr // 8 // 1000000000 > int(self.memcap):
            if pr // 8 // 1000000 < 1000:
                memall = f'{COLOR["RED"]}{pr // 8 // 1000000} MB  !!! WARNING !!! Insufficient memory resources{COLOR["ENDC"]}'
                
            elif pr // 8 // 1000000 > 1000:
                memall = f'{COLOR["RED"]}{pr // 8 // 1000000000} GB  !!! WARNING !!! Insufficient memory resources {COLOR["ENDC"]}'
        else:
            if pr // 8 // 1000000 < 1000:
                memall = f'{pr // 8 // 1000000} MB'
                
            elif pr // 8 // 1000000 > 1000:
                memall = f'{pr // 8 // 1000000000} GB'
                
    
        print(f"{85 * '-'}\n{35 * ' '}PYPrime 2.2 Windows{35 * ' '}\n{85 * '-'}\n\n" 
              f' OS                 : {self.OS}, Build {version()}\n' 
              f' CPU                : {self.CPU}\n'
              f' RAM                : {self.memcap} GB {self.memtype} @ {self.memspeed} MT/s - {self.buswidth} bit\n\n'
              
              f' Benchmark Version  : PYPrime 2.2, Build 220322\n' 
              f' Prime              : {hpr}{ppr} - up to {pr:n}\n'
              f' Python Version     : Python {sys.version_info[0]}.{sys.version_info[1]}.{sys.version_info[2]}\n'
              f' Memory Allocation  : {memall}\n'
              f' Timer              : {round(self.qpf / 1000000, 2)} MHz\n', flush=True) 
              

# Score

class Score:   
    def __init__(self, time):
        self.time = time

    def output(self):
            print(f"\n Average computation time : {round(self.time, 3):0.3f} s\n")


# Benchmark

cdef print_status(int loop, ull qpf, ull start_time):
    end_time = wintypes.LARGE_INTEGER()

    kernel32.QueryPerformanceCounter(byref(end_time))
    
    print(f" |{'█'* (loop * 2) + ' '* (18 - loop * 2)}| step {loop} --- {round((end_time.value - start_time) / qpf, 3))} s   ", end="\r")

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

    start_time = wintypes.LARGE_INTEGER()
    end_time = wintypes.LARGE_INTEGER()

    cdef ull resultx, result
    cdef ull sieve_len = (limit // 8) + 1

    
    sieve_data = cvarray(shape=(sieve_len,), itemsize=sizeof(unsigned char), format="B")
    cdef unsigned char[::1] sieve = sieve_data

    
    # Start timestamp
    kernel32.QueryPerformanceCounter(byref(start_time))

    # Calculation
    resultx = calc(sieve, limit, int(math.sqrt(limit)), qpf, start_time.value)

    # End timestamp
    kernel32.QueryPerformanceCounter(byref(end_time))

    # Finish the calculation
    result = (sieve[resultx].bit_length() - 1) + resultx * 8
    time = round((end_time.value - start_time.value) / qpf, 3)


    return [ result, result == vr, time ]


# Main

while True:
    
    # to be replaced with case matching
    if len(sys.argv) != 1:
        # Command line parameters
        for i in sys.argv[1:]:
    
            if i.upper() == "32M":
                pr = 32000000
                vr = 31999939
                break
    
            if i.upper() == "64M":
                pr = 64000000
                vr = 63999979
                break
    
            if i.upper() == "128M":
                pr = 128000000
                vr = 127999981
                break
    
            if i.upper() == "256M":
                pr = 256000000
                vr = 255999983
                break
    
            if i.upper() == "512M":
                pr = 512000000
                vr = 511999979
                break
    
            if i.upper() == "1024M" or i.upper() == "1B":
                pr = 1024000000
                vr = 1023999989
                break
    
            if i.upper() == "2048M" or i.upper() == "2B":
                pr = 2048000000
                vr = 2047999957
                break
    
            if i.upper() == "4096M" or i.upper() == "4B":
                pr = 4096000000
                vr = 4095999983
                break
    
            if i.upper() == "8192M" or i.upper() == "8B":
                pr = 8192000000
                vr = 8191999993 
                break
    
            if i.upper() == "16B":
                pr = 16384000000
                vr = 16383999977
                break
    
            if i.upper() == "32B":
                pr = 32768000000
                vr = 32767999997
                break
            
            if i.upper() == "64B":
                pr = 65536000000
                vr = 65535999941
                break
                
            else:
                print("Usage:\nPYPrime.exe [32-1024M or 1-64B] [Number of iterations, the default is 7]\n\nBenchmark written by Monabuntur, build 220322")
                sys.exit()

        if len(sys.argv) == 2:
            runs = 7
    
        if len(sys.argv) == 3:
            try:
                runs = int(sys.argv[2])
    
            except ValueError or IndexError:
                print("Usage:\nPYPrime.exe [32-1024M or 1-64B] [Number of iterations, the default is 7]\n\nBenchmark written by Monabuntur, build 220322")
                sys.exit()
    
    
    # Header
    qpf = wintypes.LARGE_INTEGER()

    kernel32.QueryPerformanceFrequency(byref(qpf))

    Header = Header(qpf.value)
    Header.output()
    
    input("Press ENTER to start the benchmark:")
    print(" ") 
        
    for i in range(runs):
        # Benchmark
        run = benchmark(pr, qpf.value)            
            
        valid = ("GREEN", "VALID") if run[1] else ("RED", "INVALID")
        # Output end time
        print(f' Run {i + 1} {COLOR[valid[0]]} {valid[1]} {COLOR["ENDC"]} ------ Completed in {format(run[2], ".3f")} s; Prime: {run[0]:n}')
        
        if not run[1]:
            break
    
        results.append(run[2])
        
    else:   
       
        try:
            import numpy
        
            std = numpy.std(results)
        
            for t in results:
                if t >= numpy.mean(results) - std and t <= numpy.mean(results) + std:
                    corr_results.append(t)

            Score = Score(numpy.mean(corr_results))
            Score.output()
            
        except ModuleNotFoundError:
            
            print("\nPlease install numpy for more precise results")         

            Score = Score(sum(results) / len(results))
            Score.output()
				
    input("Press ENTER to exit")
    
    break
