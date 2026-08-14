# Create Property from a Union of Properties

An analogue to
[`S7::new_union()`](https://rconsortium.github.io/S7/reference/new_union.html).
Defines a new property from multiple

## Usage

``` r
property_union(..., default = NULL)

# S3 method for class 'S7_property'
e1 | e2
```

## Arguments

- ...:

  S7 classes or properties to union.

- default:

  Any. Passed to
  [`S7::new_property()`](https://rconsortium.github.io/S7/reference/new_property.html).
  If left unsupplied, falls back to the first member's own default (only
  members that are an `S7_property`, e.g. a
  [`property_scalar()`](https://s7x.josiah.rs/reference/property_scalar.md)
  preset, carry one) that satisfies the union's combined validator. Pass
  `default = NULL` explicitly to pin the default to `NULL` and opt out
  of this fallback; this resolves to an actual `NULL` regardless of
  where a literal `NULL` member sits among `...`.

- e1, e2:

  S7 classes or properties to union.

## Value

An S7 property typed as the union of `...`.

## Examples

``` r
library(S7)
Piece := new_class(
  properties = list(id = property_union(S7::class_character, S7::class_integer))
)
Piece("a")
#> <Piece>
#>  @ id: chr "a"
Piece(1L)
#> <Piece>
#>  @ id: int 1
library(S7)
Piece := new_class(
  properties = list(id = class_string | property_range_discrete(1L, 6L))
)
Piece(3L)
#> <Piece>
#>  @ id: int 3
```
