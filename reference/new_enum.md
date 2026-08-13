# Create a new enum class

Create a new enum class

## Usage

``` r
new_enum(name, variants, package = topenv_package_name(parent.frame()))
```

## Arguments

- name:

  String. Name of the new class.

- variants:

  Character vector. Allowed values.

- package:

  String or NULL. Package to attribute the class to. Defaults to the
  caller's package, if any.

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
```
