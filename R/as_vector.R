#' Coerce an S7 object to a vector
#'
#' Returns a plain R vector representation of `x`, for which [is.vector()]
#' is `TRUE`: an atomic vector for scalar-backed classes, or a named list
#' of coerced properties for compound classes.
#'
#' @param x Any. Object to coerce.
#' @param ... Additional arguments passed to methods.
#' @return An atomic vector or a named list.
#' @examples
#' library(S7)
#' Point <- new_class(
#'   "Point",
#'   properties = list(x = class_double, y = class_double)
#' )
#' as_vector(Point(1, 2))
#' @export
as_vector <- S7::new_generic("as_vector", "x")

method(as_vector, S7::S7_object) <- function(x, ...) {
  nms <- S7::prop_names(x)
  values <- lapply(nms, function(nm) {
    as_vector_value(S7::prop(x, nm), ...)
  })
  rlang::set_names(values, nms)
}

as_vector_value <- function(value, ...) {
  if (S7::S7_inherits(value)) {
    as_vector(value, ...)
  } else if (rlang::is_list(value)) {
    lapply(value, as_vector_value, ...)
  } else {
    value
  }
}
