test_that("property_intersection requires every member to be satisfied", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(
      x = property_intersection(
        property_scalar(S7::class_character),
        S7::new_property(
          S7::class_character,
          validator = function(value) {
            if (!(value %in% c("a", "b"))) "must be a or b"
          }
        )
      )
    )
  )

  expect_equal(Foo("a")@x, "a")
  expect_error(Foo("c"), "must be a or b")
  expect_error(Foo(c("a", "b")), "scalar atomic")
})

test_that("property_intersection reproduces an enum via composition", {
  variants <- c("Square", "Hexagon")
  GridShapeProp <- property_intersection(
    property_scalar(S7::class_character),
    S7::new_property(
      S7::class_character,
      validator = function(value) {
        if (!(value %in% variants)) "must be one of the variants"
      }
    )
  )
  Board <- S7::new_class("Board", properties = list(orientation = GridShapeProp))

  expect_equal(Board("Square")@orientation, "Square")
  expect_error(Board("Triangle"), "variants")
  expect_error(Board(c("Square", "Hexagon")), "scalar atomic")
})

test_that("property_intersection rejects members with different underlying classes", {
  expect_error(
    property_intersection(S7::class_character, S7::class_double),
    "same underlying class"
  )
})

test_that("property_intersection requires at least one member", {
  expect_error(property_intersection(), "at least one")
})

test_that("&.S7_property matches property_intersection", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(
      x = property_scalar(S7::class_character) &
        S7::new_property(
          S7::class_character,
          validator = function(value) {
            if (!(value %in% c("a", "b"))) "must be a or b"
          }
        )
    )
  )

  expect_equal(Foo("a")@x, "a")
  expect_error(Foo("c"), "must be a or b")
})

test_that("property_enum is derived via property_intersection", {
  variants <- c("Square", "Hexagon")

  property_enum_equivalent <- property_intersection(
    property_scalar(S7::class_character),
    S7::new_property(
      S7::class_character,
      validator = function(value) {
        if (!(value %in% variants)) "must be one of the variants"
      }
    )
  )

  GridShape <- new_enum("GridShape", variants)
  Board <- S7::new_class(
    "Board",
    properties = list(orientation = property_enum_equivalent)
  )

  expect_equal(Board("Square")@orientation, GridShape("Square")@value)
  expect_error(Board("Triangle"), "variants")
  expect_error(Board(c("Square", "Hexagon")), "scalar atomic")
})

test_that("property_intersection passes default through", {
  Foo <- S7::new_class(
    "Foo",
    properties = list(
      x = property_intersection(
        property_scalar(S7::class_character),
        S7::new_property(S7::class_character),
        default = "a"
      )
    )
  )

  expect_equal(Foo()@x, "a")
})
