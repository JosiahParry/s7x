#' Create Property from a Union of Properties
#'
#' An analogue to [S7::new_union()]. Defines a new property
#' from multiple
#'
#' @param ... S7 classes or properties to union.
#' @param default Any. Passed to [S7::new_property()].
#' @return An S7 property typed as the union of `...`.
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

  S7::new_property(
    Reduce(`|`, classes),
    validator = function(value) {
      matches <- vapply(
        seq_along(members),
        function(i) {
          if (!class_matches(value, classes[[i]])) {
            return(NA)
          }
          validator <- member_validator(members[[i]])
          if (is_null(validator)) {
            TRUE
          } else {
            is_null(validator(value))
          }
        },
        logical(1)
      )
      matches <- matches[!is.na(matches)]
      if (length(matches) > 0 && !any(matches)) {
        "does not satisfy any member of the union"
      }
    },
    default = default
  )
}

# Whether `value` is an instance of `class`, a class spec accepted by
# S7::new_union() (S7 class, union, or base type). S7_inherits() only
# accepts S7 classes, not unions or base type specs, so this dispatches on
# structural shape instead: a function is an S7 class, a list with
# `$classes` is a union, a list with `$class` is a base type.
class_matches <- function(value, class) {
  if (is_function(class)) {
    return(S7::S7_inherits(value, class))
  }

  if (is_list(class) && !is_null(class$classes)) {
    return(any(vapply(class$classes, class_matches, logical(1), value = value)))
  }

  if (is.list(class) && !is.null(class$class)) {
    return(identical(typeof(value), class$class))
  }

  FALSE
}

#' @rdname property_union
#' @param e1,e2 S7 classes or properties to union.
#' @export
`|.S7_property` <- function(e1, e2) {
  property_union(e1, e2)
}
