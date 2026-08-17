#' Abstract base class for enumerations
#'
#' A scalar character value drawn from a fixed set of variants. Use
#' [new_enum()] to create concrete subclasses.
#'
#' @param value String. The enum's current value.
#' @inheritParams new_enum
#' @include scalar.R utils.R union.R as_vector.R
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
      cli::format_inline("@value must be one of {.val {self@variants}}")
    }
  },
  abstract = TRUE
)

method(convert, list(Enum, class_character)) <- function(from, to, ...) {
  from@value
}

method(as_vector, Enum) <- function(x, ...) {
  x@value
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
#' @param default String or NULL. Default value used when the property is
#'   omitted. Must be one of `variants`, or `NA` if `allow_na = TRUE`. If
#'   `NULL` (the default), falls back to `NA_character_` when
#'   `allow_na = TRUE`, otherwise the value stays required with no default.
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
  allow_na = TRUE,
  default = NULL
) {
  check_string(name, allow_empty = FALSE)
  check_character(variants)
  check_bool(allow_na)
  check_string(default, allow_na = TRUE, allow_null = TRUE)

  if (length(variants) == 0L) {
    cli::cli_abort("{.arg variants} must contain at least one value.")
  }
  if (anyDuplicated(variants)) {
    cli::cli_abort("{.arg variants} must be unique.")
  }

  default <- if (!rlang::is_null(default)) {
    valid <- (allow_na && is.na(default)) || default %in% variants
    if (!valid) {
      cli::cli_abort(
        "{.arg default} must be one of {.val {variants}}{if (allow_na) ' or NA' else ''}."
      )
    }
    default
  } else if (allow_na) {
    NA_character_
  } else {
    NULL
  }

  enum_class <- S7::new_class(
    name,
    parent = Enum,
    package = package,
    properties = list(
      value = class_string,
      variants = S7::new_property(
        S7::class_character,
        default = rlang::expr(variants)
      ),
      allow_na = property_scalar(
        S7::class_logical,
        default = rlang::expr(allow_na)
      )
    ),
    constructor = rlang::new_function(
      args = if (rlang::is_null(default)) {
        rlang::pairlist2(value = )
      } else {
        rlang::pairlist2(value = default)
      },
      body = rlang::expr({
        S7::new_object(
          S7::S7_object(),
          value = value,
          variants = variants,
          allow_na = allow_na
        )
      }),
      env = rlang::current_env()
    )
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

# Whether `x` is a class generator produced by new_enum().
is_enum_class <- function(x) {
  inherits(x, "S7_class") && identical(x@parent, Enum)
}
