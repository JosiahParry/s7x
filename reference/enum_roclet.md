# Roclet that documents enum and S7 classes

Documents exported
[`new_enum()`](https://s7x.josiah.rs/reference/new_enum.md) classes and
S7 class properties.

## Usage

``` r
enum_roclet()
```

## Value

A roxygen2 roclet.

## Details

Enable it in the `DESCRIPTION` of the package being documented:

    Roxygen: list(markdown = TRUE, roclets = c("collate", "namespace", "s7x::enum_roclet"))

`enum_roclet()` generates an enum's documentation from its variants.

## Examples

``` r
enum_roclet()
#> list()
#> attr(,"class")
#> [1] "roclet_enum" "roclet_rd"   "roclet"     
```
