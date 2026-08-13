# Package index

## Enumerations

A scalar value drawn from a fixed set of variants.

- [`Enum()`](https://josiahparry.github.io/s7x/reference/Enum.md) :
  Abstract base class for enumerations
- [`new_enum()`](https://josiahparry.github.io/s7x/reference/new_enum.md)
  : Create a new enum class
- [`property_enum()`](https://josiahparry.github.io/s7x/reference/property_enum.md)
  : Define a property backed by one or more enum classes

## Scalar properties

Properties constrained to a single atomic value.

- [`property_scalar()`](https://josiahparry.github.io/s7x/reference/property_scalar.md)
  [`class_string`](https://josiahparry.github.io/s7x/reference/property_scalar.md)
  [`class_integer`](https://josiahparry.github.io/s7x/reference/property_scalar.md)
  [`class_double`](https://josiahparry.github.io/s7x/reference/property_scalar.md)
  : Define a scalar property

## Range properties

Scalar properties bound to an inclusive numeric range.

- [`property_range()`](https://josiahparry.github.io/s7x/reference/property_range.md)
  [`property_range_discrete()`](https://josiahparry.github.io/s7x/reference/property_range.md)
  : Define a range-bound scalar property

## Combinators

Combine classes and properties with OR/AND semantics.

- [`property_union()`](https://josiahparry.github.io/s7x/reference/property_union.md)
  [`` `|`( ``*`<S7_property>`*`)`](https://josiahparry.github.io/s7x/reference/property_union.md)
  : Create Property from a Union of Properties
- [`property_intersection()`](https://josiahparry.github.io/s7x/reference/property_intersection.md)
  [`` `&`( ``*`<S7_property>`*`)`](https://josiahparry.github.io/s7x/reference/property_intersection.md)
  : Create a property from an intersection of properties
