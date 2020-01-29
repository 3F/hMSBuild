# [hMSBuild](https://github.com/3F/hMSBuild)

Compiled text-based embeddable pure batch-scripts (no powershell, no dotnet-cli) for searching of available MSBuild tools. VS2019+, VS2017 (it does not require local vswhere.exe [[?](https://github.com/Microsoft/vswhere/issues/41)]), VS2015, VS2013, VS2012, VS2010, other versions from .NET Framework. Contains [gnt.core](https://github.com/3F/GetNuTool) for work with NuGet packages and more...


[![Build status](https://ci.appveyor.com/api/projects/status/tusiutft7a0ei109/branch/master?svg=true)](https://ci.appveyor.com/project/3Fs/hmsbuild/branch/master) [![release-src](https://img.shields.io/github/release/3F/hMSBuild.svg)](https://github.com/3F/hMSBuild/releases/latest) [![License](https://img.shields.io/badge/License-MIT-74A5C2.svg)](https://github.com/3F/hMSBuild/blob/master/License.txt)
[![GetNuTool core](https://img.shields.io/badge/GetNuTool-v1.7-93C10B.svg)](https://github.com/3F/GetNuTool)

[![Build history](https://buildstats.info/appveyor/chart/3Fs/hmsbuild?buildCount=15&includeBuildsFromPullRequest=true&showStats=true)](https://ci.appveyor.com/project/3Fs/hmsbuild/history)

**Download:** Latest stable batch-script [ [hMSBuild](https://3F.github.io/hMSBuild/releases/latest/) ]
* Stable: [/releases](https://github.com/3F/hMSBuild/releases) [ [latest](https://github.com/3F/hMSBuild/releases/latest) ]
* CI builds: [`/artifacts` page](https://ci.appveyor.com/project/3Fs/hmsbuild/history) or find as `Pre-release` with mark `🎲 Nightly build` on [GitHub Releases](https://github.com/3F/hMSBuild/releases) page.


## Why hMSBuild ?

*because you need simple access to msbuild tools and more...* 

Based on **GetNuTool core** https://github.com/3F/GetNuTool

* Initially, it was part of this tool like a small msbuild-helper. Then, it has been extracted into the new project after major changes from MS for their products. Now we have more support of all this.

Today's [hMSBuild](https://github.com/3F/hMSBuild) provides flexible way to access to msbuild tools for any type of your projects. Just specify what you need in different environments. Look at *#Algorithm of searching* below.

[![{Screencast - hMSBuild in action. Demo via RunIlAsm error}](https://raw.githubusercontent.com/3F/hMSBuild/master/resources/screencast_hMSBuild_in_action.jpg)](https://www.youtube.com/watch?v=zUejJ4vUPGw&t=10)

## License

Licensed under the [MIT License (MIT)](https://github.com/3F/hMSBuild/blob/master/License.txt)

```
Copyright (c) 2017-2020  Denis Kuzmin < x-3F@outlook.com > GitHub/3F
```
hMSBuild contributors: https://github.com/3F/hMSBuild/graphs/contributors

[ [ ☕ Donate ](https://3F.github.com/Donation/) ]


### Features

Just a **single batch file** and no more for your happy build. 

Combine this with your other available scripts or just type `hMSBuild {arguments to original msbuild}` and have fun.

Start with `hMSBuild -h`

### What supports ?

* Versions from VS2019+, VS2017 
    * Full support even if you still have no any [local `vswhere.exe`](https://github.com/Microsoft/vswhere/issues/41) [[?](https://github.com/Microsoft/vswhere/issues/41)]
    
* Versions from VS2015, VS2013, VS2012
* Versions from .NET Framework, including for VS2010

### Algorithm of searching

**v2.0+**

* Versions: 
  * VS2019+, VS2017 ➟ VS2015, VS2013, ... ➟ .netfx
* Architectures (configure via `-notamd64` key): 
  * x64 ➟ x32
* Priorities (configure via `-vsw-priority` and `-stable` keys). *Specific workload components in more priority than pre-release products. See [Issue #8](https://github.com/3F/hMSBuild/issues/8)*

  1. Stable releases with selected workload components (C++ etc) ➟ Same via beta releases if allowed.
  1. Stable releases with any available components ➟ Same via beta releases if allowed.

## Usage

Usage is same as it would be same for msbuild. But you also have an additional keys to configure hMSBuild and to access to GetNuTool.

```
hMSBuild 2.3.0
Copyright (c) 2017-2020  Denis Kuzmin [ x-3F@outlook.com ] GitHub/3F
Copyright (c) hMSBuild contributors

Licensed under the MIT License
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
     * 2.6.7 ...
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
 -vsw-as "args..." - Reassign default commands to vswhere if used.
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
hMSBuild -notamd64 -vsw-version 2.6.7 "Conari.sln" /t:Rebuild
hMSBuild -vsw-version latest "Conari.sln"

hMSBuild -no-vswhere -no-vs -notamd64 "Conari.sln"
hMSBuild -no-vs "DllExport.sln"
hMSBuild vsSolutionBuildEvent.sln

hMSBuild -GetNuTool -unpack
hMSBuild -GetNuTool /p:ngpackages="Conari;regXwild"

hMSBuild -no-vs "DllExport.sln" || goto by
```

## Integration with other scripts

### batch

hMSBuild is a pure batch script. Therefore, you can combine this even inside your other batch scripts. Or simply invoke this externally as you need:

~

```bat
set msbuild=hMSBuild -notamd64
...
%msbuild% Conari.sln /m:4 /t:Rebuild
```

```bat
for /F "tokens=*" %%i in ('hMSBuild -only-path -notamd64') do set msbuild="%%i"
...
%msbuild% /version
```

...


## Build & Tests

Our build was based on [vssbe](https://github.com/3F/vsSolutionBuildEvent) scripts. 

You don't need to do anything else, just navigate to root directory of this project, and:

```bat
.\build
```

Available tests can be raised by command:

```bat
.\tests
```

We're waiting for your awesome contributions!