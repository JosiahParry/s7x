# Define a range-bound scalar property

A scalar property constrained to `[min, max]` inclusive.
`property_range()` is for doubles, `property_range_discrete()` for
integers.

## Usage

``` r
property_range(min, max, allow_na = TRUE)

property_range_discrete(min, max, allow_na = TRUE)
```

## Arguments

- min:

  Number. Inclusive lower bound.

- max:

  Number. Inclusive upper bound.

- allow_na:

  Bool. Whether `NA` is a valid value.

## Value

An S7 property whose value must be a scalar within `[min, max]`.

## Examples

``` r
library(S7)
HeadingLevel <- property_range_discrete(1L, 6L)
Heading := new_class(properties = list(level = HeadingLevel))
Heading(1L)
#> <Heading>
#>  @ level: int 1
```
