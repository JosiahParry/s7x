# Coerce an S7 object to a vector

Takes an S7 object and coerces it to the appropriate vector container
type. This is an S7 generic which can be implemented for any custom
types.

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

## Details

`as_vector()` returns:

- `S7_object`: a named list of its coerced properties.

- `Enum`: its value as a string.

- `list`: a list with each S7 object or bare list element coerced. It
  leaves other elements, such as data frames, unchanged.

- Falls back to use [`as.list()`](https://rdrr.io/r/base/list.html).

## Examples

``` r
library(S7)
Point <- new_class(
  "Point",
  properties = list(x = class_float, y = class_float)
)
as_vector(Point(1, 2))
#> $x
#> [1] 1
#> 
#> $y
#> [1] 2
#> 
```
