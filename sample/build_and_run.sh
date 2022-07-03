#!/bin/bash
#
# cd to here and run this on an x64 Linux system.
#

mkdir -p libHelloWorld/bin

gcc -g -gdwarf -std=c11 -fPIC -Wextra -Wswitch -Wswitch -Werror -O0 -fno-omit-frame-pointer -Wl,--no-undefined -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -shared -Wl,-soname,libHelloWorld.so -Wl,--version-script=libHelloWorld/libHelloWorld.version libHelloWorld/libHelloWorld.c -o libHelloWorld/bin/libHelloWorld.so

dotnet run --project HelloWorldApp
