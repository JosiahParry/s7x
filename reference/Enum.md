# Abstract base class for enumerations

A scalar character value drawn from a fixed set of variants. Use
[`new_enum()`](https://s7x.josiah.rs/reference/new_enum.md) to create
concrete subclasses.

## Usage

``` r
Enum(value = character(0), variants = character(0), allow_na = logical(0))
```

## Arguments

- value:

  String. The enum's current value.

- variants:

  Character vector. Allowed values.

- allow_na:

  Bool. Whether `NA_character_` is a valid value.

## Examples

``` r
GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
S7::S7_inherits(GridShape("Square"), Enum)
#> [1] TRUE
```
