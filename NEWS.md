# s7x (development version)

* Added a Claude Code skill (`inst/skills/SKILL.md`) documenting how to use s7x's property helpers when writing S7 classes.
* `new_enum()` gains an `allow_na` argument (default `TRUE`) so enum values can be `NA_character_`.
* Added `class_boolean`, a scalar logical property preset alongside `class_string`, `class_integer`, and `class_double`.
* Added `as_vector()`, a generic that coerces an S7 object to a plain R vector: an atomic vector for scalar-backed classes like `Enum`, or a named list of (recursively coerced) properties for compound classes.
