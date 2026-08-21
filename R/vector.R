#' Define a vector property
#'
#' The plural counterparts to [property_scalar()]. `property_vector()` takes
#' an atomic vector of `class`, `property_list_of()` a list whose every
#' element is an instance of `class`.
#'
#' Reach for these where a scalar preset like [class_string] would be wrong
#' because the value is genuinely plural. A spec typed `number[]` wants
#' `property_vector(S7::class_double)`, and one typed `Stop[]` wants
#' `property_list_of(Stop)` - not an untyped list, which validates nothing.
#'
#' `min_length` and `max_length` are how a fixed-arity spec type is
#' expressed: a tuple of one to three axes is
#' `property_list_of(Axis, min_length = 1, max_length = 3)`.
#'
#' @param class S7 class spec. Base type every element must be an instance of.
#' @param default Any. Passed to [S7::new_property()].
#' @param min_length,max_length Number. Inclusive bounds on `length(value)`.
#'   `max_length` may be `Inf` for an unbounded vector.
#' @return An S7 property whose value must be a vector of `class`.
#' @examples
#' library(S7)
#' Path := new_class(
#'   properties = list(xs = property_vector(S7::class_double))
#' )
#' Path(c(1, 2, 3))
#' @export
property_vector <- function(
  class,
  default = NULL,
  min_length = 0,
  max_length = Inf
) {
  check_length_bounds(min_length, max_length)

  S7::new_property(
    class,
    validator = function(value) {
      if (!rlang::is_atomic(value)) {
        return("must be an atomic vector")
      }
      check_length(value, min_length, max_length)
    },
    default = default
  )
}

#' @rdname property_vector
#' @examples
#' Stop := new_class(properties = list(at = class_float))
#' Ramp := new_class(properties = list(stops = property_list_of(Stop)))
#' Ramp(list(Stop(0), Stop(1)))
#' @export
property_list_of <- function(
  class,
  default = quote(list()),
  min_length = 0,
  max_length = Inf
) {
  check_length_bounds(min_length, max_length)

  S7::new_property(
    S7::class_list,
    validator = function(value) {
      if (!rlang::is_bare_list(value)) {
        return("must be a list")
      }

      bad <- which(!vapply(value, class_matches, logical(1), class = class))
      if (length(bad) > 0L) {
        label <- class_label(class)
        return(cli::format_inline(
          "must contain only {.cls {label}}; check position {.val {bad}}"
        ))
      }

      check_length(value, min_length, max_length)
    },
    default = default
  )
}

check_length_bounds <- function(min_length, max_length, call = caller_env()) {
  check_number_decimal(min_length, min = 0, call = call)
  check_number_decimal(max_length, min = 0, allow_infinite = TRUE, call = call)
  if (min_length > max_length) {
    cli::cli_abort(
      "{.arg min_length} must be less than or equal to {.arg max_length}.",
      call = call
    )
  }
  invisible(NULL)
}

# NULL when the length is in range, so it drops straight into a validator.
check_length <- function(value, min_length, max_length) {
  n <- length(value)
  if (n < min_length) {
    return(cli::format_inline(
      "must have at least {min_length} element{?s}, not {n}"
    ))
  }
  if (n > max_length) {
    return(cli::format_inline(
      "must have at most {max_length} element{?s}, not {n}"
    ))
  }
  NULL
}

# S7 classes carry their name; a base type spec carries `$class` instead.
class_label <- function(class) {
  if (rlang::is_function(class)) {
    name <- attr(class, "name")
    return(if (rlang::is_null(name)) "S7 object" else name)
  }
  if (rlang::is_list(class) && !rlang::is_null(class$class)) {
    return(class$class)
  }
  "value"
}
