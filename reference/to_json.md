# Coerce an S7 object to a JSON string

Serializes `x` to JSON by coercing it with
[`as_vector()`](https://s7x.josiah.rs/reference/as_vector.md) first.

## Usage

``` r
to_json(x, ...)
```

## Arguments

- x:

  Any. Object to serialize.

- ...:

  Additional arguments passed to
  [`yyjsonr::write_json_str()`](https://coolbutuseless.github.io/package/yyjsonr/reference/write_json_str.html).

- pretty:

  Bool. Whether to pretty-print the JSON output.

## Value

A string containing JSON.

## Examples

``` r
library(S7)
Point <- new_class(
  "Point",
  properties = list(x = class_float, y = class_float)
)
to_json(Point(1, 2))
#> [1] "{\"x\":1.0,\"y\":2.0}"
```
