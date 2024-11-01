# [hMSBuild](https://github.com/3F/hMSBuild)

*.bat* scripts with full [Package Manager](https://github.com/3F/GetNuTool) inside for searching and wrapping MSBuild tools. All *Visual Studio* and *.NET Framework* versions.

You do NOT need *powershell* or *dotnet-cli* or local [*vswhere.exe* [?]](https://github.com/Microsoft/vswhere/issues/41)

```r
Copyright (c) 2017-2024  Denis Kuzmin <x-3F@outlook.com> github/3F
```

[ 「 ❤ 」 ](https://3F.github.io/fund) [![License](https://img.shields.io/badge/License-MIT-74A5C2.svg)](https://github.com/3F/hMSBuild/blob/master/License.txt)
[![Build status](https://ci.appveyor.com/api/projects/status/8ac1021k385eyubm/branch/master?svg=true)](https://ci.appveyor.com/project/3Fs/hmsbuild-github/branch/master)
[![release](https://img.shields.io/github/release/3F/hMSBuild.svg)](https://github.com/3F/hMSBuild/releases/latest)
[![GetNuTool](https://img.shields.io/badge/GetNuTool-v1.9-93C10B.svg)](https://github.com/3F/GetNuTool)


```bat
hMSBuild -only-path -no-vs -notamd64 -no-less-4
hMSBuild -debug ~x ~c Release
hMSBuild -GetNuTool "Conari;regXwild;Fnv1a128"
hMSBuild -GetNuTool vsSolutionBuildEvent/1.16.1:../SDK & SDK\GUI
hMSBuild -cs -no-less-15 /t:Rebuild
```

**[Download](https://github.com/3F/hMSBuild/releases)** all editions: *Full, Minified, ...*

Official Direct Links:

* (Windows) Latest stable compiled batch-script [ [hMSBuild.bat](https://3F.github.io/hMSBuild/releases/latest/) ] `https://3F.github.io/hMSBuild/releases/latest/`


## Why hMSBuild

*because you need easy access to msbuild tools and more...* 

Based on [GetNuTool](https://github.com/3F/GetNuTool) and back in those days it was part of it like a small msbuild-helper inside.
  But finally it was extracted into a new independent project after major changes from MS ecosystem with their products.

Today's [hMSBuild](https://github.com/3F/hMSBuild) provides the most flexible way to access and preparing msbuild tools in different environments. You just specify what you need ... and hMSBuild prepares it for you.

[![{Screencast - hMSBuild in action. Demo via RunIlAsm error}](https://raw.githubusercontent.com/3F/hMSBuild/master/resources/screencast_hMSBuild_in_action.jpg)](https://www.youtube.com/watch?v=zUejJ4vUPGw&t=10)


### Key Features

* Single *.bat file, no less, no more.
* Manage all versions, including before install-API/2017+
* *Visual Studio* versions support: VS2022+, VS2019, VS2017, VS2015, VS2013, VS2012, VS2010
* *.NET Framework* versions support: 4.0 (2010), 3.5, 2.0
* Lightweight and text-based, about ~8 KB + ~11 KB
* Does not require *powershell* or *dotnet-cli* or even local [*vswhere.exe* [?]](https://github.com/Microsoft/vswhere/issues/41)
* Support hot updating / custom vswhere at any request for the most modern environments.
* Provides some useful aliases.
* Full [package manager](https://github.com/3F/GetNuTool) inside .bat to Create or Distribute using basic shell scripts;
* Request to the server only if the package is not installed.
* Support *packages.config* (+extra: output, sha1 if used unsecured channels ~windows xp).
* Easy integration into any scripts such as pure batch-script [netfx4sdk](https://github.com/3F/netfx4sdk), [DllExport](https://github.com/3F/DllExport/wiki/DllExport-Manager)


### hMSBuild's algorithm

The basic process is to provide the most suitable instance by explicitly eliminating unnecessary ones.

**2.0+**

* Versions: 
  * VS2022, ..., VS2017 ➟ VS2015, VS2013, ... ➟ .netfx
* Instance Architecture (configure via `-notamd64` key): 
  * x64 ➟ x32

* Extra restrictions via `-no-less-4` (Windows XP+), `-no-less-15` (install-API/2017+)
* Priorities (configure via `-priority`, `-vc`, `cs`, `-stable`, ... keys). *Specific workload components in more priority than pre-release products. See [Issue #8](https://github.com/3F/hMSBuild/issues/8)*

  1. Stable releases with selected workload components (C++ etc) ➟ Same via beta releases if allowed.
  1. Stable releases with any available components ➟ Same via beta releases if allowed.

## Syntax

Keys to *hMSBuild* are optional. You can still command like it is official *msbuild.exe* *(MSBuild Tools)*.

> hMSBuild [keys to hMSBuild] [keys to msbuild.exe]

For example, 

* The *Clean* target in current directory: `hmsbuild /t:Clean`
* Set property *Configuration* and *minimal* verbosity: `hmsbuild /p:Configuration=Debug /v:m`
  * via hMSBuild it can also be like: `hmsbuild ~x ~c Debug`

In order to use [package manager](https://github.com/3F/GetNuTool),

> hMSBuild **-GetNuTool** keys to it ...

* Get latest packages: `hmsbuild -GetNuTool "Conari;regXwild;Fnv1a128"`
* Activate GUI script editor: `hMSBuild -GetNuTool vsSolutionBuildEvent/1.16.0:../SDK & SDK\GUI`
* Create new package: `hmsbuild -GetNuTool /t:pack /p:ngin=packages/Fnv1a128`

### -... or /...

MSBuild Tools supports both key format */...* and *-...*; hMSBuild, in turn, can override some of *-...*; in this case you need to use */...* for example,

* */version* will be addressed to found MSBuild;
* *-version* will be addressed to hMSBuild;

### "..."

Any value for specific key must be protected inside `"..."` if contains either whitespaces or delimiters like `;` For example:

```bat
hmsbuild ~p "Any CPU"
```

### -help

For the most up-to-date information, use `hMSBuild -h`

```
hMSBuild 2.4.0
Copyright (c) 2017-2024  Denis Kuzmin <x-3F@outlook.com> github/3F
Copyright (c) hMSBuild contributors https://github.com/3F/hMSBuild

Under the MIT License https://github.com/3F/hMSBuild

Syntax: hMSBuild [keys to hMSBuild] [keys to MSBuild.exe or GetNuTool]

Keys
~~~~
 -no-vs        - Disable searching from Visual Studio.
 -no-netfx     - Disable searching from .NET Framework.
 -no-vswhere   - Do not search via vswhere.
 -no-less-15   - Do not include versions less than 15.0 (install-API/2017+)
 -no-less-4    - Do not include versions less than 4.0 (Windows XP+)

 -priority {IDs} - 15+ Non-strict components preference: C++ etc.
                   Separated by space "a b c" https://aka.ms/vs/workloads

 -vswhere {v}
  * 2.6.7 ...
  * latest - To get latest remote vswhere.exe
  * local  - To use only local
            (.bat;.exe /or from +15.2.26418.1 VS-build)

 -no-cache         - Do not cache vswhere for this request.
 -reset-cache      - To reset all cached vswhere versions before processing.
 -cs               - Adds to -priority C# / VB Roslyn compilers.
 -vc               - Adds to -priority VC++ toolset.
 ~c {name}         - Alias to p:Configuration={name}
 ~p {name}         - Alias to p:Platform={name}
 ~x                - Alias to m:NUMBER_OF_PROCESSORS-1 v:m
 -notamd64         - To use 32bit version of found msbuild.exe if it's possible.
 -stable           - It will ignore possible beta releases in last attempts.
 -eng              - Try to use english language for all build messages.
 -GetNuTool {args} - Access to GetNuTool core. https://github.com/3F/GetNuTool
 -only-path        - Only display fullpath to found MSBuild.
 -force            - Aggressive behavior for -priority, -notamd64, etc.
 -vsw-as "args..." - Reassign default commands to vswhere if used.
 -debug            - To show additional information from hMSBuild
 -version          - Display version of hMSBuild.
 -help             - Display this help. Aliases: -? -h
```

## Integration with scripts

### batch (.bat, .cmd)

hMSBuild is a pure batch script. Therefore, you can easily combine this even inside other batch scripts. Or invoke this externally, there's nothing special:

```bat
set msbuild=hMSBuild -notamd64 ~c Release
...
%msbuild% Conari.sln /t:Rebuild
```

```bat
for /F "tokens=*" %%i in ('hMSBuild -only-path -notamd64') do set msbuild="%%i"
...
%msbuild% /version
```

```bat
hmsbuild -cs -no-less-15 ~c Debug ~x || goto fallback
```

More actual examples can be found in [tests/](tests/) folder.

Note: for some cases, if you know what you're doing, you can also configure *__p_call* flag to eliminate the difference for the call-type invoking *hMSBuild.bat*

```bat
set __p_call=1
```


## Build & Tests

build and tests was based on batch and [vssbe](https://github.com/3F/vsSolutionBuildEvent) scripts. You don't need to do anything else, just build and test it

```bat
build & tests
```

### Build and Use from source

```bat
git clone https://github.com/3F/hMSBuild.git src
cd src & build & bin\Release\hMSBuild -help
```

### .sha1 official distribution

*hMSBuild* releases are now accompanied by a *.sha1* file in the official distribution; At the same time, commits from which releases are published are signed with the committer's verified signature (GPG).

Make sure you are using official, unmodified, safe versions.

Note: *.sha1* file is a text list of published files with checksums in the format: 

`40-hexadecimal-digits` `<space>` `file`

```
eead8f5c1fdff2abd4da7d799fbbe694d392c792 path\file
...
```

## Contributing

[*hMSBuild*](https://github.com/3F/hMSBuild) is waiting for your awesome contributions!