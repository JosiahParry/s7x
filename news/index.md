# Changelog

## s7x (development version)

- `class_string`, `class_integer`, `class_double`, and `class_boolean`
  now default to a typed `NA` when omitted from a constructor call.
- [`new_enum()`](https://s7x.josiah.rs/reference/new_enum.md) gains a
  `default` argument to pin a specific variant as the default, and
  `allow_na = TRUE` now gives omitted enum properties a default of `NA`.
- Added a Claude Code skill (`inst/skills/SKILL.md`) documenting how to
  use s7x’s property helpers when writing S7 classes.
- [`new_enum()`](https://s7x.josiah.rs/reference/new_enum.md) gains an
  `allow_na` argument (default `TRUE`) so enum values can be
  `NA_character_`.
- Added `class_boolean`, a scalar logical property preset alongside
  `class_string`, `class_integer`, and `class_double`.
- Added [`as_vector()`](https://s7x.josiah.rs/reference/as_vector.md), a
  generic that coerces an S7 object to a plain R vector: an atomic
  vector for scalar-backed classes like `Enum`, or a named list of
  (recursively coerced) properties for compound classes.
