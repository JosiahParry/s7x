test_that("to_json serializes an S7 object's properties", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )

  result <- to_json(Point(1, 2))
  expect_equal(
    yyjsonr::read_json_str(
      result,
      obj_of_arrs_to_df = FALSE,
      arr_of_objs_to_df = FALSE
    ),
    list(x = 1, y = 2)
  )
})

test_that("to_json recurses into nested S7 properties", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )
  Segment <- S7::new_class(
    "Segment",
    properties = list(from = Point, to = Point)
  )

  result <- to_json(Segment(Point(0, 0), Point(1, 1)))
  expect_equal(
    yyjsonr::read_json_str(
      result,
      obj_of_arrs_to_df = FALSE,
      arr_of_objs_to_df = FALSE
    ),
    list(from = list(x = 0, y = 0), to = list(x = 1, y = 1))
  )
})

test_that("to_json passes pretty through to yyjsonr", {
  Point <- S7::new_class(
    "Point",
    properties = list(x = S7::class_double, y = S7::class_double)
  )

  compact <- to_json(Point(1, 2))
  pretty <- to_json(Point(1, 2), pretty = TRUE)
  expect_false(grepl("\n", compact))
  expect_true(grepl("\n", pretty))
})
