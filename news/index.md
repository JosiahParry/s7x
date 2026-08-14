# Changelog

## s7x (development version)

- Added [`to_json()`](https://s7x.josiah.rs/reference/to_json.md), a
  generic that serializes an S7 object to a JSON string via
  [`as_vector()`](https://s7x.josiah.rs/reference/as_vector.md) and
  [`yyjsonr::write_json_str()`](https://coolbutuseless.github.io/package/yyjsonr/reference/write_json_str.html).
- [`as_vector()`](https://s7x.josiah.rs/reference/as_vector.md) now
  recurses into S7 objects nested inside list properties
  (e.g. `list(SomeS7Object, ...)`), not just properties that are
  directly an S7 object.
- [`property_range()`](https://s7x.josiah.rs/reference/property_range.md)
  and
  [`property_range_discrete()`](https://s7x.josiah.rs/reference/property_range.md)
  now default to a typed `NA` when `allow_na = TRUE` (the default) and
  the property is omitted from a constructor call.
- `property_union(..., default = NULL)` now resolves to an actual `NULL`
  default regardless of where a literal `NULL` member sits among `...`,
  instead of only when `NULL` is listed first.
- [`property_union()`](https://s7x.josiah.rs/reference/property_union.md)
  now distinguishes an omitted `default` from an explicit
  `default = NULL`: omitting `default` still derives one from a member’s
  own default, while `default = NULL` pins the default to `NULL` and
  opts out of derivation.
- [`property_union()`](https://s7x.josiah.rs/reference/property_union.md)
  now derives its default from the first member’s own default (when a
  member is an `S7_property` and that default satisfies the union),
  instead of always defaulting to `NULL`.
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
