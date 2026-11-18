#' Coerce an S7 object to a JSON string
#'
#' Serializes `x` to JSON by coercing it with [as_vector()] first.
#'
#' @param x Any. Object to serialize.
#' @param ... Additional arguments passed to `yyjsonr::write_json_str()`.
#' @return A string containing JSON.
#' @details The `S7_object` method also takes `pretty`, a bool that
#' pretty-prints the JSON output.
#' @include as_vector.R
#' @examples
#' library(S7)
#' Point <- new_class(
#'   "Point",
#'   properties = list(x = class_float, y = class_float)
#' )
#' to_json(Point(1, 2))
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
