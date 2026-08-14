#' Define a scalar property
#'
#' @param class S7 class spec. Base type the value must be an instance of.
#' @param default Any. Passed to [S7::new_property()].
#' @return An S7 property whose value must be a scalar atomic.
#' @examples
#' library(S7)
#' Point := new_class(properties = list(x = property_scalar(S7::class_double)))
#' Point(1.5)
#' @export
property_scalar <- function(class, default = NULL) {
  S7::new_property(
    class,
    validator = function(value) {
      if (!rlang::is_scalar_atomic(value)) {
        "must be a scalar atomic"
      }
    },
    default = default
  )
}

#' Scalar property presets
#'
#' Ready-to-use [property_scalar()] variants for the common atomic base
#' types.
#'
#' @format NULL
#' @rdname property_scalar
#' @examples
#' library(S7)
#' Board := new_class(
#'   properties = list(
#'     label = class_string,
#'     rank = class_integer,
#'     score = class_double
#'   )
#' )
#' Board("check", 1L, 0.5)
#' @export
class_string <- property_scalar(S7::class_character, default = NA_character_)

#' @rdname property_scalar
#' @export
class_integer <- property_scalar(S7::class_integer, default = NA_integer_)

#' @rdname property_scalar
#' @export
class_double <- property_scalar(S7::class_double, default = NA_real_)

#' @rdname property_scalar
#' @export
class_boolean <- property_scalar(S7::class_logical, default = NA)

new_range_property <- function(class, min, max, allow_na, na_default) {
  if (min > max) {
    cli::cli_abort("{.arg min} must be less than or equal to {.arg max}.")
  }

  S7::new_property(
    class,
    validator = function(value) {
      if (!rlang::is_scalar_atomic(value)) {
        return("must be a scalar atomic")
      }
      if (is.na(value)) {
        if (!allow_na) "must not be NA"
      } else if (value < min || value > max) {
        sprintf("must be between %s and %s", min, max)
      }
    },
    default = if (allow_na) na_default else NULL
  )
}

#' Define a range-bound scalar property
#'
#' A scalar property constrained to `[min, max]` inclusive.
#' `property_range()` is for doubles, `property_range_discrete()` for
#' integers.
#'
#' @param min Number. Inclusive lower bound.
#' @param max Number. Inclusive upper bound.
#' @param allow_na Bool. Whether `NA` is a valid value.
#' @return An S7 property whose value must be a scalar within `[min, max]`.
#' @examples
#' library(S7)
#' HeadingLevel <- property_range_discrete(1L, 6L)
#' Heading := new_class(properties = list(level = HeadingLevel))
#' Heading(1L)
#' @export
property_range <- function(min, max, allow_na = TRUE) {
  check_number_decimal(min)
  check_number_decimal(max)
  check_bool(allow_na)
  new_range_property(S7::class_double, min, max, allow_na, NA_real_)
}

#' @rdname property_range
#' @export
property_range_discrete <- function(min, max, allow_na = TRUE) {
  check_number_whole(min)
  check_number_whole(max)
  check_bool(allow_na)
  new_range_property(
    S7::class_integer,
    as.integer(min),
    as.integer(max),
    allow_na,
    NA_integer_
  )
}
