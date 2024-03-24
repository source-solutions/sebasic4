### String operators
***
Code     | Operation     | Result
-------- | ------------- | -----------------------------------------------------
`x$ + y$`  | concatenation | The contents of `x$` followed by the contents of `y$`
`x$ \* y`   | repetition    | The contents of `x$` is repeated `y` times.
`x$ AND y` | selection     | If `y` is `0`, result is an empty string, otherwise `x$`

#### Note
With repetition, If `y` is negative, the result is mirrored.
