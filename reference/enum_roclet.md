# Roclet that documents enum classes

Fills in the title, description, `value` argument, and properties of
every exported
[`new_enum()`](https://s7x.josiah.rs/reference/new_enum.md) class from
the class itself. Extends roxygen2's `rd` roclet, so it replaces `"rd"`
rather than running alongside it.

## Usage

``` r
enum_roclet()
```

## Value

A roxygen2 roclet.

## Details

Enable it in the `DESCRIPTION` of the package being documented:

    Roxygen: list(markdown = TRUE, roclets = c("collate", "namespace", "s7x::enum_roclet"))

Any tag written by hand wins. A block with its own title keeps that
title, and only the missing pieces are generated.

## Examples

``` r
enum_roclet()
#> Error in loadNamespace(x): there is no package called ‘roxygen2’
```
