# Create a new enum class

Create a new enum class

## Usage

``` r
new_enum(
  name,
  variants,
  package = topenv_package_name(parent.frame()),
  allow_na = TRUE,
  default = NULL
)
```

## Arguments

- name:

  String. Name of the new class.

- variants:

  Character vector. Allowed values.

- package:

  String or NULL. Package to attribute the class to. Defaults to the
  caller's package, if any.

- allow_na:

  Bool. Whether `NA_character_` is a valid value.

- default:

  String or NULL. Default value used when the property is omitted. Must
  be one of `variants`, or `NA` if `allow_na = TRUE`. If `NULL` (the
  default), falls back to `NA_character_` when `allow_na = TRUE`,
  otherwise the value stays required with no default.

## Value

An S7 class generator that inherits from
[Enum](https://s7x.josiah.rs/reference/Enum.md).

## Examples

``` r
GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
#> Overwriting method convert(<character>, <GridShape>)
GridShape("Square")
#> <GridShape>
#>  @ value   : chr "Square"
#>  @ variants: chr [1:2] "Square" "Hexagon"
#>  @ allow_na: logi TRUE
GridShape(NA_character_)
#> <GridShape>
#>  @ value   : chr NA
#>  @ variants: chr [1:2] "Square" "Hexagon"
#>  @ allow_na: logi TRUE
```
