# Build an S7 object from a vector

The inverse of
[`as_vector()`](https://s7x.josiah.rs/reference/as_vector.md). Builds an
instance of `class` from a named list of its properties, recursing into
properties that are S7 classes.

## Usage

``` r
from_vector(x, class, ...)
```

## Arguments

- x:

  Any. Vector to build from.

- class:

  S7 class spec. Class to build.

- ...:

  Additional arguments passed to methods.

## Value

An instance of `class`, or `x` unchanged.

## Details

`from_vector()` builds `class` from the properties in `x`. It returns
atomic vectors unchanged and unclasses data frames first.

## Examples

``` r
library(S7)
Point <- new_class(
  "Point",
  properties = list(x = class_float, y = class_float)
)
from_vector(list(x = 1, y = 2), Point)
#> <Point>
#>  @ x: num 1
#>  @ y: num 2
```
