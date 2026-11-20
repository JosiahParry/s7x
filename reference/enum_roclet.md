# roxygen2 integration

Use the `@enum` roclet to automatically generate s7x documentation.

## Usage

``` r
enum_roclet()

use_roxygen(path = ".")
```

## Arguments

- path:

  a scalar character. Path to the package.

## Value

`enum_roclet()` returns a roxygen2 roclet. `use_roxygen()` returns
`path`, invisibly.

## Details

Run `use_roxygen()` to add `s7x::enum_roclet` to the roclets in your
`DESCRIPTION`.

The roclet generates:

- Enums: the title, description, `value` param, `variants` and
  `allow_na` properties, returns and an example.

- Enums sharing an `@rdname`: the `value` param and a Variants section.

- S7 classes: a `@param` for each property.

## Examples

``` r
enum_roclet()
#> list()
#> attr(,"class")
#> [1] "roclet_enum" "roclet_rd"   "roclet"     

path <- tempfile()
dir.create(path)
writeLines("Package: example", file.path(path, "DESCRIPTION"))
use_roxygen(path)
#> ✔ Added "s7x::enum_roclet" to Roxygen.
```
