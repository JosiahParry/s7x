#' Create Property from a Union of Properties
#'
#' An analogue to [S7::new_union()]. Defines a new property
#' from multiple
#'
#' @param ... S7 classes or properties to union.
#' @param default Any. Passed to [S7::new_property()]. If `NULL` (the
#'   default), falls back to the first member's own default (only members
#'   that are an `S7_property`, e.g. a [property_scalar()] preset, carry
#'   one) that satisfies the union's combined validator.
#' @return An S7 property typed as the union of `...`.
#' @examples
#' library(S7)
#' Piece := new_class(
#'   properties = list(id = property_union(S7::class_character, S7::class_integer))
#' )
#' Piece("a")
#' Piece(1L)
#' @export
property_union <- function(..., default = NULL) {
  members <- rlang::list2(...)
  classes <- lapply(
    members,
    function(m) if (inherits(m, "S7_property")) m$class else m
  )
  member_validator <- function(m) {
    if (inherits(m, "S7_property")) m$validator else NULL
  }

  is_valid <- function(value) {
    matches <- vapply(
      seq_along(members),
      function(i) {
        if (!class_matches(value, classes[[i]])) {
          return(NA)
        }
        validator <- member_validator(members[[i]])
        if (rlang::is_null(validator)) {
          TRUE
        } else {
          rlang::is_null(validator(value))
        }
      },
      logical(1)
    )
    matches <- matches[!is.na(matches)]
    length(matches) == 0 || any(matches)
  }

  resolved_default <- if (!rlang::is_null(default)) {
    default
  } else {
    member_defaults <- lapply(
      members,
      function(m) if (inherits(m, "S7_property")) m$default else NULL
    )
    member_defaults <- Filter(Negate(rlang::is_null), member_defaults)
    valid_defaults <- Filter(is_valid, member_defaults)
    if (length(valid_defaults) > 0) valid_defaults[[1]] else NULL
  }

  S7::new_property(
    Reduce(`|`, classes),
    validator = function(value) {
      if (!is_valid(value)) "does not satisfy any member of the union"
    },
    default = resolved_default
  )
}

# Whether `value` is an instance of `class`, a class spec accepted by
# S7::new_union() (S7 class, union, or base type). S7_inherits() only
# accepts S7 classes, not unions or base type specs, so this dispatches on
# structural shape instead: a function is an S7 class, a list with
# `$classes` is a union, a list with `$class` is a base type.
class_matches <- function(value, class) {
  if (rlang::is_function(class)) {
    return(S7::S7_inherits(value, class))
  }

  if (rlang::is_list(class) && !rlang::is_null(class$classes)) {
    return(any(vapply(class$classes, class_matches, logical(1), value = value)))
  }

  if (rlang::is_list(class) && !rlang::is_null(class$class)) {
    return(identical(typeof(value), class$class))
  }

  FALSE
}

#' @rdname property_union
#' @param e1,e2 S7 classes or properties to union.
#' @examples
#' library(S7)
#' Piece := new_class(
#'   properties = list(id = class_string | property_range_discrete(1L, 6L))
#' )
#' Piece(3L)
#' @export
`|.S7_property` <- function(e1, e2) {
  property_union(e1, e2)
}

#' Create a property from an intersection of properties
#'
#' Requires a value to satisfy every member of `...`, unlike
#' [property_union()] which requires at least one. Every member must share
#' the same underlying class since a single value can't be an instance of
#' two different classes at once.
#'
#' @param ... S7 classes or properties to intersect.
#' @param default Any. Passed to [S7::new_property()].
#' @return An S7 property whose value must satisfy every member of `...`.
#' @examples
#' library(S7)
#' PieceColor <- property_intersection(
#'   property_scalar(S7::class_character),
#'   S7::new_property(
#'     S7::class_character,
#'     validator = function(value) {
#'       if (!(value %in% c("White", "Black"))) "must be White or Black"
#'     }
#'   )
#' )
#' Piece := new_class(properties = list(color = PieceColor))
#' Piece("White")
#' @export
property_intersection <- function(..., default = NULL) {
  members <- rlang::list2(...)
  if (length(members) == 0L) {
    cli::cli_abort("{.arg ...} must contain at least one class or property.")
  }

  classes <- lapply(
    members,
    function(m) if (inherits(m, "S7_property")) m$class else m
  )
  same_class <- vapply(classes, identical, logical(1), classes[[1]])
  if (!all(same_class)) {
    cli::cli_abort(
      "Every member of {.arg ...} must share the same underlying class."
    )
  }

  validators <- Filter(
    Negate(rlang::is_null),
    lapply(
      members,
      function(m) if (inherits(m, "S7_property")) m$validator else NULL
    )
  )

  S7::new_property(
    classes[[1]],
    validator = function(value) {
      for (validator_fn in validators) {
        message <- validator_fn(value)
        if (!rlang::is_null(message)) {
          return(message)
        }
      }
      NULL
    },
    default = default
  )
}

#' @rdname property_intersection
#' @param e1,e2 S7 classes or properties to intersect.
#' @examples
#' library(S7)
#' Piece := new_class(
#'   properties = list(
#'     id = property_scalar(S7::class_character) & S7::new_property(S7::class_character)
#'   )
#' )
#' Piece("a")
#' @export
`&.S7_property` <- function(e1, e2) {
  property_intersection(e1, e2)
}
