# Package index

## Enumerations

A scalar value drawn from a fixed set of variants.

- [`Enum()`](https://s7x.josiah.rs/reference/Enum.md) : Create an
  Enum(eration)
- [`new_enum()`](https://s7x.josiah.rs/reference/new_enum.md) : Create a
  new enum class
- [`property_enum()`](https://s7x.josiah.rs/reference/property_enum.md)
  : Enum(eration) property
- [`enum_roclet()`](https://s7x.josiah.rs/reference/enum_roclet.md) :
  Roclet that documents enum and S7 classes

## Scalar properties

Properties constrained to a single atomic value.

- [`property_scalar()`](https://s7x.josiah.rs/reference/property_scalar.md)
  [`class_string`](https://s7x.josiah.rs/reference/property_scalar.md)
  [`class_int`](https://s7x.josiah.rs/reference/property_scalar.md)
  [`class_float`](https://s7x.josiah.rs/reference/property_scalar.md)
  [`class_boolean`](https://s7x.josiah.rs/reference/property_scalar.md)
  : Scalar property

## Range properties

Scalar properties bound to an inclusive numeric range.

- [`property_range()`](https://s7x.josiah.rs/reference/property_range.md)
  [`property_range_discrete()`](https://s7x.josiah.rs/reference/property_range.md)
  : Range property

## Combinators

Combine classes and properties with OR/AND semantics.

- [`property_union()`](https://s7x.josiah.rs/reference/property_union.md)
  [`` `|`( ``*`<S7_property>`*`)`](https://s7x.josiah.rs/reference/property_union.md)
  : Create Property from a Union of Properties
- [`property_intersection()`](https://s7x.josiah.rs/reference/property_intersection.md)
  [`` `&`( ``*`<S7_property>`*`)`](https://s7x.josiah.rs/reference/property_intersection.md)
  : Create a property from an intersection of properties

## Coercion

Coerce S7 objects to plain R vectors or JSON.

- [`as_vector()`](https://s7x.josiah.rs/reference/as_vector.md) : Coerce
  an S7 object to a vector
- [`from_vector()`](https://s7x.josiah.rs/reference/from_vector.md) :
  Build an S7 object from a vector
- [`to_json()`](https://s7x.josiah.rs/reference/to_json.md) : Coerce an
  S7 object to a JSON string
