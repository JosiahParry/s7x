#' @rdname as_vector
#' @export
from_vector <- S7::new_generic("from_vector", "x", function(x, class, ...) {
  S7::S7_dispatch()
})

method(from_vector, S7::class_list) <- function(x, class, ...) {
  convert_method <- rlang::try_fetch(
    S7::method(convert, list(S7::class_list, class)),
    error = function(e) NULL
  )
  if (!rlang::is_null(convert_method)) {
    return(convert_method(x, class, ...))
  }
  if (!inherits(class, "S7_class")) {
    return(x)
  }

  props <- class@properties
  unknown <- setdiff(names(x), names(props))
  if (length(unknown) > 0L) {
    cli::cli_abort(
      "{.arg x} has names that aren't properties of {.cls {class@name}}: {.val {unknown}}."
    )
  }

  nms <- intersect(names(x), names(props))
  args <- lapply(nms, function(nm) {
    value <- x[[nm]]
    element_class <- attr(props[[nm]], "element_class", exact = TRUE)
    if (rlang::is_null(value)) {
      value
    } else if (!rlang::is_null(element_class)) {
      lapply(value, from_vector, class = element_class, ...)
    } else {
      from_vector(value, props[[nm]]$class, ...)
    }
  })
  rlang::exec(class, !!!rlang::set_names(args, nms))
}

method(from_vector, S7::class_atomic) <- function(x, class, ...) {
  from <- switch(
    typeof(x),
    character = S7::class_character,
    double = S7::class_double,
    integer = S7::class_integer,
    logical = S7::class_logical
  )
  convert_method <- rlang::try_fetch(
    S7::method(convert, list(from, class)),
    error = function(e) NULL
  )
  if (!rlang::is_null(convert_method)) {
    return(convert_method(x, class, ...))
  }
  x
}

method(from_vector, S7::class_data.frame) <- function(x, class, ...) {
  from_vector(unclass(x), class, ...)
}
