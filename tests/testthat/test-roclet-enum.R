# Builds a throwaway package that uses `enum_roclet()`, documents it, and
# returns the lines of one generated .Rd file.
roxygenise_enum_pkg <- function(code, topic, envir = parent.frame()) {
  pkg_dir <- withr::local_tempdir(pattern = "testpkg", .local_envir = envir)

  usethis::create_package(
    path = pkg_dir,
    fields = list(
      Package = "testpkg",
      Version = "0.0.0.9000",
      Imports = "s7x",
      Roxygen = 'list(markdown = TRUE, roclets = c("collate", "namespace", "s7x::enum_roclet"))'
    ),
    open = FALSE,
    rstudio = FALSE
  )

  writeLines(code, file.path(pkg_dir, "R", "enums.R"))
  roxygen2::roxygenise(pkg_dir, load_code = "pkgload")

  readLines(file.path(pkg_dir, "man", topic))
}

test_that("enum_roclet documents an enum from the class itself", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' @export",
      'GridShape <- s7x::new_enum("GridShape", c("Square", "Hexagon"))'
    ),
    "GridShape.Rd"
  )

  expect_true(any(grepl("\\title{GridShape}", rd, fixed = TRUE)))
  expect_true(any(grepl("Square", rd, fixed = TRUE)))
  expect_true(any(grepl("Hexagon", rd, fixed = TRUE)))
  expect_true(any(grepl("\\usage{", rd, fixed = TRUE)))
  expect_true(any(grepl("\\arguments{", rd, fixed = TRUE)))
})

test_that("enum_roclet leaves a hand-written title alone", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' Grid shapes",
      "#' @export",
      'GridShape <- s7x::new_enum("GridShape", c("Square", "Hexagon"))'
    ),
    "GridShape.Rd"
  )

  expect_true(any(grepl("\\title{Grid shapes}", rd, fixed = TRUE)))
  expect_false(any(grepl("\\title{GridShape}", rd, fixed = TRUE)))
})

test_that("the generated usage shows the default as a literal", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' @export",
      'GridShape <- s7x::new_enum(',
      '  "GridShape",',
      '  c("Square", "Hexagon"),',
      '  default = "Square"',
      ")"
    ),
    "GridShape.Rd"
  )

  expect_true(any(grepl('GridShape(value = "Square")', rd, fixed = TRUE)))
})

test_that("enum constructors carry literal defaults in their formals", {
  GridShape <- new_enum("GridShape", c("Square", "Hexagon"), default = "Square")
  expect_identical(formals(GridShape)$value, "Square")

  Optional <- new_enum("Optional", c("A", "B"))
  expect_identical(formals(Optional)$value, NA_character_)

  Strict <- new_enum("Strict", c("A", "B"), allow_na = FALSE)
  expect_true(rlang::is_missing(formals(Strict)$value))
})

test_that("enum_roclet generates an example for an enum", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' @export",
      'GridShape <- s7x::new_enum("GridShape", c("Square", "Hexagon"))'
    ),
    "GridShape.Rd"
  )

  expect_true(any(grepl("\\examples{", rd, fixed = TRUE)))
  expect_true(any(grepl('GridShape("Square")', rd, fixed = TRUE)))
})

test_that("enum_roclet documents an S7 class's properties as params", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' A point",
      "#' @export",
      'Point <- S7::new_class("Point", properties = list(',
      "  label = s7x::class_string,",
      "  x = s7x::class_float",
      "))"
    ),
    "Point.Rd"
  )

  expect_true(any(grepl(
    "\\item{label}{a scalar character.}",
    rd,
    fixed = TRUE
  )))
  expect_true(any(grepl("\\item{x}{a scalar numeric.}", rd, fixed = TRUE)))
})

test_that("enum_roclet skips a computed property, which has no argument", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' A box",
      "#' @export",
      'Box <- S7::new_class("Box", properties = list(',
      "  width = s7x::class_float,",
      "  area = S7::new_property(S7::class_double, getter = function(self) self@width)",
      "))"
    ),
    "Box.Rd"
  )

  expect_true(any(grepl("\\item{width}{a scalar numeric.}", rd, fixed = TRUE)))
  expect_false(any(grepl("\\item{area}", rd, fixed = TRUE)))
})

