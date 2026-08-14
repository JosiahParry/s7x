test_that("property_scalar accepts a scalar atomic value", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(x = property_scalar(S7::class_character))
  )

  expect_equal(Foo("a")@x, "a")
})

test_that("property_scalar rejects non-scalar values", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(x = property_scalar(S7::class_character))
  )

  expect_error(Foo(c("a", "b")), "scalar atomic")
  expect_error(Foo(character()), "scalar atomic")
})

test_that("property_range accepts a value within bounds", {
  Foo <- S7::new_class("Foo", properties = list(x = property_range(1, 6)))

  expect_equal(Foo(1)@x, 1)
  expect_equal(Foo(6)@x, 6)
})

test_that("property_range rejects a value outside bounds", {
  Foo <- S7::new_class("Foo", properties = list(x = property_range(1, 6)))

  expect_error(Foo(0), "between")
  expect_error(Foo(7), "between")
})

test_that("property_range's allow_na controls whether NA is valid", {
  Foo <- S7::new_class("Foo", properties = list(x = property_range(1, 6)))
  Bar <- S7::new_class(
    "Bar",
    properties = list(x = property_range(1, 6, allow_na = FALSE))
  )

  expect_true(is.na(Foo(NA_real_)@x))
  expect_error(Bar(NA_real_), "NA")
})

test_that("property_range validates min <= max at construction time", {
  expect_error(property_range(6, 1), "min")
})

test_that("property_range_discrete rejects a non-integer value", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(x = property_range_discrete(1L, 6L))
  )

  expect_error(Foo(1.5))
})

test_that("property_range_discrete supports the HeadingLevel example", {
  HeadingLevel <- property_range_discrete(1L, 6L)
  Foo <- S7::new_class("Foo", properties = list(level = HeadingLevel))

  expect_equal(Foo(1L)@level, 1L)
  expect_equal(Foo(6L)@level, 6L)
  expect_error(Foo(0L), "between")
  expect_error(Foo(7L), "between")
})

test_that("scalar presets default to a typed NA when omitted", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(
      a = class_string,
      b = class_integer,
      c = class_double,
      d = class_boolean
    )
  )

  foo <- Foo()
  expect_true(is.na(foo@a))
  expect_true(is.na(foo@b))
  expect_true(is.na(foo@c))
  expect_true(is.na(foo@d))
})
