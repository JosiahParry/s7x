#' Convert S7 objects to and from JSON
#'
#' `to_json()` serializes `x` with [as_vector()]. `from_json()` parses `json`
#' and builds `class` with [from_vector()].
#'
#' @param x Any. Object to serialize.
#' @param ... Additional arguments passed to methods.
#' @return `to_json()` returns a string of JSON. `from_json()` returns an
#'   instance of `class`, or a list of them for a JSON array.
#' @details Set `pretty = TRUE` to pretty-print the JSON.
#' @include as_vector.R
#' @examples
#' library(S7)
#' Point <- new_class(
#'   "Point",
#'   properties = list(x = class_float, y = class_float)
#' )
#' json <- to_json(Point(1, 2))
#' json
#' from_json(json, Point)
#' @export
to_json <- S7::new_generic("to_json", "x")

method(to_json, S7::S7_object) <- function(x, ..., pretty = FALSE) {
  yyjsonr::write_json_str(
    as_vector(x),
    auto_unbox = TRUE,
    pretty = pretty,
    ...
  )
}

#' @rdname to_json
#' @param json String. JSON to parse.
#' @param class S7 class spec. Class to build.
#' @export
from_json <- S7::new_generic("from_json", "json", function(json, class, ...) {
  S7::S7_dispatch()
})

method(from_json, S7::class_character) <- function(json, class, ...) {
  check_string(json)
  value <- yyjsonr::read_json_str(
    json,
    opts = yyjsonr::opts_read_json(
      obj_of_arrs_to_df = FALSE,
      arr_of_objs_to_df = FALSE
    )
  )
  if (rlang::is_named(value)) {
    return(from_vector(value, class, ...))
  }
  lapply(value, from_vector, class = class, ...)
}
