# Convert S7 objects to and from JSON

`to_json()` serializes `x` with
[`as_vector()`](https://s7x.josiah.rs/reference/as_vector.md).
`from_json()` parses `json` and builds `class` with
[`from_vector()`](https://s7x.josiah.rs/reference/as_vector.md).

## Usage

``` r
to_json(x, ...)

from_json(json, class, ...)
```

## Arguments

- x:

  Any. Object to serialize.

- ...:

  Additional arguments passed to methods.

- json:

  String. JSON to parse.

- class:

  S7 class spec. Class to build.

## Value

`to_json()` returns a string of JSON. `from_json()` returns an instance
of `class`, or a list of them for a JSON array.

## Details

Set `pretty = TRUE` to pretty-print the JSON.

## Examples

``` r
library(S7)
Point <- new_class(
  "Point",
  properties = list(x = class_float, y = class_float)
)
json <- to_json(Point(1, 2))
json
#> [1] "{\"x\":1.0,\"y\":2.0}"
from_json(json, Point)
#> <Point>
#>  @ x: num 1
#>  @ y: num 2
```
