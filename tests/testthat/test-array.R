test_that("property_array accepts a list of the declared class", {
  Point <- S7::new_class("Point", properties = list(x = class_float))
  Path <- S7::new_class(
    "Path",
    properties = list(points = property_array(Point))
  )

  path <- Path(list(Point(1), Point(2)))
  expect_identical(path@points, list(Point(1), Point(2)))
})

test_that("property_array rejects an element of the wrong class", {
  Point <- S7::new_class("Point", properties = list(x = class_float))
  Path <- S7::new_class(
    "Path",
    properties = list(points = property_array(Point))
  )

  expect_error(Path(list(Point(1), "a")), "2")
})

test_that("property_array defaults to an empty list", {
  Point <- S7::new_class("Point", properties = list(x = class_float))
  Path <- S7::new_class(
    "Path",
    properties = list(points = property_array(Point))
  )

  expect_identical(Path()@points, list())
})