test_that("enum_roclet lists each enum's variants on a shared page", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' Shapes",
      "#'",
      "#' Shape classes.",
      "#'",
      "#' @param value a scalar character. One of the class's variants.",
      "#' @name shapes",
      "#' @examples",
      "#' GridShape(\"Square\")",
      "NULL",
      "",
      "#' @rdname shapes",
      "#' @export",
      'GridShape <- s7x::new_enum("GridShape", c("Square", "Hexagon"))',
      "",
      "#' @rdname shapes",
      "#' @export",
      'Size <- s7x::new_enum("Size", c("Small", "Large"))'
    ),
    "shapes.Rd"
  )

  expect_true(any(grepl("\\section{Variants}{", rd, fixed = TRUE)))
  expect_true(any(grepl("\\code{GridShape}: one of", rd, fixed = TRUE)))
  expect_true(any(grepl("\\code{Size}: one of", rd, fixed = TRUE)))
  expect_false(any(grepl("\\title{GridShape}", rd, fixed = TRUE)))
  expect_identical(sum(grepl("\\item{value}", rd, fixed = TRUE)), 1L)
  expect_identical(sum(grepl("\\section{Variants}", rd, fixed = TRUE)), 1L)
})

test_that("enum_roclet documents value on a shared page", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' Shapes",
      "#'",
      "#' Shape classes.",
      "#'",
      "#' @name shapes",
      "#' @examples",
      "#' GridShape(\"Square\")",
      "NULL",
      "",
      "#' @rdname shapes",
      "#' @export",
      'GridShape <- s7x::new_enum("GridShape", c("Square", "Hexagon"))',
      "",
      "#' @rdname shapes",
      "#' @export",
      'Size <- s7x::new_enum("Size", c("Small", "Large"))'
    ),
    "shapes.Rd"
  )

  expect_true(any(grepl(
    "\\item{value}{a scalar character. One of the class's variants.}",
    rd,
    fixed = TRUE
  )))
  expect_identical(sum(grepl("\\item{value}", rd, fixed = TRUE)), 1L)
})

test_that("enum_roclet leaves a hand-written property param alone", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' A point",
      "#' @param label the point's label.",
      "#' @export",
      'Point <- S7::new_class("Point", properties = list(',
      "  label = s7x::class_string,",
      "  x = s7x::class_float",
      "))"
    ),
    "Point.Rd"
  )

  expect_true(any(grepl("\\item{label}{the point's label.}", rd, fixed = TRUE)))
  expect_false(any(grepl(
    "\\item{label}{a scalar character.}",
    rd,
    fixed = TRUE
  )))
  expect_true(any(grepl("\\item{x}{a scalar numeric.}", rd, fixed = TRUE)))
})

test_that("enum_roclet adds no params to a class on a shared page", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' Shapes",
      "#'",
      "#' Shape classes.",
      "#'",
      "#' @param x the x coordinate.",
      "#' @name shapes",
      "#' @examples",
      "#' Point(1)",
      "NULL",
      "",
      "#' @rdname shapes",
      "#' @export",
      'Point <- S7::new_class("Point", properties = list(x = s7x::class_float))'
    ),
    "shapes.Rd"
  )

  expect_true(any(grepl("\\item{x}{the x coordinate.}", rd, fixed = TRUE)))
  expect_false(any(grepl("\\item{x}{a scalar numeric.}", rd, fixed = TRUE)))
})

test_that("enum_roclet reads every name in a multi-name param", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' A point",
      "#' @param x,y the coordinates.",
      "#' @export",
      'Point <- S7::new_class("Point", properties = list(',
      "  x = s7x::class_float,",
      "  y = s7x::class_float",
      "))"
    ),
    "Point.Rd"
  )

  expect_true(any(grepl("\\item{x, y}{the coordinates.}", rd, fixed = TRUE)))
  expect_false(any(grepl("a scalar numeric.", rd, fixed = TRUE)))
})

test_that("enum_roclet labels vector and range properties", {
  skip_if_not_installed("roxygen2")
  skip_if_not_installed("usethis")
  skip_if_not_installed("withr")

  rd <- roxygenise_enum_pkg(
    c(
      "#' A sample",
      "#' @export",
      'Sample <- S7::new_class("Sample", properties = list(',
      "  values = S7::class_double,",
      "  level = s7x::property_range_discrete(1L, 6L)",
      "))"
    ),
    "Sample.Rd"
  )

  expect_true(any(grepl("\\item{values}{a numeric vector.}", rd, fixed = TRUE)))
  expect_true(any(grepl("\\item{level}{a scalar integer.}", rd, fixed = TRUE)))
})
