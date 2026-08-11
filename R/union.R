#' Define a property backed by a class union
#'
#' The property-level accompaniment to [S7::new_union()]. `...` may be
#' plain S7 classes or properties (like [property_scalar()] or
#' [property_range()]); a property member's own validator still applies to
#' values matching its class.
#'
#' @param ... S7 classes or properties to union.
#' @param default Any. Passed to [S7::new_property()].
#' @return An S7 property typed as the union of `...`.
#' @export
property_union <- function(..., default = NULL) {
  members <- list(...)
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
          if (!S7::S7_inherits(value, classes[[i]])) {
            return(NA)
          }
          validator <- member_validator(members[[i]])
          if (is.null(validator)) TRUE else is.null(validator(value))
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

#' @rdname property_union
#' @param e1,e2 S7 classes or properties to union.
#' @export
`|.S7_property` <- function(e1, e2) {
  property_union(e1, e2)
}
