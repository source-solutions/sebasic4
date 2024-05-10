[API docs](https://source-solutions.github.io/sebasic4/api/) | [User guide](https://github.com/source-solutions/sebasic4/wiki) | [Patreon](https://www.patreon.com/chloe280se) | [Telegram](https://t.me/chloe280seug) | [Vimeo](https://vimeo.com/chloecorp) | [Try it out](https://source-solutions.github.io/sebasic4/emu/chloe.html)

![SE Basic 4.2.0](/images/sebasic4-2.png)

[SE BASIC](https://source-solutions.github.io/sebasic4/) is a free open-source BASIC interpreter for the Z80 architecture. Although it aims for a high degree of compatibility with Microsoft BASIC, there are some differences. It is developed as part of the firmware for the [Chloe 280SE](https://www.patreon.com/chloe280se), an open source hardware/software project as defined by the [Open Source Hardware Association](https://www.oshwa.org/) and the [Open Source Initiative](https://opensource.org/). Localization is carried out in partnership with [Translation Commons](https://translationcommons.org/) and [Weblate](https://hosted.weblate.org/engage/sebasic4/). SE BASIC runs plain text `.BAS` files. It implements floating-point arithmetic in the extended [Microsoft Binary Format](https://github.com/source-solutions/sebasic4/wiki/Technical-reference#microsoft-binary-format-extended) (MBF) and can therefore read and write binary data files created by 6502 versions of Microsoft BASIC.  

<img src="images/oshw-logo-800-px.png" style="width:112px"/>&nbsp;&nbsp;<img src="images/osi_standard_logo_0.png" style="width:100px"/>&nbsp;&nbsp;<img src="images/TC-logo.png" style="width:200px"/>&nbsp;&nbsp;<img src="images/weblate_logo.png" style="height:100px"/> 

Features include:

* 40 column (16 color) and 80 column (2 color) paletted video modes.
* Always-on expression evaluation (use variables as filenames).
* Application package format with support for turning BASIC programs into apps.
* Automatic typing of integer and floating point numbers.
* BIOS with DOS and high level OS (API) integration.
* Bitwise logic (`AND`, `NOT`, `OR`, `XOR`).
* Built-in help system.
* Choice of Microsoft (`LEFT$`, `MID$` and `RIGHT$`) or Sinclair (`TO`) string slicing.
* Composable characters (supports Vietnamese).
* Disk-based file system.
* Double-byte memory manipulation (`DEEK`, `DOKE`).
* Error handling (`ON ERROR`…, `TRACE`).
* Flow control (`IF`…`THEN`…`ELSE`, `WHILE`…`WEND`).
* Full random file access from BASIC (`OPEN`, `CLOSE`, `SEEK`).
* Full-size keyboard support (`DEL`, `HOME`, `END` and so on).
* Graphics commands in 40 column mode (`CIRCLE`, `DRAW`, `PLOT`).
* Localization of character sets, error messages, and keyboard layouts.
* Long variable names.
* Motorola style number entry (`%`; binary, `@`; octal, `$`; hexadecimal).
* Super BREAK (non-maskable interrupt).
* On-entry syntax checking.
* `PLAY` command with 6-channel PSG and MIDI support.
* Recursive user-defined functions.
* Token abbreviation and shortcuts (`&`; `AND`, `~`; `NOT`; `|`; `OR`, `?`; `PRINT`, `'`; `REM`').
* Undo `NEW` (`OLD`).
* User-defined hardware channels.
* User-defined character sets (256 characters).
* User-defined macros.
* User-defined screen modes.

<img src="images/ssi.png"/>

Copyright © 1981-2024 Source Solutions, Inc.

<a rel="me" href="https://hachyderm.io/@aowendev"></a>
