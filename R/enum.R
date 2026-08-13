#' Abstract base class for enumerations
#'
#' A scalar character value drawn from a fixed set of variants. Use
#' [new_enum()] to create concrete subclasses.
#'
#' @include scalar.R utils.R union.R
#' @export
Enum <- S7::new_class(
  "Enum",
  properties = list(
    value = class_string,
    variants = S7::class_character
  ),
  validator = function(self) {
    if (!(self@value %in% self@variants)) {
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
#' @return An S7 class generator that inherits from [Enum].
#' @export
new_enum <- function(
  name,
  variants,
  package = topenv_package_name(parent.frame())
) {
  check_string(name, allow_empty = FALSE)
  check_character(variants)

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
      )
    ),
    constructor = function(value) {
      S7::new_object(S7::S7_object(), value = value, variants = variants)
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
