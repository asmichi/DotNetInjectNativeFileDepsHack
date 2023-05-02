using System.Runtime.InteropServices;

[assembly: DefaultDllImportSearchPaths(DllImportSearchPath.System32)]

namespace HelloWorld;

public static class HelloWorldLibrary
{
    public static void HelloWorld() => NativeHelloWorld();

    [DllImport("libHelloWorld")]
    private static extern void NativeHelloWorld();
}
