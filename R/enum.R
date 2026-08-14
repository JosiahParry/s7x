#' Abstract base class for enumerations
#'
#' A scalar character value drawn from a fixed set of variants. Use
#' [new_enum()] to create concrete subclasses.
#'
#' @include scalar.R utils.R union.R
#' @examples
#' GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
#' S7::S7_inherits(GridShape("Square"), Enum)
#' @export
Enum <- S7::new_class(
  "Enum",
  properties = list(
    value = class_string,
    variants = S7::class_character,
    allow_na = class_boolean
  ),
  validator = function(self) {
    if (is.na(self@value)) {
      if (!self@allow_na) "@value must not be NA"
    } else if (!(self@value %in% self@variants)) {
      "@value must be one of @variants"
    }
  },
  abstract = TRUE
)

method(convert, list(Enum, class_character)) <- function(from, to, ...) {
  from@value
}

#' @rawNamespace S3method(as.character, "s7x::Enum", enum_as_character)
enum_as_character <- function(x, ...) {
  x@value
}

#' Create a new enum class
#'
#' @param name String. Name of the new class.
#' @param variants Character vector. Allowed values.
#' @param package String or NULL. Package to attribute the class to.
#'   Defaults to the caller's package, if any.
#' @param allow_na Bool. Whether `NA_character_` is a valid value.
#' @return An S7 class generator that inherits from [Enum].
#' @examples
#' GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
#' GridShape("Square")
#' GridShape(NA_character_)
#' @export
new_enum <- function(
  name,
  variants,
  package = topenv_package_name(parent.frame()),
  allow_na = TRUE
) {
  check_string(name, allow_empty = FALSE)
  check_character(variants)
  check_bool(allow_na)

  if (length(variants) == 0L) {
    cli::cli_abort("{.arg variants} must contain at least one value.")
  }
  if (anyDuplicated(variants)) {
    cli::cli_abort("{.arg variants} must be unique.")
  }

  enum_class <- S7::new_class(
    name,
    parent = Enum,
    package = package,
    properties = list(
      value = class_string,
      variants = S7::new_property(
        S7::class_character,
        default = quote(variants)
      ),
      allow_na = property_scalar(
        S7::class_logical,
        default = quote(allow_na)
      )
    ),
    constructor = function(value) {
      S7::new_object(
        S7::S7_object(),
        value = value,
        variants = variants,
        allow_na = allow_na
      )
    }
  )

  method(convert, list(class_character, enum_class)) <- function(
    from,
    to,
    ...
  ) {
    enum_class(from)
  }

  enum_class
}

#' Define a property backed by one or more enum classes
#'
#' @param ... Enum classes. One or more classes from [new_enum()].
#' @param default Any. Passed to [S7::new_property()].
#' @return An S7 property typed as the union of `...`.
#' @examples
#' library(S7)
#' GridShape <- new_enum("GridShape", c("Square", "Hexagon"))
#' Direction <- new_enum("Direction", c("North", "South"))
#' Board := new_class(
#'   properties = list(orientation = property_enum(GridShape, Direction))
#' )
#' Board(GridShape("Square"))
#' @export
property_enum <- function(..., default = NULL) {
  classes <- list(...)
  if (length(classes) == 0L) {
    cli::cli_abort("{.arg ...} must contain at least one enum class.")
  }

  is_enum <- vapply(
    classes,
    function(cls) inherits(cls, "S7_class") && identical(cls@parent, Enum),
    logical(1)
  )
  if (!all(is_enum)) {
    cli::cli_abort(
      "Every class in {.arg ...} must be created by {.fn new_enum}."
    )
  }

  property_union(..., default = default)
}
