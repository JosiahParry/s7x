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
