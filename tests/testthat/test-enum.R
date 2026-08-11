test_that("new_enum_class builds a working subclass of Enum", {
  GridShape <- new_enum_class("GridShape", c("Square", "Hexagon"))

  shape <- GridShape("Square")
  expect_true(S7::S7_inherits(shape, Enum))
  expect_equal(shape@Value, "Square")
  expect_equal(shape@Variants, c("Square", "Hexagon"))
})

test_that("new_enum_class rejects values outside the variant set", {
  GridShape <- new_enum_class("GridShape", c("Square", "Hexagon"))
  expect_error(GridShape("Triangle"))
})

test_that("new_enum_class validates its own arguments", {
  expect_error(new_enum_class("GridShape", character()), "variants")
  expect_error(new_enum_class("GridShape", c("A", "A")), "unique")
})

test_that("classes from new_enum_class work in a default-less union property", {
  GridShape <- new_enum_class("GridShape", c("Square", "Hexagon"))
  Direction <- new_enum_class("Direction", c("North", "South"))

  Board <- S7::new_class(
    "Board",
    properties = list(orientation = property_enum(GridShape, Direction))
  )

  expect_equal(Board(GridShape("Square"))@orientation@Value, "Square")
  expect_equal(Board(Direction("North"))@orientation@Value, "North")
  expect_error(Board("Square"))
})

test_that("property_enum rejects classes not created by new_enum_class", {
  expect_error(property_enum(S7::class_character), "new_enum_class")
})
