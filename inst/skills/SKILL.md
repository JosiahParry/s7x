---
name: s7x
description: Write S7 classes in R using the s7x package's property helpers — scalar-constrained properties, range-bound numeric properties, enums with a fixed set of variants, and OR/AND combinators for properties. Use this whenever a user is defining an S7 class (new_class()) and wants a property restricted to a scalar, a numeric range, a fixed set of string variants, or a combination of constraints, or asks how to use the s7x package specifically.
---

# s7x

`s7x` extends [S7](https://rconsortium.github.io/S7/) with ready-made property
constraints so you don't hand-write validators for common cases. Reach for it
any time an S7 property needs to be more specific than "any instance of this
class" — a single number, a bounded range, one of a fixed set of strings, or
several constraints at once.

All of the functions below return an `S7_property` (or, for `Enum`, an S7
class), so they drop directly into a `new_class()`'s `properties` list. Write
class definitions in the `Foo := new_class(...)` style, matching S7's own
style guide. One exception: roxygen2 does not recognise `:=`, so a class a
package documents and exports needs `Foo <- new_class("Foo", ...)` to get a
`\usage` section.

## Scalar properties

`property_scalar(class, default = NULL)` requires the value to be a length-1
atomic of `class`. Presets exist for the common base types:
`class_string`, `class_int`, `class_float`, `class_boolean`. Each preset
defaults to a typed `NA` (`NA_character_`, `NA_integer_`, `NA_real_`, `NA`),
so a bare preset property can be omitted from a constructor call.

```r
library(S7)
library(s7x)

Point := new_class(
  properties = list(
    x = class_float,
    y = class_float,
    label = class_string
  )
)
Point(1.5, 2.5, "origin")
```

Use `property_scalar()` directly when you need a scalar of some other S7
class (not just the presets):

```r
Wrapper := new_class(properties = list(id = property_scalar(S7::class_integer)))
```

## Range properties

`property_range(min, max, allow_na = TRUE)` is a scalar double bound to
`[min, max]`. `property_range_discrete(min, max, allow_na = TRUE)` is the
integer equivalent. Both are inclusive.

```r
HeadingLevel <- property_range_discrete(1L, 6L)
Heading := new_class(properties = list(level = HeadingLevel))
Heading(1L)
Heading(7L) # errors: must be between 1 and 6
```

## Enums

`new_enum(name, variants, package = NULL, allow_na = TRUE, default = NULL)`
creates a new S7 class (inheriting from the abstract `Enum` class) whose
instances hold a single string drawn from `variants`. The generator takes
the value directly — no property list.

```r
GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
GridShape("Square")
GridShape("Triangle") # errors: @value must be one of "Square" and "Hexagon"
```

By default `NA_character_` is also a valid value (representing "no value",
e.g. for JSON `null`), and it doubles as the generator's default, so
`GridShape()` and a bare `GridShape` property omitted from a host class's
constructor call both give `NA`. Set `allow_na = FALSE` to require one of
`variants`:

```r
GridShape(NA_character_) # ok
Strict <- new_enum("Strict", c("A", "B"), allow_na = FALSE)
Strict(NA_character_) # errors: @value must not be NA
Strict() # errors: argument "value" is missing, with no default
```

Pass `default` to pin a specific variant as the generator's default instead
of `NA`:

```r
GridShape2 <- new_enum("GridShape2", c("Square", "Hexagon"), default = "Square")
GridShape2()@value # "Square"
```

When a package exports enums, enable `s7x::enum_roclet()` in its `DESCRIPTION`:

```
Roxygen: list(markdown = TRUE, roclets = c("collate", "namespace", "s7x::enum_roclet"))
```

Every enum then documents itself from the class, needing no tags beyond
`@export`. The title, description, `@param value`, and the `variants` and
`allow_na` properties are all generated:

```r
#' @export
GridShape <- s7x::new_enum("GridShape", c("Square", "Hexagon"))
```

Anything written by hand wins, so a block with its own title keeps it and only
the missing pieces are filled in:

```r
#' Grid shapes
#' @export
GridShape <- s7x::new_enum("GridShape", c("Square", "Hexagon"))
```

Note that roxygen2 does not recognise S7's `:=` operator, so a class defined
with `Foo := new_class(...)` gets no `\usage` section. Use `<-` with an
explicit name for classes a package exports.

Enum instances convert to and from plain strings via `S7::convert()`,
`as.character()`, and `as_vector()`:

```r
convert(GridShape("Square"), class_character)
as.character(GridShape("Square"))
as_vector(GridShape("Square"))
convert("Hexagon", GridShape)
```

Use `property_enum(...)` to type a property as one of several enum classes
(it errors if any argument wasn't created by `new_enum()`):

```r
Direction <- new_enum("Direction", c("North", "South"))
Board := new_class(
  properties = list(orientation = property_enum(GridShape, Direction))
)
Board(GridShape("Square"))
Board(Direction("North"))
```

## Combining properties: union (OR) and intersection (AND)

`property_union(..., default = NULL)` accepts a value that satisfies **any**
member of `...` (classes or properties). It has an infix form,
`` `|.S7_property` ``, when at least one operand is already an `S7_property`:

```r
Piece := new_class(
  properties = list(id = class_string | property_range_discrete(1L, 6L))
)
Piece(3L)
Piece("a")
```

When `default` is omitted, it's derived from the first member that's an
`S7_property` with its own usable default (a scalar preset like
`class_string`, for instance), so a bare union property can be left off a
constructor call:

```r
Board := new_class(properties = list(id = property_union(class_string, class_float)))
Board()@id # NA_character_
```

Pass `default = NULL` explicitly to pin the default to `NULL` and opt out of
derivation, e.g. for an optional nested object. `NULL` can be listed in any
position among `...`:

```r
Point := new_class(properties = list(x = class_float, y = class_float))
Board2 := new_class(
  properties = list(origin = property_union(Point, NULL, default = NULL))
)
is.null(Board2()@origin) # TRUE
```

`property_intersection(..., default = NULL)` requires a value to satisfy
**every** member of `...`, combined with the infix `` `&.S7_property` ``.
Every member must share the same underlying base class — a single value
can't be an instance of two different classes at once — so this is for
layering multiple validators onto one type, not for combining unrelated
classes.

```r
PieceColor <- property_scalar(class_character) & new_property(
  class_character,
  validator = function(value) {
    if (!(value %in% c("White", "Black"))) "must be White or Black"
  }
)
Piece := new_class(properties = list(color = PieceColor))
Piece("White")
```

This is in fact how `Enum` itself is conceptually structured: a scalar
constraint AND a fixed-variant constraint, both on `character`. Reach for
`property_intersection()` directly whenever a fixed-variant style constraint
needs additional per-value logic that `new_enum()` doesn't expose.

## Coercing to a plain vector

`as_vector(x, ...)` is an S7 generic that strips any object down to a plain R
vector (something `is.vector()` is `TRUE` for): an atomic vector for
scalar-backed classes like `Enum`, or a named list of (recursively coerced)
properties for compound classes. A default method handles any `S7_object`,
so it works out of the box for classes you define with `new_class()`:

```r
Point := new_class(properties = list(x = class_float, y = class_float))
as_vector(Point(1, 2)) # list(x = 1, y = 2)
as_vector(GridShape("Square")) # "Square"
```

A bare list is coerced elementwise, so a structure mixing S7 objects with
plain values converts in a single call, and anything else is returned as-is:

```r
as_vector(list(name = "a", at = Point(1, 2)))
# list(name = "a", at = list(x = 1, y = 2))
```

Recursion stops at anything that is not a bare list, so a `data.frame` nested
in a structure keeps its class instead of being flipped columnar.

## Serializing to JSON

`to_json(x, ..., pretty = FALSE)` serializes any S7 object to a JSON string,
by running it through `as_vector()` first and passing the result to
`yyjsonr::write_json_str()`. `...` is forwarded to `write_json_str()`, so any
`yyjsonr::opts_write_json()` option can be overridden:

```r
to_json(Point(1, 2)) # {"x":1.0,"y":2.0}
to_json(Point(1, 2), pretty = TRUE)
```

## Picking the right helper

- One atomic value, any type → `property_scalar()` (or a `class_*` preset).
- One number, bounded → `property_range()` / `property_range_discrete()`.
- One string from a fixed, closed set → `new_enum()` / `property_enum()`.
- "Satisfies at least one of these" → `property_union()` / `|`.
- "Satisfies all of these at once" → `property_intersection()` / `&`.
- Coerce an S7 object down to a plain vector/list → `as_vector()`.
