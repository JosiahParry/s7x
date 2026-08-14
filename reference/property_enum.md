# Define a property backed by one or more enum classes

Define a property backed by one or more enum classes

## Usage

``` r
property_enum(..., default = NULL)
```

## Arguments

- ...:

  Enum classes. One or more classes from
  [`new_enum()`](https://s7x.josiah.rs/reference/new_enum.md).

- default:

  Any. Passed to
  [`S7::new_property()`](https://rconsortium.github.io/S7/reference/new_property.html).

## Value

An S7 property typed as the union of `...`.

## Examples

``` r
library(S7)
#> 
#> Attaching package: ‘S7’
#> The following objects are masked from ‘package:s7x’:
#> 
#>     class_double, class_integer
GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
#> Overwriting method convert(<character>, <GridShape>)
Direction <- new_enum("Direction", c("North", "South"))
Board := new_class(
  properties = list(orientation = property_enum(GridShape, Direction))
)
Board(GridShape("Square"))
#> <Board>
#>  @ orientation: <GridShape>
#>  .. @ value   : chr "Square"
#>  .. @ variants: chr [1:2] "Square" "Hexagon"
#>  .. @ allow_na: logi TRUE
```
