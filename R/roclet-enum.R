#' Roclet that documents enum classes
#'
#' Fills in the title, description, `value` argument, and properties of every
#' exported [new_enum()] class from the class itself. Extends roxygen2's `rd`
#' roclet, so it replaces `"rd"` rather than running alongside it.
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
    )
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

# A sentence listing the variants, e.g. `"a"`, `"b"`, or `NA`.
enum_one_of <- function(x) {
  variants <- paste0("\\code{\"", enum_default(x, "variants"), "\"}")
  if (isTRUE(enum_default(x, "allow_na"))) {
    variants <- c(variants, "\\code{NA}")
  }
  paste0("One of ", paste(variants, collapse = ", "), ".")
}
