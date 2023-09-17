### The working environment
***
The first thing you'll see when starting SE Basic IV is the working environment.
Like Microsoft BASIC, but unlike practically all modern compilers and
interpreters, SE Basic IV's working environment serves both as a development
environment and as a canvas on which to execute BASIC commands directly. With a
few exceptions, practically all commands that can be run in the working
environment can be used in a program, and vice versa.

The default SE Basic IV screen has 24 rows and 80 columns. In some video modes, there are only 40 or fewer columns. Editing takes place on the lowest row.

Logical lines exceed the width of the physical row: if you keep typing beyond
the screen width, the text will wrap to the next line but SE Basic IV will still
consider it part of the same line. A logical line can be as long as you want
providing the memory required to store it is available.

If you press Return, SE Basic IV will attempt to execute the logical line on
which the cursor is placed as a command. When the command is executed correctly,
SE Basic IV will display the prompt `Ok`. If there is an error, it will display an
error message. If the line starts with a number, it will be stored as a program
line. No prompt is displayed.