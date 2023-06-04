[![build](https://github.com/source-solutions/sebasic4/actions/workflows/main.yml/badge.svg)](https://github.com/source-solutions/sebasic4/actions/workflows/main.yml)
[![API docs](https://github.com/source-solutions/sebasic4/actions/workflows/api.yml/badge.svg)](https://github.com/source-solutions/sebasic4/actions/workflows/api.yml)
<a href="https://hosted.weblate.org/engage/sebasic4/">
<img src="https://hosted.weblate.org/widgets/sebasic4/-/svg-badge.svg" alt="Translation status" />
</a>
![GitHub issues by-label](https://img.shields.io/github/issues/source-solutions/sebasic4/bug)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/source-solutions/sebasic4)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/source-solutions/sebasic4)

# SE Basic IV

[SE Basic IV](https://source-solutions.github.io/sebasic4/) is a free open-source BASIC interpreter for the Z80 architecture. Although it aims for a high degree of compatibility with Microsoft BASIC, there are some differences. SE Basic IV is designed to run on the [Chloe 280SE](https://www.patreon.com/chloe280se) but it is also compatible with Timex Sinclair models with 128K of RAM, esxDOS, Timex video modes and ULAplus. SE Basic IV runs plain text `.BAS` files. It implements floating-point arithmetic in the extended [Microsoft Binary Format](https://github.com/source-solutions/sebasic4/wiki/Technical-reference#microsoft-binary-format-extended) (MBF) and can therefore read and write binary data files created by 6502 versions of Microsoft BASIC.  

* [Quick start guide](https://github.com/source-solutions/sebasic4/wiki/Quick-start-guide), the essentials needed to get started.
* [User's guide](https://github.com/source-solutions/sebasic4/wiki/User's-guide), in-depth guide to using BASIC.
* [Configuration guide](https://github.com/source-solutions/sebasic4/wiki/Configuration-guide), settings and options.
* [Language guide](https://github.com/source-solutions/sebasic4/wiki/Language-guide), overview of the BASIC language by topic.
* [Language reference](https://github.com/source-solutions/sebasic4/wiki/Language-reference), comprehensive reference to BASIC.
* [Technical reference](https://github.com/source-solutions/sebasic4/wiki/Technical-reference), file formats and internals.
* [Developer's guide](https://github.com/source-solutions/sebasic4/wiki/Developer-guide), building SE basic IV from source.
* [Acknowledgments](https://github.com/source-solutions/sebasic4/wiki/Acknowledgments)
* [License](https://github.com/source-solutions/sebasic4/wiki/License)

![SE Basic 4.2.0](https://github.com/source-solutions/sebasic4/raw/gh-pages/images/sebasic4-2.png)

# SE Basic IV 4.2 Cordelia
A classic BASIC interpreter for the Z80 architecture

Copyright © 1999-2023 Source Solutions, Inc.

## Build tools
Building this software locally requires:
* [Java](https://www.java.com)
* [JQ](https://stedolan.github.io/jq/)
* [Perl](https://www.perl.org/)
* [RASM](https://github.com/EdouardBERGE/rasm)

## Emulator
On macOS and Windows, the preferred emulator for development is [ZEsarUX](https://github.com/chernandezba/zesarux). On Linux it is [Fuse](https://fuse-emulator.sourceforge.net/).

For Fuse builds, uncomment out the `slam` directives in `basic.asm` and `boot.asm`.

## IDE
This repository includes scripts for [Visual Studio Code](https://code.visualstudio.com/ "Visual Studio Code").
