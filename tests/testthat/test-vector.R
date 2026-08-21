test_that("property_vector accepts an atomic vector of any length", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(x = property_vector(S7::class_double))
  )

  expect_equal(Foo(c(1, 2, 3))@x, c(1, 2, 3))
  expect_equal(Foo(1)@x, 1)
  expect_equal(Foo(numeric())@x, numeric())
})

test_that("property_vector rejects a list and the wrong base type", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(x = property_vector(S7::class_double))
  )

  expect_error(Foo(list(1)), "<double>")
  expect_error(Foo("a"), "<double>")
})

test_that("property_vector honours length bounds", {
  Pair <- S7::new_class(
    "Pair",
    properties = list(
      x = property_vector(S7::class_double, min_length = 2, max_length = 2)
    )
  )

  expect_equal(Pair(c(1, 2))@x, c(1, 2))
  expect_error(Pair(1), "at least 2")
  expect_error(Pair(c(1, 2, 3)), "at most 2")
})

test_that("property_list_of accepts a list of the declared class", {
  Stop <- S7::new_class("Stop", properties = list(at = class_float))
  Ramp <- S7::new_class(
    "Ramp",
    properties = list(stops = property_list_of(Stop))
  )

  expect_length(Ramp(list(Stop(0), Stop(1)))@stops, 2)

  # An empty list, not NULL, so the property is always safe to iterate.
  expect_equal(Ramp()@stops, list())
})

test_that("property_list_of rejects an element of the wrong class", {
  Stop <- S7::new_class("Stop", properties = list(at = class_float))
  Ramp <- S7::new_class(
    "Ramp",
    properties = list(stops = property_list_of(Stop))
  )

  expect_error(Ramp(list(Stop(0), 5)), "only <Stop>")
  expect_error(Ramp(5), "<list>")

  # The message names where to look, not just that something is wrong.
  expect_error(Ramp(list(Stop(0), 5)), "position 2")
})

test_that("property_list_of expresses a fixed arity spec type", {
  Axis <- S7::new_class("Axis", properties = list(at = class_float))
  Chart <- S7::new_class(
    "Chart",
    properties = list(
      axes = property_list_of(Axis, min_length = 1, max_length = 3)
    )
  )

  expect_length(Chart(list(Axis(0), Axis(1)))@axes, 2)
  expect_error(Chart(list()), "at least 1")
  expect_error(Chart(rep(list(Axis(0)), 4)), "at most 3")
})

test_that("length bounds are validated when the property is defined", {
  expect_error(
    property_vector(S7::class_double, min_length = 5, max_length = 1),
    "less than or equal to"
  )
  expect_error(
    property_list_of(S7::class_double, min_length = -1),
    "must be a number"
  )
})

test_that("a list-of property survives as_vector()", {
  Stop <- S7::new_class("Stop", properties = list(at = class_float))
  Ramp <- S7::new_class(
    "Ramp",
    properties = list(stops = property_list_of(Stop))
  )

  out <- as_vector(Ramp(list(Stop(0), Stop(1))))

  expect_length(out$stops, 2)
  expect_equal(out$stops[[1]]$at, 0)
})
