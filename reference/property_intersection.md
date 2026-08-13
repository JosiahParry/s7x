# Create a property from an intersection of properties

Requires a value to satisfy every member of `...`, unlike
[`property_union()`](https://josiahparry.github.io/s7x/reference/property_union.md)
which requires at least one. Every member must share the same underlying
class since a single value can't be an instance of two different classes
at once.

## Usage

``` r
property_intersection(..., default = NULL)

# S3 method for class 'S7_property'
e1 & e2
```

## Arguments

- ...:

  S7 classes or properties to intersect.

- default:

  Any. Passed to
  [`S7::new_property()`](https://rconsortium.github.io/S7/reference/new_property.html).

- e1, e2:

  S7 classes or properties to intersect.

## Value

An S7 property whose value must satisfy every member of `...`.

## Examples

``` r
library(S7)
PieceColor <- property_intersection(
  property_scalar(S7::class_character),
  S7::new_property(
    S7::class_character,
    validator = function(value) {
      if (!(value %in% c("White", "Black"))) "must be White or Black"
    }
  )
)
Piece := new_class(properties = list(color = PieceColor))
Piece("White")
#> <Piece>
#>  @ color: chr "White"
library(S7)
Piece := new_class(
  properties = list(
    id = property_scalar(S7::class_character) & S7::new_property(S7::class_character)
  )
)
Piece("a")
#> <Piece>
#>  @ id: chr "a"
```
