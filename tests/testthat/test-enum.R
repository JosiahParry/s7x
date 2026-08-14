test_that("new_enum builds a working subclass of Enum", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"))

  shape <- GridShape("Square")
  expect_true(S7::S7_inherits(shape, Enum))
  expect_equal(shape@value, "Square")
  expect_equal(shape@variants, c("Square", "Hexagon"))
})

test_that("new_enum rejects values outside the variant set", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
  expect_error(GridShape("Triangle"))
})

test_that("new_enum validates its own arguments", {
  expect_error(new_enum("GridShape", character()), "variants")
  expect_error(new_enum("GridShape", c("A", "A")), "unique")
})

test_that("classes from new_enum work in a default-less union property", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
  Direction <- new_enum("Direction", c("North", "South"))

  Board <- S7::new_class(
    "Board",
    properties = list(orientation = property_enum(GridShape, Direction))
  )

  expect_equal(Board(GridShape("Square"))@orientation@value, "Square")
  expect_equal(Board(Direction("North"))@orientation@value, "North")
  expect_error(Board("Square"))
})

test_that("property_enum rejects classes not created by new_enum", {
  expect_error(property_enum(S7::class_character), "new_enum")
})

test_that("new_enum allows NA_character_ by default", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
  shape <- GridShape(NA_character_)
  expect_true(is.na(shape@value))
})

test_that("new_enum rejects NA_character_ when allow_na is FALSE", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"), allow_na = FALSE)
  expect_error(GridShape(NA_character_), "must not be NA")
})

test_that("new_enum validates allow_na", {
  expect_error(new_enum("GridShape", c("Square", "Hexagon"), allow_na = "yes"))
})
