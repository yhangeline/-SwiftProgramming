/*:
## `inout` Parameters and Mutating Methods

The "`&`" that we use at the front of an `inout` argument in Swift might give
you the impression — especially if you have a C or C++ background — that `inout`
parameters are essentially pass-by-reference. But they aren't. `inout` is
pass-by-value-and-copy-back, *not* pass-by-reference. To quote the official
Swift Programming Language book:

> An `inout` parameter has a value that is passed in to the function, is
> modified by the function, and is passed back out of the function to replace
> the original value.

In the chapter on structs and classes, we wrote about `inout` parameters, and we
looked at the similarities between `mutating` methods and methods that take an
`inout` parameter.

In order to understand what kind of expressions can be passed as an `inout`
parameter, we need to make the distinction between lvalues and rvalues. An
*lvalue* describes a memory location. An *rvalue* describes a value. For
example, `array[0]` is an lvalue, as it describes the memory location of the
first element in the array. `2 + 2` is an rvalue, as it describes the value `4`.

For `inout` parameters, you can only pass lvalues, because it doesn't make sense
to mutate an rvalue. When you're working with `inout` parameters in regular
functions and methods, you need to be explicit about passing them in: every
lvalue needs to be prefixed with an `&`. For example, when we call the
`increment` function (which takes an `inout Int`), we can pass in a variable by
prefixing it with an ampersand:

*/

//#-editable-code
func increment(value: inout Int) {
    value += 1
}

var i = 0
increment(value: &i)
//#-end-editable-code

/*:
If we define a variable using `let`, we can't use it as an lvalue. This makes
sense, because we're not allowed to mutate `let` variables; we can only use
"mutable" lvalues:

``` swift-example
let y: Int = 0
increment(value: &y) // Error
```

We can pass in many more things in addition to variables. For example, we can
also pass in an array subscript if the array is defined using `var`:

*/

//#-editable-code
var array = [0, 1, 2]
increment(value: &array[0])
array
//#-end-editable-code

/*:
In fact, this works with every `subscript` (including your own custom
subscripts), as long as they both have a `get` and a `set` defined. Likewise, we
can use properties as lvalues, but again, only if they have both `get` and `set`
defined:

*/

//#-editable-code
struct Point {
    var x: Int
    var y: Int
}
var point = Point(x: 0, y: 0)
increment(value: &point.x)
point
//#-end-editable-code

/*:
If a property is read-only (that is, only `get` is available), we can't use it
as an `inout` parameter:

``` swift-example
extension Point {
    var squaredDistance: Int {
        return x*x + y*y
    }
}
increment(value: &point.squaredDistance) // Error
```

Operators can also take an `inout` value, but for the sake of simplicity, they
don't require the ampersand when called; we just specify the lvalue. For
example, let's add back the postfix increment operator, which was removed in
[SE-0004](https://github.com/apple/swift-evolution/blob/master/proposals/0004-remove-pre-post-inc-decrement.md):

*/

//#-editable-code
postfix func ++(x: inout Int) {
    x += 1
}
point.x++
//#-end-editable-code

/*:
A mutating operator can even be combined with optional chaining. This works with
regular optionals, like below, but also with dictionary subscripts:

*/

//#-editable-code
var dictionary = ["one": 1]
dictionary["one"]?++
//#-end-editable-code

/*:
Note that, in case the key lookup returns `nil`, the `++` operator won't get
executed.

The compiler may optimize an `inout` variable to pass-by-reference, rather than
copying in and out. However, it's explicitly stated in the documentation that we
shouldn't rely on this behavior.

*/
