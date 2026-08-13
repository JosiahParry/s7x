# s7x - S7 extensions

[s7x](https://s7x.josiah.rs/) provides utility extensions to the
[`{S7}`](https://rconsortium.github.io/S7/) type system.

It fills the void of features I’ve long wanted in S7 (and R) to help
make R packages more type safe(ish) with less boilerplate.

Notably s7x provides:

- an extensible `Enum` class for speficying enumerations
- scalar properties
- range propeties (discrete and continuous)
- property unions and intersections

See [Enums in R: towards type safe
R](https://josiah.rs/posts/enums-in-r/) for the motivation behind this
package.

## Installation

You can install the development version of s7x like so:

``` r

pak::pak("josiahparry/s7x")
```

> \[!NOTE\]
>
> `s7x` is built on the development version of `S7`. Install it with
> `pak::pak("RConsortium/S7")`.

## Enum(eration)s

In R, we use enumerations all the time, though in formally. For example,
[`stats::cor()`](https://rdrr.io/r/stats/cor.html)’s argument
`method = c("pearson", "kendall", "spearman")` is an enumeration in that
`method` can be only one of three possible values. In R, enums are
typically strings and validated via `arg.match()` or the equivalent
[`rlang::arg_match()`](https://rlang.r-lib.org/reference/arg_match.html).

In [s7x](https://s7x.josiah.rs/), enums are formalized through the
[`s7x::Enum`](https://s7x.josiah.rs/reference/Enum.md) class.

``` r

library(s7x)

# create a new enum
CorMethod <- new_enum("CorMethod", c("pearson", "kendall", "spearman"))

# instantiate the enum
x <- CorMethod("pearson")
x
#> <CorMethod>
#>  @ value   : chr "pearson"
#>  @ variants: chr [1:3] "pearson" "kendall" "spearman"
```

Note that all [`s7x::Enum`](https://s7x.josiah.rs/reference/Enum.md)s
can be cast as character vectors.

``` r

as.character(x)
#> [1] "pearson"
```

Thus, we can use the `Enum` to enforce variants, but when we need the
underlying value we can
[`as.character()`](https://rdrr.io/r/base/character.html) or extract
it’s value via `x@value`.

## Scalar properties

A longtime [wish list
item](https://github.com/RConsortium/S7/issues/554) of mine is
**scalar** properties. A scalar in R is a **length one** vector. These
are useful for arguments such as `n_components = 5`—where it wouldn’t
make sense for the value to be `c(5, 1)`, for example.

S7 has built-in classes for the vector types in R (double, integer,
character, list) but not for their scalar variants.

`s7x` introduces the
[`property_scalar()`](https://s7x.josiah.rs/reference/property_scalar.md)
function which lets you create **scalar** variants.

For example:

``` r

library(S7)
NComponents := new_class(properties = list(n = property_scalar(class_integer)))

n_comps <- NComponents(5L)
n_comps
#> <NComponents>
#>  @ n: int 5
```

Providing a non-length 1 value creates an error:

``` r

NComponents(c(5L, 1L))
#> Error in `NComponents()`:
#> ! <NComponents> object properties are invalid:
#> - @n must be a scalar atomic
```
