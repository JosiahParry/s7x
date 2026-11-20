#' Document enums and S7 classes
#'
#' Use `enum_roclet()` to generate the docs of exported [new_enum()] and S7
#' classes from their definitions.
#'
#' @return A roxygen2 roclet.
#' @details
#' Enable it in your package's `DESCRIPTION`:
#'
#' ```
#' Roxygen: list(markdown = TRUE, roclets = c("collate", "namespace", "s7x::enum_roclet"))
#' ```
#'
#' You get each of these that you don't write yourself:
#'
#' - An enum on its own page: the title, description, `value` param,
#'   `variants` and `allow_na` properties, returns and an example.
#' - Enums that share a page through `@rdname`: the `value` param and a
#'   Variants section that lists each enum's values.
#' - An S7 class on its own page: a `@param` with the type of each property.
#' @examplesIf rlang::is_installed("roxygen2")
#' enum_roclet()
#' @export
enum_roclet <- function() {
  roxygen2::roclet(c("enum", "rd"))
}

#' @rawNamespace S3method(roxygen2::roclet_process, roclet_enum)
roclet_process.roclet_enum <- function(x, blocks, env, base_path) {
  rdnames <- vapply(
    blocks,
    function(block) {
      if (block_is_enum(block) && roxygen2::block_has_tags(block, "rdname")) {
        roxygen2::block_get_tag_value(block, "rdname")
      } else {
        NA_character_
      }
    },
    character(1)
  )

  own_page <- is.na(rdnames)
  blocks[own_page] <- lapply(blocks[own_page], block_add_enum_tags)

  for (rdname in unique(rdnames[!own_page])) {
    idx <- which(rdnames == rdname)
    bullets <- vapply(
      blocks[idx],
      function(block) {
        cls <- block$object$value
        paste0("- `", cls@name, "`: ", sub("^One", "one", enum_one_of(cls)))
      },
      character(1)
    )
    generated <- list(list(
      tag = "section",
      raw = paste0("Variants:\n\n", paste(bullets, collapse = "\n"))
    ))

    on_page <- vapply(
      blocks,
      function(block) {
        identical(roxygen2::block_get_tag_value(block, "rdname"), rdname) ||
          identical(roxygen2::block_get_tag_value(block, "name"), rdname)
      },
      logical(1)
    )
    if (!"value" %in% unlist(lapply(blocks[on_page], block_param_names))) {
      generated <- c(
        generated,
        list(list(
          tag = "param",
          raw = "value a scalar character. One of the class's variants."
        ))
      )
    }

    first <- idx[[1]]
    blocks[[first]]$tags <- c(
      blocks[[first]]$tags,
      lapply(generated, parse_tag)
    )
  }

  own_class_page <- !vapply(
    blocks,
    function(block) roxygen2::block_has_tags(block, "rdname"),
    logical(1)
  )
  blocks[own_class_page] <- lapply(blocks[own_class_page], block_add_class_tags)
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
    param = list(
      tag = "param",
      raw = paste("value a scalar character.", one_of)
    ),
    prop_variants = list(
      tag = "prop",
      raw = "variants a character vector. The values this enum allows."
    ),
    prop_allow_na = list(
      tag = "prop",
      raw = "allow_na a scalar logical. Whether the enum allows \\code{NA_character_}."
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

  documented <- block_param_names(block)
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

# A `@param x,y` tag documents both `x` and `y`.
block_param_names <- function(block) {
  unlist(lapply(
    Filter(function(tag) tag$tag == "param", block$tags),
    function(tag) trimws(strsplit(tag$val$name, ",")[[1]])
  ))
}

# One sentence naming the property's type, which is all the class itself knows.
prop_description <- function(prop) {
  cls <- prop$class
  scalar <- isTRUE(attr(prop, "scalar", exact = TRUE))
  if (rlang::is_null(cls)) {
    return("any value.")
  }
  if (inherits(cls, "S7_union")) {
    parts <- vapply(cls$classes, prop_label, character(1), scalar = scalar)
    return(paste0(paste(parts, collapse = " or "), "."))
  }
  paste0(prop_label(cls, scalar), ".")
}

scalar_labels <- c(
  character = "a scalar character",
  double = "a scalar numeric",
  integer = "a scalar integer",
  numeric = "a scalar numeric",
  logical = "a scalar logical",
  list = "a list"
)

vector_labels <- c(
  character = "a character vector",
  double = "a numeric vector",
  integer = "an integer vector",
  numeric = "a numeric vector",
  logical = "a logical vector",
  list = "a list"
)

prop_label <- function(cls, scalar = FALSE) {
  if (rlang::is_null(cls)) {
    return("`NULL`")
  }
  if (inherits(cls, "S7_base_class")) {
    if (scalar) {
      labels <- scalar_labels
    } else {
      labels <- vector_labels
    }
    return(unname(labels[cls$class] %|NA|% "any value"))
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
