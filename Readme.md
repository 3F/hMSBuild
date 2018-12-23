# [hMSBuild](https://github.com/3F/hMSBuild)

Compiled text-based embeddable pure batch-scripts (no powershell or dotnet-cli) for searching of available MSBuild tools. VS2017+ (does not require local vswhere.exe [[?](https://github.com/Microsoft/vswhere/issues/41)]), VS2015, VS2013, VS2010, other versions from .NET Framework. Contains [gnt.core](https://github.com/3F/GetNuTool) for work with NuGet packages and more...


[![Build status](https://ci.appveyor.com/api/projects/status/tusiutft7a0ei109/branch/master?svg=true)](https://ci.appveyor.com/project/3Fs/hmsbuild/branch/master) [![release-src](https://img.shields.io/github/release/3F/hMSBuild.svg)](https://github.com/3F/hMSBuild/releases/latest) [![License](https://img.shields.io/badge/License-MIT-74A5C2.svg)](https://github.com/3F/hMSBuild/blob/master/License.txt)
[![GetNuTool core](https://img.shields.io/badge/GetNuTool-v1.7-93C10B.svg)](https://github.com/3F/GetNuTool)

**Download:** Latest stable batch-script [ [hMSBuild](https://3F.github.io/hMSBuild/releases/latest/) ]
* [/releases](https://github.com/3F/hMSBuild/releases) [ [latest](https://github.com/3F/hMSBuild/releases/latest) ]
* [nightly builds](https://ci.appveyor.com/project/3Fs/hmsbuild/history) (`/artifacts` page)
But remember: It can be unstable or not work at all. Use this for tests of latest changes.
  * Artifacts [older than 6 months](https://www.appveyor.com/docs/packaging-artifacts/#artifacts-retention-policy) you can also find as `Pre-release` with mark `🎲 Nightly build` on [GitHub Releases](https://github.com/3F/hMSBuild/releases) page.


## Why hMSBuild ?

*because you need simple access to msbuild tools and more...* 

Based on **GetNuTool core** https://github.com/3F/GetNuTool

* Initially, it was part of this tool like a small msbuild-helper. Then, it has been extracted into the new project after major changes from MS for their products. Now we have more support of all this.

Today's [hMSBuild](https://github.com/3F/hMSBuild) provides flexible way to access to msbuild tools for any type of your projects. Just specify what you need in different environments. Look at *#Algorithm of searching* below.

[![{Screencast - hMSBuild in action. Demo via RunIlAsm error}](https://raw.githubusercontent.com/3F/hMSBuild/master/resources/screencast_hMSBuild_in_action.jpg)](https://www.youtube.com/watch?v=zUejJ4vUPGw&t=10)

### Features

Just a **single batch file** and no more for your happy build. 

Combine this with your other available scripts or just type `hMSBuild {arguments to original msbuild}` and have fun.

Start with `hMSBuild -h`

### What supports ?

* Versions from VS2017+ 
    * Full support even if you still have no any [local `vswhere.exe`](https://github.com/Microsoft/vswhere/issues/41) [[?](https://github.com/Microsoft/vswhere/issues/41)]
    
* Versions from VS2015, VS2013
* Versions from .NET Framework, including for VS2010

### Algorithm of searching

**v2.0+**

* Versions: 
  * VS2017+ ➟ VS2015, VS2013, ... ➟ .netfx
* Architectures (configure via `-notamd64` key): 
  * x64 ➟ x32
* Priorities (configure via `-vsw-priority` and `-stable` keys). *Specific workload components in more priority than pre-release products. See [Issue #8](https://github.com/3F/hMSBuild/issues/8)*

  1. Stable releases with selected workload components (C++ etc) ➟ Same via beta releases if allowed.
  1. Stable releases with any available components ➟ Same via beta releases if allowed.

## Usage

Usage is same as it would be same for msbuild. But you also have an additional keys to configure hMSBuild and to access to GetNuTool.

```
hMSBuild - 2.0.0 
Copyright (c) 2017-2018  Denis Kuzmin [ entry.reg@gmail.com ] :: github.com/3F

Distributed under the MIT license
https://github.com/3F/hMSBuild


Usage: hMSBuild [args to hMSBuild] [args to msbuild.exe or GetNuTool core]
------

Arguments:
----------
 -no-vs        - Disable searching from Visual Studio.
 -no-netfx     - Disable searching from .NET Framework.
 -no-vswhere   - Do not search via vswhere.

 -vsw-priority {IDs} - Non-strict components preference: C++ etc.
                       Separated by space: https://aka.ms/vs/workloads

 -vsw-version {arg}  - Specific version of vswhere. Where {arg}:
     * 1.0.50 ...
     * Keywords:
       `latest` - To get latest remote version;
       `local`  - To use only local versions;
                  (.bat;.exe /or from +15.2.26418.1 VS-build)

 -no-cache         - Do not cache vswhere for this request.
 -reset-cache      - To reset all cached vswhere versions before processing.
 -notamd64         - To use 32bit version of found msbuild.exe if it's possible.
 -stable           - It will ignore possible beta releases in last attempts.
 -eng              - Try to use english language for all build messages.
 -GetNuTool {args} - Access to GetNuTool core. https://github.com/3F/GetNuTool
 -only-path        - Only display fullpath to found MSBuild.
 -force            - Aggressive behavior for -vsw-priority, -notamd64, etc.
 -debug            - To show additional information from hMSBuild.
 -version          - Display version of hMSBuild.
 -help             - Display this help. Aliases: -help -h


------
Flags:
------
 __p_call - Tries to eliminate the difference for the call-type invoking hMSBuild.bat

--------
Samples:
--------
hMSBuild -notamd64 -vsw-version 1.0.50 "Conari.sln" /t:Rebuild
hMSBuild -vsw-version latest "Conari.sln"

hMSBuild -no-vswhere -no-vs -notamd64 "Conari.sln"
hMSBuild -no-vs "DllExport.sln"
hMSBuild vsSolutionBuildEvent.sln

hMSBuild -GetNuTool -unpack
hMSBuild -GetNuTool /p:ngpackages="Conari;regXwild"

hMSBuild -no-vs "DllExport.sln" || goto bx
```

## License

The [MIT License (MIT)](https://github.com/3F/hMSBuild/blob/master/License.txt)

```
Copyright (c) 2017-2018  Denis Kuzmin <entry.reg@gmail.com> :: github.com/3F
```

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif) ☕](https://3F.github.io/Donation/) 
