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
    property_list_of(S7::class_double, min_length = 5, max_length = 1),
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
