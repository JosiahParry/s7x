#' Convert S7 objects to and from vectors
#'
#' Takes an S7 object and coerces it to the appropriate vector container type.
#' `from_vector()` builds an instance of `class` from a vector. Both are S7
#' generics which can be implemented for any custom types.
#'
#' @details
#' `as_vector()` returns:
#'
#' - `S7_object`: a named list of its coerced properties.
#' - `Enum`: its value as a string.
#' - `list`: a list with each S7 object or bare list element coerced. It leaves
#'   other elements, such as data frames, unchanged.
#' - Falls back to use [as.list()].
#'
#' `from_vector()` builds `class` from the properties in `x`. It returns atomic
#' vectors unchanged and unclasses data frames first.
#'
#' @param x Any. Object to convert.
#' @param class S7 class spec. Class to build.
#' @param ... Additional arguments passed to methods.
#' @return `as_vector()` returns an atomic vector or a named list.
#'   `from_vector()` returns an instance of `class`, or `x` unchanged.
#' @examples
#' library(S7)
#' Point <- new_class(
#'   "Point",
#'   properties = list(x = class_float, y = class_float)
#' )
#' v <- as_vector(Point(1, 2))
#' v
#' from_vector(v, Point)
#' @export
as_vector <- S7::new_generic("as_vector", "x")

method(as_vector, S7::S7_object) <- function(x, ...) {
  nms <- names(attr(S7::S7_class(x), "properties", exact = TRUE))
  if (rlang::is_null(nms)) {
    nms <- character()
  }
  values <- lapply(nms, function(nm) as_vector_value(S7::prop(x, nm), ...))
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
  if (inherits(value, "S7_object") || rlang::is_bare_list(value)) {
    as_vector(value, ...)
  } else {
    value
  }
}
