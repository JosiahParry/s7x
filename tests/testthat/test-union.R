test_that("property_union unions plain S7 classes", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(
      x = property_union(S7::class_character, S7::class_integer)
    )
  )

  expect_equal(Foo("a")@x, "a")
  expect_equal(Foo(1L)@x, 1L)
  expect_error(Foo(1.5))
})

test_that("property_union applies a member property's own validator", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(
      x = property_union(property_range_discrete(1L, 6L), class_string)
    )
  )

  expect_equal(Foo(3L)@x, 3L)
  expect_equal(Foo("hello")@x, "hello")
  expect_error(Foo(10L), "does not satisfy")
})

test_that("|.S7_property matches property_union", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(x = class_string | property_range_discrete(1L, 6L))
  )

  expect_equal(Foo(3L)@x, 3L)
  expect_equal(Foo("hello")@x, "hello")
  expect_error(Foo(10L), "does not satisfy")
})

test_that("property_union passes default through", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(
      x = property_union(S7::class_character, S7::class_integer, default = "a")
    )
  )

  expect_equal(Foo()@x, "a")
})

test_that("property_union derives a default from a scalar preset member when omitted", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(x = property_union(class_string, class_double))
  )

  expect_true(is.na(Foo()@x))
})

test_that("an explicit default overrides a derivable member default", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(
      x = property_union(class_string, class_double, default = "hi")
    )
  )

  expect_equal(Foo()@x, "hi")
})

test_that("an explicit default = NULL pins the default and opts out of derivation", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )
  Foo <- S7::new_class(
    "Foo",
    properties = list(p = property_union(NULL, Point, default = NULL))
  )

  expect_null(Foo()@p)
})

test_that("default = NULL resolves to NULL regardless of where NULL sits among members", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )
  Foo <- S7::new_class(
    "Foo",
    properties = list(p = property_union(Point, NULL, default = NULL))
  )

  expect_null(Foo()@p)
  expect_equal(Foo(Point(1, 2))@p@x, 1)
})
