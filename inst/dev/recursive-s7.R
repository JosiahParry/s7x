# Repro: as_vector() was slow on large objects.
#
# It runs a check on every node. It used S7::S7_inherits() and
# S7::prop_names(), which call S7:::as_class(). as_class() builds its error
# message with sprintf() and deparse(substitute(x)) before it checks
# anything, so every call pays ~15us even on success. prop_names() pays
# twice, via check_is_S7().
#
# Run from the package root: Rscript inst/dev/recursive-s7.R

pkgload::load_all(quiet = TRUE)

per_call_us <- function(f, n = 2e4) {
  elapsed <- system.time(for (i in seq_len(n)) f())[["elapsed"]]
  round(elapsed / n * 1e6, 2)
}

Point <- S7::new_class(
  "Point",
  properties = list(x = class_float, y = class_float)
)

p <- Point(1, 2)
x <- 1.5

# 1. Per-call cost of each check -----------------------------------------
data.frame(
  call = c(
    "S7::S7_inherits(x)",
    "is_s7_object(x)",
    "S7::prop_names(p)",
    "s7_prop_names(p)",
    "S7:::as_class(NULL)"
  ),
  us = c(
    per_call_us(function() S7::S7_inherits(x)),
    per_call_us(function() is_s7_object(x)),
    per_call_us(function() S7::prop_names(p)),
    per_call_us(function() s7_prop_names(p)),
    per_call_us(function() S7:::as_class(NULL))
  )
)

# 2. as_vector() on large inputs, old checks vs new ------------------------
old_as_vector <- function(x) {
  if (S7::S7_inherits(x)) {
    nms <- S7::prop_names(x)
    rlang::set_names(lapply(nms, function(nm) old_value(S7::prop(x, nm))), nms)
  } else {
    lapply(x, old_value)
  }
}
old_value <- function(value) {
  if (S7::S7_inherits(value) || rlang::is_bare_list(value)) {
    old_as_vector(value)
  } else {
    value
  }
}

n <- 2e4
pts <- lapply(seq_len(n), function(i) Point(as.double(i), as.double(i)))
dbls <- as.list(runif(n))

stopifnot(identical(old_as_vector(pts), as_vector(pts)))
stopifnot(identical(old_as_vector(dbls), as_vector(dbls)))

data.frame(
  input = c("20k Points", "20k doubles"),
  old_s = c(
    system.time(old_as_vector(pts))[["elapsed"]],
    system.time(old_as_vector(dbls))[["elapsed"]]
  ),
  new_s = c(
    system.time(as_vector(pts))[["elapsed"]],
    system.time(as_vector(dbls))[["elapsed"]]
  )
)
