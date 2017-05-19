# [hMSBuild](https://github.com/3F/hMSBuild)

A lightweight tool (compiled batch file ~20 Kb that can be embedded inside any scripts or other batch files) - an easy helper for searching of available MSBuild tools. Supports tools from VS2017+ (does not require additional vswhere.exe), VS2015 or less, other versions from .NET Framework.


[![Build status](https://ci.appveyor.com/api/projects/status/tusiutft7a0ei109/branch/master?svg=true)](https://ci.appveyor.com/project/3Fs/hmsbuild/branch/master) [![release-src](https://img.shields.io/github/release/3F/hMSBuild.svg)](https://github.com/3F/hMSBuild/releases/latest) [![License](https://img.shields.io/badge/License-MIT-74A5C2.svg)](https://github.com/3F/hMSBuild/blob/master/License.txt)

**Download:** [/releases](https://github.com/3F/hMSBuild/releases) [ **[latest](https://github.com/3F/hMSBuild/releases/latest)** ]
* [nightly builds](https://ci.appveyor.com/project/3Fs/hmsbuild/history) (see `/artifacts` page) - *it can be unstable or not work at all. Use this for tests of latest changes.*


## Why hMSBuild ?

*because you need simple access to msbuild tools and more...* 

It based on **GetNuTool core** https://github.com/3F/GetNuTool, and initially it was a more simplified msbuild-helper as part of this tool. But with latest changes from MS we extracted this into new project for more support of all this.

### Features

**1 batch file and no anything else** for your happy build. 

Combine with your other available scripts or just type `hMSBuild <args to msbuild.exe>` and have fun. Start with `hMSBuild -?`

### What supports ?

* Versions from VS2017+ 
    * Full support even if you still have no any [local `vswhere.exe`](https://github.com/Microsoft/vswhere/issues/41) [[?](https://github.com/Microsoft/vswhere/issues/41)]
    
* Versions from VS2015, VS2013, .NET Framework
    
## Usage

Usage is same as it would be same for msbuild. But you also have additional keys to access to GetNuTool core and to settings of hMSBuild:

```
Usage: hMSBuild [args to hMSBuild] [args to msbuild.exe or GetNuTool core]
------

Arguments:
----------
 -novswhere             - Do not search via vswhere.
 -novs                  - Disable searching from Visual Studio.
 -nonet                 - Disable searching from .NET Framework.
 -vswhere-version {num} - Specific version of vswhere. Where {num}:
                          * Versions: 1.0.50 ...
                          * Keywords:
                            `latest` to get latest available version;
                            `local`  to use only local versions:
                                     (.bat;.exe /or from +15.2.26418.1 VS-build);

 -nocachevswhere        - Do not cache vswhere. Use this also for reset cache.
 -notamd64              - To use 32bit version of found msbuild.exe if it's possible.
 -eng                   - Try to use english language for all build messages.
 -GetNuTool {args}      - Access to GetNuTool core. https://github.com/3F/GetNuTool
 -only-path             - Only display fullpath to found MSBuild.
 -debug                 - To show additional information from hMSBuild.
 -version               - Display version of hMSBuild.
 -help                  - Display this help. Aliases: -help -h -?


--------
Samples:
--------
hMSBuild -vswhere-version 1.0.50 -notamd64 "Conari.sln" /t:Rebuild
hMSBuild -vswhere-version latest "Conari.sln"

hMSBuild -novswhere -novs -notamd64 "Conari.sln"
hMSBuild -novs "DllExport.sln"
hMSBuild vsSolutionBuildEvent.sln

hMSBuild -GetNuTool -unpack
hMSBuild -GetNuTool /p:ngpackages="Conari;regXwild"

"hMSBuild -novs "DllExport.sln" || goto err"

---------------------
Possible Error Codes: ERROR_FILE_NOT_FOUND (0x2), ERROR_PATH_NOT_FOUND (0x3), ERROR_SUCCESS (0x0)
---------------------
```

## License

The [MIT License (MIT)](https://github.com/3F/hMSBuild/blob/master/License.txt)

```
Copyright (c) 2017  Denis Kuzmin <entry.reg@gmail.com> :: github.com/3F
```

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=entry%2ereg%40gmail%2ecom&lc=US&item_name=3F%2dOpenSource%20%5b%20github%2ecom%2f3F&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted)