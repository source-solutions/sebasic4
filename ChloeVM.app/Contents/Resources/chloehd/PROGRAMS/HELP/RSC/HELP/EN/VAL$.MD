### VAL$
***
<code><var>repr</var> <b>= VAL$(</b><var>string</var><b>)</b></code>

Evaluates a <code><var>string</var></code> as a string expression. For example

```
10 INPUT a$, x$
20 PRINT VAL$ a$
```

The string value assigned to `a$` should be an expression using `x$`. For example, `"x$+x$"`. A string value is then assigned to `x$`, for example `"yo"`. `VAL$` strips the quotes of the value of `a$` to get `x$+x$` and evaluates it using the value assigned to `x$` displaying the result `yoyo`.

#### Notes
* This function is not present in Microsoft BASIC. It is very useful for creating recursive functions, if used together with `AND` applied to string arguments, allowing for selective evaluation.
* Expressions between curly braces `{` and `}` are not evaluated, but their syntax is checked upon entering. They are interpreted as strings that can be passed to VAL$ for actual evaluation.
