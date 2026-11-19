# Create a property from an intersection of properties

A value must satisfy every single property in the intersection.

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
    id = property_scalar(S7::class_character) &
      S7::new_property(S7::class_character)
  )
)
Piece("a")
#> <Piece>
#>  @ id: chr "a"
```
