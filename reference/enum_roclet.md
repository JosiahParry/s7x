# Document enums and S7 classes

Use `enum_roclet()` to generate the docs of exported
[`new_enum()`](https://s7x.josiah.rs/reference/new_enum.md) and S7
classes from their definitions.

## Usage

``` r
enum_roclet()
```

## Value

A roxygen2 roclet.

## Details

Enable it in your package's `DESCRIPTION`:

    Roxygen: list(markdown = TRUE, roclets = c("collate", "namespace", "s7x::enum_roclet"))

You get each of these that you don't write yourself:

- An enum on its own page: the title, description, `value` param,
  `variants` and `allow_na` properties, returns and an example.

- Enums that share a page through `@rdname`: the `value` param and a
  Variants section that lists each enum's values.

- An S7 class on its own page: a `@param` with the type of each
  property.

## Examples

``` r
enum_roclet()
#> list()
#> attr(,"class")
#> [1] "roclet_enum" "roclet_rd"   "roclet"     
```
