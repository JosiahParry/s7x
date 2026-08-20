# Coerce an S7 object to a vector

Returns a plain R vector representation of `x`, for which
[`is.vector()`](https://rdrr.io/r/base/vector.html) is `TRUE`: an atomic
vector for scalar-backed classes, or a named list of coerced properties
for compound classes. A list is coerced elementwise, so a mixed
structure of S7 objects and plain values converts in one call.

## Usage

``` r
as_vector(x, ...)
```

## Arguments

- x:

  Any. Object to coerce.

- ...:

  Additional arguments passed to methods.

## Value

An atomic vector or a named list.

## Examples

``` r
library(S7)
#> 
#> Attaching package: ‘S7’
#> The following objects are masked from ‘package:s7x’:
#> 
#>     class_double, class_integer
Point <- new_class(
  "Point",
  properties = list(x = class_double, y = class_double)
)
as_vector(Point(1, 2))
#> $x
#> [1] 1
#> 
#> $y
#> [1] 2
#> 
```
