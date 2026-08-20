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

test_that("as_vector recurses into S7 objects nested inside a list property", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )
  Path <- S7::new_class(
    "Path",
    properties = list(points = S7::class_list)
  )

  result <- as_vector(Path(points = list(Point(0, 0), Point(1, 1))))
  expect_equal(
    result,
    list(points = list(list(x = 0, y = 0), list(x = 1, y = 1)))
  )
})

test_that("as_vector coerces a bare list elementwise without adding a level", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )

  result <- as_vector(list(name = "a", at = Point(1, 2), n = 3))
  expect_equal(result, list(name = "a", at = list(x = 1, y = 2), n = 3))
  expect_length(result, 3)
})

test_that("as_vector dispatches an S7 object to its own method, not the list one", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )

  expect_equal(as_vector(Point(1, 2)), list(x = 1, y = 2))
  expect_named(as_vector(Point(1, 2)), c("x", "y"))
})

test_that("as_vector leaves a data frame alone rather than flipping it columnar", {
  fields <- data.frame(name = c("a", "b"), type = c("x", "y"))

  result <- as_vector(list(fields = fields, n = 2))
  expect_s3_class(result$fields, "data.frame")
  expect_equal(result$fields, fields)
})

test_that("as_vector.Enum returns the underlying atomic value", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"))

  result <- as_vector(GridShape("Square"))
  expect_equal(result, "Square")
  expect_true(is.vector(result))
  expect_true(is.character(result))
})
