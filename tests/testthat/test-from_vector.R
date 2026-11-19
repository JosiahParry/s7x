test_that("from_vector builds an S7 object from a named list", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = class_float, y = class_float)
  )

  expect_identical(from_vector(list(x = 1, y = 2), Point), Point(1, 2))
})

test_that("from_vector recurses into nested S7 properties", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = class_float, y = class_float)
  )
  Segment <- S7::new_class(
    "Segment",
    properties = list(from = Point, to = Point)
  )

  result <- from_vector(
    list(from = list(x = 0, y = 0), to = list(x = 1, y = 1)),
    Segment
  )
  expect_identical(result, Segment(Point(0, 0), Point(1, 1)))
})

test_that("from_vector round-trips as_vector", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
  Point <- S7::new_class(
    "Point",
    properties = list(x = class_float, y = class_float)
  )
  Board <- S7::new_class(
    "Board",
    properties = list(
      shape = GridShape,
      corner = Point,
      label = class_string,
      tags = S7::class_character
    )
  )
  board <- Board(
    shape = GridShape("Hexagon"),
    corner = Point(0, 1),
    label = "main",
    tags = c("a", "b")
  )

  expect_identical(from_vector(as_vector(board), Board), board)
})

test_that("from_vector fills omitted properties with their defaults", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = class_float, y = class_float)
  )

  expect_identical(from_vector(list(x = 1), Point), Point(x = 1))
})

test_that("from_vector converts a string to an enum", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"))

  expect_identical(from_vector("Square", GridShape), GridShape("Square"))
})

test_that("from_vector errors on names that are not properties", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = class_float, y = class_float)
  )

  expect_error(from_vector(list(x = 1, y = 2, zz = 3), Point), "zz")
})

test_that("from_vector returns an atomic unchanged for a base class", {
  expect_identical(from_vector(c(1, 2), S7::class_double), c(1, 2))
})

test_that("from_vector leaves a union property value unchanged", {
  Piece <- S7::new_class(
    "Piece",
    properties = list(
      id = property_union(S7::class_character, S7::class_integer)
    )
  )

  expect_identical(from_vector(list(id = 3L), Piece), Piece(3L))
})

test_that("from_vector keeps the elements of a class_list property as lists", {
  Path <- S7::new_class("Path", properties = list(points = S7::class_list))
  points <- list(list(x = 0, y = 0), list(x = 1, y = 1))

  expect_identical(from_vector(list(points = points), Path)@points, points)
})

test_that("from_vector unclasses a data frame in a class_list property", {
  Table <- S7::new_class("Table", properties = list(rows = S7::class_list))
  rows <- data.frame(a = 1:2, b = c("x", "y"))

  result <- from_vector(list(rows = rows), Table)
  expect_identical(result@rows, unclass(rows))
})

test_that("from_vector builds an S7 object from the columns of a data frame", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = class_float, y = class_float)
  )

  expect_identical(from_vector(data.frame(x = 1, y = 2), Point), Point(1, 2))
})
