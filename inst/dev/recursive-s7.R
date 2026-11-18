Point <- S7::new_class(
  "Point",
  properties = list(x = S7::class_double, y = S7::class_double)
)

p <- Point(1, 2)
x <- 1.5

bench::mark(
  S7::S7_inherits(x),
  inherits(x, "S7_object"),
  S7::prop_names(p),
  names(attr(S7::S7_class(p), "properties")),
  S7:::as_class(NULL),
  check = FALSE
)

s7_inherits_recursive <- function(x) {
  if (S7::S7_inherits(x)) {
    nms <- S7::prop_names(x)
    values <- lapply(nms, function(nm) {
      s7_inherits_recursive(S7::prop(x, nm))
    })
    rlang::set_names(values, nms)
  } else if (rlang::is_bare_list(x)) {
    lapply(x, s7_inherits_recursive)
  } else {
    x
  }
}

manual_s7_comparisons <- function(x) {
  if (inherits(x, "S7_object")) {
    nms <- names(attr(S7::S7_class(x), "properties", exact = TRUE))
    if (rlang::is_null(nms)) {
      nms <- character()
    }
    values <- lapply(nms, function(nm) {
      manual_s7_comparisons(S7::prop(x, nm))
    })
    rlang::set_names(values, nms)
  } else if (rlang::is_bare_list(x)) {
    lapply(x, manual_s7_comparisons)
  } else {
    x
  }
}

bench::press(
  n = c(1e3, 1e4),
  {
    obj <- lapply(seq_len(n), function(i) Point(as.double(i), as.double(i)))
    bench::mark(
      s7_inherits_recursive = s7_inherits_recursive(obj),
      manual_s7_comparisons = manual_s7_comparisons(obj),
      min_iterations = 5
    )
  }
)
