Point <- S7::new_class(
  "Point",
  properties = list(x = class_float, y = class_float)
)
Segment <- S7::new_class(
  "Segment",
  properties = list(from = Point, to = Point)
)
Path <- S7::new_class(
  "Path",
  properties = list(name = class_string, points = property_array(Point))
)

test_that("from_json builds one object from a JSON object", {
  expect_identical(from_json('{"x":1.0,"y":2.0}', Point), Point(1, 2))
})

test_that("from_json builds one object per row of a JSON array", {
  result <- from_json('[{"x":1.0,"y":2.0},{"x":3.0,"y":4.0}]', Point)
  expect_identical(result, list(Point(1, 2), Point(3, 4)))
})

test_that("from_json builds nested S7 objects", {
  json <- '{"from":{"x":0.0,"y":0.0},"to":{"x":1.0,"y":1.0}}'
  expect_identical(from_json(json, Segment), Segment(Point(0, 0), Point(1, 1)))
})

test_that("from_json builds a row of nested S7 objects per array element", {
  json <- paste0(
    '[{"from":{"x":0.0,"y":0.0},"to":{"x":1.0,"y":1.0}},',
    '{"from":{"x":2.0,"y":2.0},"to":{"x":3.0,"y":3.0}}]'
  )
  expect_identical(
    from_json(json, Segment),
    list(Segment(Point(0, 0), Point(1, 1)), Segment(Point(2, 2), Point(3, 3)))
  )
})

test_that("from_json round-trips to_json", {
  segment <- Segment(Point(0, 0.5), Point(1, 1.5))
  expect_identical(from_json(to_json(segment), Segment), segment)
})

test_that("from_json builds each element of an array property", {
  json <- '{"name":"route","points":[{"x":0.0,"y":0.0},{"x":1.0,"y":1.0}]}'
  result <- from_json(json, Path)
  expect_identical(result@points, list(Point(0, 0), Point(1, 1)))
})
