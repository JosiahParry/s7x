Our goal is to create utility functions to work with the package S7 and create helpers for our use case.

S7 doesn't support a scalar class to be used in properties of an object

The movitivation here is that we want to have a union type with scalar and atomics.

We want to be able to have a type that can be used to define Enumerations for example: 

```r
library(S7)

# create a new Enum abstract class
Enum <- new_class(
  "Enum",
  properties = list(
    Value = class_character,
    Variants = class_character
  ),
  validator = function(self) { 
    if (length(self@Value) != 1L) {
      "enum value's are length 1"
    } else if (!(self@Value %in% self@Variants)) {
      "enum value must be one of possible variants"
    }
  }, 
  abstract = TRUE
)

# create a new enum constructor 
new_enum_class <- function(enum_class, variants) {
  new_class(
    enum_class,
    parent = Enum,
    properties = list(
      Value = class_character,
      Variants = new_property(class_character, default = variants)
    ),
    constructor = function(Value) {
      new_object(S7_object(), Value = Value, Variants = variants)
    }
  )
}


GridShape <- new_enum_class(
  "GridShape",
  c("Square", "Hexagon")
)

GridShape
```
```
<GridShape> class
@ parent     : <Enum>
@ constructor: function(Value) {...}
@ validator  : <NULL>
@ properties :
 $ Value   : <character>
 $ Variants: <character>
 ```

We want to be able to use vctrs to cast to and from a scalar string to the enum S7 class 
and then S7 -> base R character vector for automatic handling.

We want a similar behavior for a Range, too. THis will let use define a range type that ensures a scalar value must fall within that range. It can be continuous or discrete depending on if it is a union of integer or double
