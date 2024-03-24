### Errors
***
 1. `NEXT without FOR`  
    A `NEXT` statement was encountered for which no matching `FOR` could be found.

 2. `Syntax error`  
    The BASIC syntax is incorrect. A statement or expression was mistyped or
    called in one of many incorrect ways. This error is also raised on a `DATA`
    line if a `READ` statement encounters a data entry of an incorrect format.

 3. `RETURN without GOSUB`  
    A `RETURN` statement was encountered for which no `GOSUB` call was made.

 4. `Out of DATA`  
    A `READ` statement is attempting to read more data entries than can be found
    from the current `DATA` location onward.

 5. `Illegal function call`  
    A statement, function or operator was called with parameters outside the
    accepted range. This error is also raised for a large variety of other
    conditions - check the reference for the statement or function called.

 6. `Overflow`  
    A numeric expression result or intermediate value is too large for the
    required number format.

 7. `Out of memory`  
    There is not enough free BASIC memory to complete the operation. Too much
    memory is consumed by the program; variables, arrays and strings, or
    execution stacks for loops, subroutines or user-defined functions.

 8. `Undefined line number`  
    A reference is made to a line number that does not exist in the program.

 9. `Subscript out of range`  
    An array index (subscript) is used that is outside the range reserved for
    that array by the `DIM` statement.

10. `Undefined variable`  
    A simple variable was used without assigning it a value, or a control
    variable was used with `NEXT`  first setting it up in a `FOR` statement, or a
    subscripted value was used before dimensioning the array with `DIM`.



11. `Address out of range`  
    The value specified in a `CLEAR` statement is either too big or too small.

12. `Statement missing`  
    A jump was attempted to a statement that no longer exists.

13. `Type mismatch`  
    The expression used is of a type that cannot be converted to the required
    type for the function or statement. Most commonly, this is raised if a
    string argument is supplied to a statement or function that expects a
    number, or the opposite.

14. `Out of screen`  
    `CIRCLE`, `DRAW` or `PLOT` were used with parameters beyond the screen size. Or
    `INPUT` has generated more than 23 lines in the lower part of the screen.

15. `Bad I/O device`  
    File handling report.

16. `Undefined stream`  
    Attempted to read or write from a stream that has not been defined with an
    `OPEN` statement.

17. `Undefined channel`  
    Attempted to open a stream to an unrecognized channel.

18. `Undefined user function`  
    The `FN` function is called with a function name for which no definition was
    made by a `DEF FN` statement.

19. `Line buffer overflow`  
    There is not enough memory space left to enter the new program line.

20. `FOR without NEXT`  
    A `FOR` statement was encountered for which no matching `NEXT` statement can be
    found.

22. `WHILE without WEND`  
    A `WHILE` statement was encountered for which no matching `WEND` statement can
    be found.

22. `WEND without WHILE`  
    A `WEND` statement was encountered for which no matching `WHILE` statement can
    be found.


23. `File not found`  
    A named file on a disk device cannot be found.

24. `Input past end`  
    An attempt is made to retrieve input from a file that has passed its end of
    file.

25. `Path not found`  
    An `OPEN`, `MKDIR`, `RMDIR`, or `CHDIR` statement is executed referring to a
    (parent) path that does not exist on the disk device.













