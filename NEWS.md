# s7x (development version)

* `property_union()` now derives its default from the first member's own default (when a member is an `S7_property` and that default satisfies the union), instead of always defaulting to `NULL`.
* `class_string`, `class_integer`, `class_double`, and `class_boolean` now default to a typed `NA` when omitted from a constructor call.
* `new_enum()` gains a `default` argument to pin a specific variant as the default, and `allow_na = TRUE` now gives omitted enum properties a default of `NA`.
* Added a Claude Code skill (`inst/skills/SKILL.md`) documenting how to use s7x's property helpers when writing S7 classes.
* `new_enum()` gains an `allow_na` argument (default `TRUE`) so enum values can be `NA_character_`.
* Added `class_boolean`, a scalar logical property preset alongside `class_string`, `class_integer`, and `class_double`.
* Added `as_vector()`, a generic that coerces an S7 object to a plain R vector: an atomic vector for scalar-backed classes like `Enum`, or a named list of (recursively coerced) properties for compound classes.
