#' Coerce an S7 object to a vector
#'
#' Returns a plain R vector representation of `x`, for which [is.vector()]
#' is `TRUE`: an atomic vector for scalar-backed classes, or a named list
#' of coerced properties for compound classes. A list is coerced elementwise,
#' so a mixed structure of S7 objects and plain values converts in one call.
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

method(as_vector, S7::class_list) <- function(x, ...) {
  lapply(x, as_vector_value, ...)
}

# Without this the generic is partial: a classed object like a data frame or
# an AsIs vector has no method at all. as.list() is the general coercion to a
# form for which is.vector() holds.
method(as_vector, S7::class_any) <- function(x, ...) {
  as.list(x)
}

# is_bare_list(), not is_list(): a data frame is a list, and descending into
# one strips its class and flips it columnar.
as_vector_value <- function(value, ...) {
  if (S7::S7_inherits(value) || rlang::is_bare_list(value)) {
    as_vector(value, ...)
  } else {
    value
  }
}
