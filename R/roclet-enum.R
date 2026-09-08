#' Roclet that documents enum and S7 classes
#'
#' Fills in the title, description, `value` argument, and properties of every
#' exported [new_enum()] class from the class itself, and gives every exported
#' S7 class one `@param` per property. Extends roxygen2's `rd` roclet, so it
#' replaces `"rd"` rather than running alongside it.
#'
#' @return A roxygen2 roclet.
#' @details
#' Enable it in the `DESCRIPTION` of the package being documented:
#'
#' ```
#' Roxygen: list(markdown = TRUE, roclets = c("collate", "namespace", "s7x::enum_roclet"))
#' ```
#'
#' Any tag written by hand wins. A block with its own title keeps that title,
#' and only the missing pieces are generated.
#' @examples
#' enum_roclet()
#' @export
enum_roclet <- function() {
  roxygen2::roclet(c("enum", "rd"))
}

#' @rawNamespace S3method(roxygen2::roclet_process, roclet_enum)
roclet_process.roclet_enum <- function(x, blocks, env, base_path) {
  blocks <- lapply(blocks, block_add_enum_tags)
  blocks <- lapply(blocks, block_add_class_tags)
  NextMethod()
}

# The block's object is only attached once roxygen2 has evaluated the package,
# which `roclet_process()` is guaranteed to run after.
block_is_enum <- function(block) {
  object <- block$object
  !rlang::is_null(object) && is_enum_class(object$value)
}

# Append the generated tags this block doesn't already carry, so anything
# written by hand takes precedence.
block_add_enum_tags <- function(block) {
  if (!block_is_enum(block)) {
    return(block)
  }

  present <- vapply(block$tags, function(tag) tag$tag, character(1))
  generated <- enum_tags(block$object$value)
  tags <- vapply(generated, function(x) x$tag, character(1))

  block$tags <- c(
    block$tags,
    unname(lapply(generated[!tags %in% present], parse_tag))
  )
  block
}

parse_tag <- function(x) {
  roxygen2::roxy_tag_parse(roxygen2::roxy_tag(x$tag, x$raw))
}

# The tag name to raw-content pairs describing an enum class. Named by tag so
# a block that already has one can drop it.
enum_tags <- function(x) {
  one_of <- enum_one_of(x)

  list(
    title = list(tag = "title", raw = x@name),
    description = list(tag = "description", raw = one_of),
    param = list(tag = "param", raw = paste("value String.", one_of)),
    prop_variants = list(
      tag = "prop",
      raw = "variants Character vector. The values this enum allows."
    ),
    prop_allow_na = list(
      tag = "prop",
      raw = "allow_na Bool. Whether \\code{NA_character_} is allowed."
    ),
    value = list(
      tag = "returns",
      raw = paste0("An object of class \\code{", x@name, "}.")
    ),
    examples = list(tag = "examples", raw = enum_example(x))
  )
}

# A property's default, read off the class generator rather than an instance.
# S7 only accepts a scalar or a quoted call as a `default`, so `variants` is
# stored as a promise and has to be evaluated in the constructor's environment.
enum_default <- function(x, name) {
  default <- x@properties[[name]]$default
  if (rlang::is_symbol(default) || rlang::is_call(default)) {
    eval(default, environment(x@constructor))
  } else {
    default
  }
}

# CRAN requires an example on every exported object, and an enum's only
# meaningful one is constructing it. The first variant stands for the rest.
enum_example <- function(x) {
  variants <- enum_default(x, "variants")
  if (rlang::is_empty(variants)) {
    return(paste0(x@name, "()"))
  }
  paste0(x@name, "(\"", variants[[1]], "\")")
}

# A sentence listing the variants, e.g. `"a"`, `"b"`, or `NA`.
enum_one_of <- function(x) {
  variants <- paste0("\\code{\"", enum_default(x, "variants"), "\"}")
  if (isTRUE(enum_default(x, "allow_na"))) {
    variants <- c(variants, "\\code{NA}")
  }
  paste0("One of ", paste(variants, collapse = ", "), ".")
}

# A class generator's arguments are its properties, and `usage` only exists
# when roxygen2 recognized the assignment - so `:=` classes are skipped.
block_is_class <- function(block) {
  object <- block$object
  !rlang::is_null(object) &&
    inherits(object$value, "S7_class") &&
    !is_enum_class(object$value)
}

block_add_class_tags <- function(block) {
  if (!block_is_class(block)) {
    return(block)
  }

  documented <- vapply(
    Filter(function(tag) tag$tag == "param", block$tags),
    function(tag) names(tag$val)[[1]],
    character(1)
  )
  # A computed property has no constructor argument, so documenting it would
  # trade one warning for the opposite one.
  props <- block$object$value@properties
  args <- names(formals(block$object$value@constructor))
  missing <- setdiff(intersect(names(props), args), documented)

  block$tags <- c(
    block$tags,
    unname(lapply(missing, function(nm) {
      parse_tag(list(
        tag = "param",
        raw = paste(nm, prop_description(props[[nm]]))
      ))
    }))
  )
  block
}

# One sentence naming the property's type, which is all the class itself knows.
prop_description <- function(prop) {
  cls <- prop$class
  if (rlang::is_null(cls)) {
    return("Any value.")
  }
  if (inherits(cls, "S7_union")) {
    parts <- vapply(cls$classes, prop_label, character(1))
    return(sentence(paste(parts, collapse = " or ")))
  }
  sentence(prop_label(cls))
}

sentence <- function(x) {
  paste0(toupper(substr(x, 1, 1)), substr(x, 2, nchar(x)), ".")
}

base_labels <- c(
  character = "String",
  double = "Number",
  integer = "Number",
  numeric = "Number",
  logical = "Bool",
  list = "List"
)

prop_label <- function(cls) {
  if (rlang::is_null(cls)) {
    return("`NULL`")
  }
  if (inherits(cls, "S7_base_class")) {
    base <- cls$class
    return(unname(base_labels[base] %|NA|% "Any value"))
  }
  if (is_enum_class(cls)) {
    return(paste0("a `", cls@name, "` enum"))
  }
  if (inherits(cls, "S7_class")) {
    return(paste0("a `", cls@name, "` object"))
  }
  "any value"
}

`%|NA|%` <- function(x, y) if (is.na(x)) y else x
