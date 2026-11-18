# Define a homogeneous list property

The plural counterpart to
[`property_scalar()`](https://s7x.josiah.rs/reference/property_scalar.md),
for a list whose every element is an instance of `class`. A spec type
written `Stop[]` is `property_list_of(Stop)`, where a plain
[S7::class_list](https://rconsortium.github.io/S7/reference/base_classes.html)
would validate nothing about what the list holds.

## Usage

``` r
property_list_of(
  class,
  default = quote(list()),
  min_length = 0,
  max_length = Inf
)
```

## Arguments

- class:

  S7 class spec. Base type every element must be an instance of.

- default:

  Any. Passed to
  [`S7::new_property()`](https://rconsortium.github.io/S7/reference/new_property.html).
  Defaults to an empty list, so the property is always safe to iterate.

- min_length, max_length:

  Number. Inclusive bounds on `length(value)`. `max_length` may be `Inf`
  for an unbounded list.

## Value

An S7 property whose value must be a list of `class`.

## Details

Atomic vectors need no helper here -
[`S7::class_double`](https://rconsortium.github.io/S7/reference/base_classes.html)
and
[`S7::class_character`](https://rconsortium.github.io/S7/reference/base_classes.html)
already accept a vector of any length, and the scalar presets
([class_string](https://s7x.josiah.rs/reference/property_scalar.md),
[class_float](https://s7x.josiah.rs/reference/property_scalar.md)) are
what restrict one to length 1.

`min_length` and `max_length` express a fixed-arity spec type: a tuple
of one to three axes is
`property_list_of(Axis, min_length = 1, max_length = 3)`.

## Examples

``` r
library(S7)
Stop := new_class(properties = list(at = class_float))
Ramp := new_class(properties = list(stops = property_list_of(Stop)))
Ramp(list(Stop(0), Stop(1)))
#> <Ramp>
#>  @ stops: List of 2
#>  .. $ : <Stop>
#>  ..  ..@ at: num 0
#>  .. $ : <Stop>
#>  ..  ..@ at: num 1
```
