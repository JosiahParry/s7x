# s7x (development version)

* Added a Claude Code skill (`inst/skills/SKILL.md`) documenting how to use s7x's property helpers when writing S7 classes.
* `new_enum()` gains an `allow_na` argument (default `TRUE`) so enum values can be `NA_character_`.
* Added `class_boolean`, a scalar logical property preset alongside `class_string`, `class_integer`, and `class_double`.
