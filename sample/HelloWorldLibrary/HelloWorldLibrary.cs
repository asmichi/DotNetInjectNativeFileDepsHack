using System.Runtime.InteropServices;

namespace HelloWorld;

public static class HelloWorldLibrary
{
    public static void HelloWorld() => NativeHelloWorld();

    [DllImport("libHelloWorld")]
    private static extern void NativeHelloWorld();
}
