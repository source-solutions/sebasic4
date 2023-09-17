# Developer's guide
***
Applications are stored as a collection of files and folders within a folder in a top-level folder called `PROGRAMS`. Application names can be any length and
contain any valid FAT-32 filename character (including space). In SE BASIC,
applications are launched with `!MY APP NAME` or `RUN "MY APP NAME"`.
The application name is truncated to derive the folder and binary filenames and spaces are converted to underscores.
```
PROGRAMS
|----------- MY_APP_N.AME
             |----------- PRG
                          |----------- MY_APP_N.PRG
                          RSC
                          |----------- RESOURCE.BIN
```
The `RUN` command sets the stack pointer to `$6000`, loads the binary (`PRG` file) at `$6000`, changes the path to the resource (`RSC`) folder and sets the program
counter to `$6000`.



If the binary fails to load it restores the stack and falls back to BASIC. This means the binary can be up to 40K in length. The binary is then responsible for loading its own resources. The method for passing parameters to the app is
to define a variable in BASIC.

This approach has a number of advantages over the single executable file method.
For example, with multi-lingual software, only the selected language resources
need to be loaded. It is also easy to customize the app without the need to
recompile it.

Apps can use [`SEOS`](SEOS) system calls to perform common tasks that would ordinarily
require boiler-plate code.

Apps can also make use of the internal software floating point unit using the
[`X80`](X80) instruciton set.








