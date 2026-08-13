# Define a scalar property

Ready-to-use `property_scalar()` variants for the common atomic base
types.

## Usage

``` r
property_scalar(class, default = NULL)

class_string

class_integer

class_double
```

## Arguments

- class:

  S7 class spec. Base type the value must be an instance of.

- default:

  Any. Passed to
  [`S7::new_property()`](https://rconsortium.github.io/S7/reference/new_property.html).

## Value

An S7 property whose value must be a scalar atomic.

## Examples

``` r
library(S7)
Point := new_class(properties = list(x = property_scalar(S7::class_double)))
Point(1.5)
#> <Point>
#>  @ x: num 1.5
library(S7)
Board := new_class(
  properties = list(
    label = class_string,
    rank = class_integer,
    score = class_double
  )
)
Board("check", 1L, 0.5)
#> <Board>
#>  @ label: chr "check"
#>  @ rank : int 1
#>  @ score: num 0.5
```
