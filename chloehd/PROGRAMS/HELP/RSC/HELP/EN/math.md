### Mathematical operators
***
Mathematical operators operate on numeric expressions only. Note however that `+`
can take the role of the [string concatenation](#string-concatenation) operator if both operands are
strings.

Code|Operation|Result
------- | ------------------- | ------------------------------------------------
`x ^ y`   | Exponentiation      | `x` raised to the power of `y`
`x * y`   | Multiplication      | Product of `x` and `y`
`x / y`   | Division            | Quotient of `x` and `y`
`x \\ y`   | Truncated division  | Integer quotient of `x` and `y`
`x MOD y` | Modulo              | Integer remainder of `x` by `y` (with the sign of `x`)
`x + y`   | Addition            | Sum of `x` and `y`
`x - y`   | Subtraction         | Difference of `x` and `y`
`+ y`     | Unary Plus          | Value of `y`
`- y`     | Negation            | Negative value of `y`

#### Notes
The expression `0^0` will return `1` and not raise an error, even though,
mathematically, raising zero to the zeroeth power is undefined.

#### Errors
* If either operand is a string, an error will be raised. The exception is `+`
  which will only raise Type mismatch if either but not both operands are
  strings.
* If `y=0`, `x / y`, `x MOD y` and `x \ y` will raise an error.
* If `x=0` and `y<0`, `x^y` will raise an error.
* If the result of any operation is too large to fit in a floating-point data
  type, an error is raised.
* If operands or result of `\` or `MOD` are not in `[-32768 to 32767]`, an error is
  raised.