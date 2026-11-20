#' Array property
#'
#' An array is a list of values that all share one class.
#'
#' @param class S7 class spec. Class of every element.
#' @param default Any. Passed to [S7::new_property()].
#' @return An S7 property whose value must be a list of `class`.
#' @examples
#' library(S7)
#' Point <- new_class("Point", properties = list(x = class_float))
#' Path <- new_class("Path", properties = list(points = property_array(Point)))
#' Path(list(Point(1), Point(2)))
#' @export
property_array <- function(class, default = rlang::expr(list())) {
  prop <- S7::new_property(
    S7::class_list,
    validator = function(value) {
      bad <- which(!vapply(value, class_matches, logical(1), class = class))
      if (length(bad) > 0L) {
        cli::format_inline("elements {.val {bad}} have the wrong class")
      }
    },
    default = default
  )
  attr(prop, "element_class") <- class
  prop
}
