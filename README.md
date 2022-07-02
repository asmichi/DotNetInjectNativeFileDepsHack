# Asmichi.InjectNativeFileDepsHack

An *insane hack* to inject runtime assets into deps.json by injecting RuntimeTargetsCopyLocalItems items into the GenerateDepsFile task.

This library can be obtained via [NuGet](https://www.nuget.org/packages/Asmichi.InjectNativeFileDepsHack/).

# Background

By default (without `DllImportSearchPath.AssemblyDirectory`), the .NET runtime only loads native DLLs listed in the deps.json of an application. There is a long-standing issue: deps.json does not list native DLLs from reference projects (only native DLLs from NuGet packages), which means that such native DLLs cannot be loaded:

- https://github.com/dotnet/sdk/issues/765 Copy runtime libraries from references project
- https://github.com/dotnet/sdk/issues/1088 Allow runtime-specific assets in the project
- https://github.com/dotnet/sdk/issues/24708 Architecture-specific folders like runtimes/<rid>/native/ outside of NuGet packages [nativeinterop]

So, if you develop a library containing native DLLs, you get stuck. The test projects and sample projects will project-reference the library project, which does not work!

# WARNING

Again, this is an *insane hack* that plays with the implementation details deep inside the .NET SDK. It is likely that this will break **even by a minor version update** of the .NET SDK.

Tested on the following versions of the .NET SDK:

- 6.0.301

# Usage
List the native files as `InjectNativeFileDepsHack` items.

```xml
  <ItemGroup>
    <PackageReference Include="Asmichi.InjectNativeFileDepsHack" Version="0.1.0" PrivateAssets="all" IncludeAssets="runtime;build;native;contentfiles;analyzers" />
  </ItemGroup>

  <ItemGroup>
    <InjectNativeFileDepsHack Include="$(OutputPath)runtimes\linux-x64\native\libMyAwesomeLibrary.so">
      <!-- The relative path of the deployed files from the application directory. -->
      <DestinationSubDirectory>runtimes\linux-x64\native\libMyAwesomeLibrary.so</DestinationSubDirectory>
      <!-- RID -->
      <RuntimeIdentifier>linux-x64</RuntimeIdentifier>
    </InjectNativeFileDepsHack>
  </ItemGroup>
```

Notes:

- Normally you list the native DLLs as `Content` items in the library project, so the native DLLs should be copied into `$(OutputPath)`.
- You cannot use wildcards in `Include` to list files within output directories because these wild cards are evaluated before the build starts and thus output files do not yet exist.
