# Package index

## Enumerations

A scalar value drawn from a fixed set of variants.

- [`Enum()`](https://s7x.josiah.rs/reference/Enum.md) : Abstract base
  class for enumerations
- [`new_enum()`](https://s7x.josiah.rs/reference/new_enum.md) : Create a
  new enum class
- [`property_enum()`](https://s7x.josiah.rs/reference/property_enum.md)
  : Define a property backed by one or more enum classes

## Scalar properties

Properties constrained to a single atomic value.

- [`property_scalar()`](https://s7x.josiah.rs/reference/property_scalar.md)
  [`class_string`](https://s7x.josiah.rs/reference/property_scalar.md)
  [`class_integer`](https://s7x.josiah.rs/reference/property_scalar.md)
  [`class_double`](https://s7x.josiah.rs/reference/property_scalar.md)
  [`class_boolean`](https://s7x.josiah.rs/reference/property_scalar.md)
  : Define a scalar property

## Range properties

Scalar properties bound to an inclusive numeric range.

- [`property_range()`](https://s7x.josiah.rs/reference/property_range.md)
  [`property_range_discrete()`](https://s7x.josiah.rs/reference/property_range.md)
  : Define a range-bound scalar property

## Combinators

Combine classes and properties with OR/AND semantics.

- [`property_union()`](https://s7x.josiah.rs/reference/property_union.md)
  [`` `|`( ``*`<S7_property>`*`)`](https://s7x.josiah.rs/reference/property_union.md)
  : Create Property from a Union of Properties
- [`property_intersection()`](https://s7x.josiah.rs/reference/property_intersection.md)
  [`` `&`( ``*`<S7_property>`*`)`](https://s7x.josiah.rs/reference/property_intersection.md)
  : Create a property from an intersection of properties

## Coercion

Coerce S7 objects to plain R vectors.

- [`as_vector()`](https://s7x.josiah.rs/reference/as_vector.md) : Coerce
  an S7 object to a vector
