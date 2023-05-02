#!/bin/bash
#
# cd to here and run this on an x64 Linux system.
#
set -eu

case ${1-sample} in
    test)
        # Use this sample as the test
        options="-p:ImportCurrentTargets=true"
        ;;
    sample)
        options=""
        ;;
    *)
        echo Unknown mode $1
        exit 1
        ;;
esac

mkdir -p libHelloWorld/bin

gcc -g -gdwarf -std=c11 -fPIC -Wextra -Wswitch -Wswitch -Werror -O0 -fno-omit-frame-pointer -Wl,--no-undefined -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -shared -Wl,-soname,libHelloWorld.so -Wl,--version-script=libHelloWorld/libHelloWorld.version libHelloWorld/libHelloWorld.c -o libHelloWorld/bin/libHelloWorld.so

dotnet clean --nologo -v:minimal
dotnet run --project HelloWorldApp $options
dotnet run -r linux-x64 --no-self-contained --project HelloWorldApp $options
