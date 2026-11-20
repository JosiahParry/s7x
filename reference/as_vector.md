# Convert S7 objects to and from vectors

Takes an S7 object and coerces it to the appropriate vector container
type. `from_vector()` builds an instance of `class` from a vector. Both
are S7 generics which can be implemented for any custom types.

## Usage

``` r
as_vector(x, ...)

from_vector(x, class, ...)
```

## Arguments

- x:

  Any. Object to convert.

- ...:

  Additional arguments passed to methods.

- class:

  S7 class spec. Class to build.

## Value

`as_vector()` returns an atomic vector or a named list. `from_vector()`
returns an instance of `class`, or `x` unchanged.

## Details

`as_vector()` returns:

- `S7_object`: a named list of its coerced properties.

- `Enum`: its value as a string.

- `list`: a list with each S7 object or bare list element coerced. It
  leaves other elements, such as data frames, unchanged.

- Falls back to use [`as.list()`](https://rdrr.io/r/base/list.html).

`from_vector()` builds `class` from the properties in `x`. It returns
atomic vectors unchanged and unclasses data frames first.

## Examples

``` r
library(S7)
Point <- new_class(
  "Point",
  properties = list(x = class_float, y = class_float)
)
v <- as_vector(Point(1, 2))
v
#> $x
#> [1] 1
#> 
#> $y
#> [1] 2
#> 
from_vector(v, Point)
#> <Point>
#>  @ x: num 1
#>  @ y: num 2
```
