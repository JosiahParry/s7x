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
style guide.

## Scalar properties

`property_scalar(class, default = NULL)` requires the value to be a length-1
atomic of `class`. Presets exist for the common base types:
`class_string`, `class_integer`, `class_double`.

```r
library(S7)
library(s7x)

Point := new_class(
  properties = list(
    x = class_double,
    y = class_double,
    label = class_string
  )
)
Point(1.5, 2.5, "origin")
```

Use `property_scalar()` directly when you need a scalar of some other S7
class (not just the three presets):

```r
Wrapper := new_class(properties = list(id = property_scalar(class_integer)))
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

`new_enum(name, variants, package = NULL)` creates a new S7 class (inheriting
from the abstract `Enum` class) whose instances hold a single string drawn
from `variants`. The generator takes the value directly — no property list.

```r
GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
GridShape("Square")
GridShape("Triangle") # errors: @value must be one of @variants
```

Enum instances convert to and from plain strings via `S7::convert()` and
`as.character()`:

```r
convert(GridShape("Square"), class_character)
as.character(GridShape("Square"))
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

## Picking the right helper

- One atomic value, any type → `property_scalar()` (or a `class_*` preset).
- One number, bounded → `property_range()` / `property_range_discrete()`.
- One string from a fixed, closed set → `new_enum()` / `property_enum()`.
- "Satisfies at least one of these" → `property_union()` / `|`.
- "Satisfies all of these at once" → `property_intersection()` / `&`.
