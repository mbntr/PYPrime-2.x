# PYPrime-2.x
PYPrime 2 is an open source python based benchmark that scales well with RAM clock, timings and overall latency, less so with CPU speed.

When compiling it yourself you should first install cython

    pip install cython 
  
after that you can cythonize the .pyx file
  
    cython --embed -3 -o PYPrime.c PYPrime.pyx 
    
Now you can compile the file, on windows use something like this, this will be slightly different on your PC, 

    cl PYPrime.c /O2 /Oi /Ot /GL /Gy /fp:fast /I "[Path to python]\include" /link /OPT:REF,ICF /LIBPATH:"[Path to python]\libs"

    xcopy /Y /Q PYPrime.exe workload-PYPrime.exe
    
On linux you can use either gcc or Clang, I chose Clang since the performance is closer to what you get on windows*
You might have to replace "python3.7" with later versions depending on what you have currently installed
    
    clang -O3 -I /usr/include/python3.7 PYPrime.c -lpython3.7m -o PYPrime
    
    
    
    
*Keep in mind that you can't use this version directly on Linux since uses Query Performance Counter from Kernel32.dll, which is only available on Windows, you can replace those lines of code with time.perf_counter()

You can find precompiled binaries here:

http://pyprime.servehttp.com/PYPrime/Downloads2.html



A huge thanks goes to the guys at BenchMate without whom this wouldn't have been possible!
