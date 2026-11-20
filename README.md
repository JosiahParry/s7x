

<!-- README.md is generated from README.qmd. Please edit that file -->

# s7x - S7 extensions <a href="https://s7x.josiah.rs/"><picture><source media="(prefers-color-scheme: dark)" srcset="man/figures/logo-dark.webp" /><img src="man/figures/logo.svg" align="right" height="139" alt="s7x website" /></picture></a>

`{s7x}` provides utility extensions to the
[`{S7}`](https://rconsortium.github.io/S7/) type system.

It fills the void of features I’ve long wanted in S7 (and R) to help
make R packages more type safe(ish) with less boilerplate.

<!-- badges: start -->

<!-- badges: end -->

Notably s7x provides:

- an extensible `Enum` class for speficying enumerations
- scalar properties
- arrays of S7 classes
- range propeties (discrete and continuous)
- property intersections

See [Enums in R: towards type safe
R](https://josiah.rs/posts/enums-in-r/) for the motivation behind this
package.

## Installation

You can install the development version of s7x like so:

``` r
pak::pak("josiahparry/s7x")
```

> [!NOTE]
>
> `s7x` is built on the development version of `S7`. Install it with
> `pak::pak("RConsortium/S7")`.

## Enum(eration)s

In R, we use enumerations all the time, though in formally. For example,
`stats::cor()`’s argument `method = c("pearson", "kendall", "spearman")`
is an enumeration in that `method` can be only one of three possible
values. In R, enums are typically strings and validated via
`arg.match()` or the equivalent `rlang::arg_match()`.

In `{s7x}`, enums are formalized through the `s7x::Enum` class.

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
#>  @ allow_na: logi TRUE
```

Note that all `s7x::Enum`s can be cast as character vectors.

``` r
as.character(x)
#> [1] "pearson"
```

Thus, we can use the `Enum` to enforce variants, but when we need the
underlying value we can `as.character()` or extract it’s value via
`x@value`.

## Scalar properties

A longtime [wish list
item](https://github.com/RConsortium/S7/issues/554) of mine is
**scalar** properties. A scalar in R is a **length one** vector. These
are useful for arguments such as `n_components = 5`—where it wouldn’t
make sense for the value to be `c(5, 1)`, for example.

S7 has built-in classes for the vector types in R (double, integer,
character, list) but not for their scalar variants.

`s7x` introduces the `property_scalar()` function which lets you create
**scalar** variants.

For example:

``` r
library(S7)
NComponents := new_class(
  properties = list(n = property_scalar(S7::class_integer))
)

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

## Ranges

For example, if you wanted to model a chess board:

``` r
Rank := new_class(
  properties = list(number = property_range_discrete(1, 8, allow_na = FALSE))
)

File := new_class(
  properties = list(number = property_range_discrete(1, 8, allow_na = FALSE))
)
```

We can combine this with an enum and a normal S7 object to define the
position of a chess piece.

``` r
Piece := new_enum(
  c("Pawn", "Bishop", "Knight", "Rook", "Queen", "King"),
  allow_na = FALSE,
  default = "Pawn"
)

Square := new_class(
  properties = list(
    piece = Piece,
    rank = Rank,
    file = File
  )
)

queen_start <- Square(
  Piece("Queen"),
  Rank(1L),
  File(4L)
)

queen_start
#> <Square>
#>  @ piece: <Piece>
#>  .. @ value   : chr "Queen"
#>  .. @ variants: chr [1:6] "Pawn" "Bishop" "Knight" "Rook" "Queen" "King"
#>  .. @ allow_na: logi FALSE
#>  @ rank : <Rank>
#>  .. @ number: int 1
#>  @ file : <File>
#>  .. @ number: int 4
```

## Arrays

Often, you may want to contain an array of S7 objects.

The `property_array()` gives us strongly typed arrays of S7 objects. If
we wanted to record the position of all of each player’s pieces at on
turn we could create a new type that contains an array of `Squares`.

``` r
PlayerPieces := new_class(
  properties = list(pieces = property_array(Square))
)

white <- PlayerPieces(
  list(
    queen_start,
    Square(
      Piece("King"),
      Rank(1L),
      File(5L)
    )
  )
)

white
#> <PlayerPieces>
#>  @ pieces: List of 2
#>  .. $ : <Square>
#>  ..  ..@ piece: <Piece>
#>  .. .. .. @ value   : chr "Queen"
#>  .. .. .. @ variants: chr [1:6] "Pawn" "Bishop" "Knight" "Rook" ...
#>  .. .. .. @ allow_na: logi FALSE
#>  ..  ..@ rank : <Rank>
#>  .. .. .. @ number: int 1
#>  ..  ..@ file : <File>
#>  .. .. .. @ number: int 4
#>  .. $ : <Square>
#>  ..  ..@ piece: <Piece>
#>  .. .. .. @ value   : chr "King"
#>  .. .. .. @ variants: chr [1:6] "Pawn" "Bishop" "Knight" "Rook" ...
#>  .. .. .. @ allow_na: logi FALSE
#>  ..  ..@ rank : <Rank>
#>  .. .. .. @ number: int 1
#>  ..  ..@ file : <File>
#>  .. .. .. @ number: int 5
```

## Conversion to vectors

The `s7x` package introduces the generics `as_vector()` and
`from_vector()` to provide conversion methods from base S3 vectors types
such as a list, or character vector, etc.

The defualt implementation does the following:

- `S7` objects: creates a named list of each property and value
- `Enum`s: converts to a character vector
- `Range`s: converts to a double or integer

You can create your own bespoke methods as well.

For example, we can use `as_vector()` to convert our `Square()` to a
list.

``` r
queen_list <- as_vector(queen_start)
queen_list
#> $piece
#> [1] "Queen"
#> 
#> $rank
#> $rank$number
#> [1] 1
#> 
#> 
#> $file
#> $file$number
#> [1] 4
```

Additionally, if your data comes in the format of a list or another
type, we can parse that into the correct `S7` type using
`from_vector(object, S7_class)`.

``` r
round_tripped <- from_vector(queen_list, Square)
round_tripped
#> <Square>
#>  @ piece: <Piece>
#>  .. @ value   : chr "Queen"
#>  .. @ variants: chr [1:6] "Pawn" "Bishop" "Knight" "Rook" "Queen" "King"
#>  .. @ allow_na: logi FALSE
#>  @ rank : <Rank>
#>  .. @ number: int 1
#>  @ file : <File>
#>  .. @ number: int 4

# verify no differences
waldo::compare(queen_start, round_tripped)
#> ✔ No differences
```

## Json conversion

Inspired by `serde` and `serde_json` in the rust ecosystem, `s7x`
provides generics `from_json()` and `to_json()`. These use `yyjsonr`
under the hood for fast performance.

``` r
to_json(white, pretty = TRUE) |>
  cat()
#> {
#>   "pieces": [
#>     {
#>       "piece": "Queen",
#>       "rank": {
#>         "number": 1
#>       },
#>       "file": {
#>         "number": 4
#>       }
#>     },
#>     {
#>       "piece": "King",
#>       "rank": {
#>         "number": 1
#>       },
#>       "file": {
#>         "number": 5
#>       }
#>     }
#>   ]
#> }
```

Now, we can call `from_json()` to parse this back into the correct type.
This is particularly useful when you have a `property_array()` that you
want to have as a list of your S7 class:

``` r
# round trip the json conversion
to_json(white) |>
  from_json(PlayerPieces)
#> <PlayerPieces>
#>  @ pieces: List of 2
#>  .. $ : <Square>
#>  ..  ..@ piece: <Piece>
#>  .. .. .. @ value   : chr "Queen"
#>  .. .. .. @ variants: chr [1:6] "Pawn" "Bishop" "Knight" "Rook" ...
#>  .. .. .. @ allow_na: logi FALSE
#>  ..  ..@ rank : <Rank>
#>  .. .. .. @ number: int 1
#>  ..  ..@ file : <File>
#>  .. .. .. @ number: int 4
#>  .. $ : <Square>
#>  ..  ..@ piece: <Piece>
#>  .. .. .. @ value   : chr "King"
#>  .. .. .. @ variants: chr [1:6] "Pawn" "Bishop" "Knight" "Rook" ...
#>  .. .. .. @ allow_na: logi FALSE
#>  ..  ..@ rank : <Rank>
#>  .. .. .. @ number: int 1
#>  ..  ..@ file : <File>
#>  .. .. .. @ number: int 5
```

## Package Development

If using an `Enum` from `s7x`, call `s7x::use_roxygen()` so that you can
use the `@enum` roclet to automatically generate variant level
documentation.

For example:

``` r
#' @enum
#' @export
GridShape := new_enum(c("Square", "Hexagon"))
```
