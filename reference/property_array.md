# Array property

An array is a list of values that all share one class.

## Usage

``` r
property_array(class, default = rlang::expr(list()))
```

## Arguments

- class:

  S7 class spec. Class of every element.

- default:

  Any. Passed to
  [`S7::new_property()`](https://rconsortium.github.io/S7/reference/new_property.html).

## Value

An S7 property whose value must be a list of `class`.

## Examples

``` r
library(S7)
Point <- new_class("Point", properties = list(x = class_float))
Path <- new_class("Path", properties = list(points = property_array(Point)))
Path(list(Point(1), Point(2)))
#> <Path>
#>  @ points: List of 2
#>  .. $ : <Point>
#>  ..  ..@ x: num 1
#>  .. $ : <Point>
#>  ..  ..@ x: num 2
```
