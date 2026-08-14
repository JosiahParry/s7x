test_that("as_vector.S7_object builds a named list of properties", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )

  expect_equal(as_vector(Point(1, 2)), list(x = 1, y = 2))
})

test_that("as_vector recurses into nested S7 properties", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )
  Segment <- S7::new_class(
    "Segment",
    properties = list(from = Point, to = Point)
  )

  result <- as_vector(Segment(Point(0, 0), Point(1, 1)))
  expect_equal(result, list(from = list(x = 0, y = 0), to = list(x = 1, y = 1)))
})

test_that("as_vector.Enum returns the underlying atomic value", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"))

  result <- as_vector(GridShape("Square"))
  expect_equal(result, "Square")
  expect_true(is.vector(result))
  expect_true(is.character(result))
})
