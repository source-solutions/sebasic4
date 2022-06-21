### VAL
***
<code><var>value</var> <b>= VAL(</b><var>string</var><b>)</b></code>

Returns the numeric value of the string expression <code><var>string</var></code>. See the section on [numeric literals](#Numeric-literals) for the recognised number formats.

#### Notes
* Spaces before a number are ignored: `VAL(" 10")` returns `10`. But unlike 
  Microsoft BASIC, spaces inside a number are not ignored.
* Unlike Microsoft BASIC, expressions inside the string expression are also 
  evaluated. For example, `VAL "5+5"` returns `10` and `VAL "foo"` returns the value 
  of variable `foo`.
* Expressions between curly braces `{` and `}` are not evaluated, but their syntax 
  is checked upon entering. They are interpreted as strings that can be passed 
  to VAL for actual evaluation.

#### Errors
<code><var>string</var></code> has a number value: <samp>Type mismatch</samp>.
