#' Abstract base class for enumerations
#'
#' A scalar character value drawn from a fixed set of variants. Use
#' [new_enum_class()] to create concrete subclasses.
#'
#' @include scalar.R utils.R union.R
#' @export
Enum <- S7::new_class(
  "Enum",
  properties = list(
    Value = class_string,
    Variants = S7::class_character
  ),
  validator = function(self) {
    if (!(self@Value %in% self@Variants)) {
      "@Value must be one of @Variants"
    }
  },
  abstract = TRUE
)

#' Create a new enum class
#'
#' @param name String. Name of the new class.
#' @param variants Character vector. Allowed values.
#' @param package String or NULL. Package to attribute the class to.
#'   Defaults to the caller's package, if any.
#' @return An S7 class generator that inherits from [Enum].
#' @export
new_enum_class <- function(
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

  S7::new_class(
    name,
    parent = Enum,
    package = package,
    properties = list(
      Value = class_string,
      Variants = S7::new_property(S7::class_character, default = variants)
    ),
    constructor = function(Value) {
      S7::new_object(S7::S7_object(), Value = Value, Variants = variants)
    }
  )
}

#' Define a property backed by one or more enum classes
#'
#' @param ... Enum classes. One or more classes from [new_enum_class()].
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
      "Every class in {.arg ...} must be created by {.fn new_enum_class}."
    )
  }

  property_union(..., default = default)
}
