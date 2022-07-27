# PYPrime-3.x
PYPrime is an open source python based benchmark that scales well with RAM clock, timings and overall latency, less so with CPU speed.

When compiling it yourself you should first install cython

    pip install cython 
  
after that you can cythonize the .pyx file
  
    cython --embed -3 -o PYPrime.c PYPrime.pyx 
    
Now you can compile the file, on windows use something like this, this will be slightly different on your PC, 

    cl PYPrime.c /O2 /Oi /Ot /GL /Gy /fp:fast /I "[Path to python]\include" /link /OPT:REF,ICF /LIBPATH:"[Path to python]\libs"
    
On linux you can use either gcc or Clang, I chose Clang as the performance is closer to what you would get on windows*
You might have to replace "python3.7" with later versions depending on what you have currently installed
    
    clang -O3 -I /usr/include/python3.7 PYPrime.c -lpython3.7m -o PYPrime
    
    
*Keep in mind that you can't use this version directly on Linux since uses Query Performance Counter from Kernel32.dll, which is only available on Windows, you can replace those lines of code with time.perf_counter()



On macOS the procedure isn't as straight forward, first you have to install python 3 and Xcode, then you have to edit the output file (PYPrime.c)
I decided to use Python 3.9 as it will also support arm based macs, but you can use basically whatever version you want

you will find something akin to this

    #include "Python.h"

For the compilation to work you'll have to change it to the directory of your Python 3 installation, for example:

    #include "/Library/Frameworks/Python.framework/Versions/3.9/include/python3.9/Python.h"
    
Then you may compile the program:

    clang -O3 -L /Library/Frameworks/Python.framework/Versions/3.9/lib -lpython3.9 -I /Library/Frameworks/Python.framework/Versions/3.9/include/python3.9  PYPrime.c -o PYPrime


You can find precompiled binaries for most architectures and OSes here:

https://github.com/monabuntur/PYPrime-2.x/releases

PYPrime is also available from Winget 

A huge thanks goes to the guys at BenchMate without whom this wouldn't have been possible!
