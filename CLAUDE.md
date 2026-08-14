# CLAUDE.md

## Coding Standards

- Never use [`do.call()`](https://rdrr.io/r/base/do.call.html)
- Never use nested for loops

### The em dash rule

**`–` (space–en/em dash–space) is banned in all code, strings, and
documentation.**

### Parameter documentation

**Never duplicate parameter docs.** Always use `@inheritParams` pointing
to a function that already documents those parameters:

### Documentation style

**Be ruthlessly concise.** Max two sentences per block
(title/description, `@param`, `@return`). No `;`. No em dash (see
above). State what a thing does, not what it doesn’t do or every edge
case — put that in `@details` instead.

`@param` lines follow this structure, where `{...}` is a placeholder for
the actual type/value (not literal braces):

    @param name Value type. Concise definition.

Example: `@param name String. Name of the new class.`

### Parameter validation

**Always use rlang standalone checks** for every parameter in a
function. These are imported via `R/import-standalone-types-check.R`:

``` r

check_string(x, allow_empty = FALSE)
check_bool(x)
check_number_whole(x, min = 1, max = 100)
check_number_decimal(x)
check_character(x, allow_null = TRUE)
check_data_frame(x)
check_function(x)
```

### Error messages

Use [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
with `call = error_call` (or `call = rlang::caller_env()`). Use cli
inline markup: `{.arg x}`, `{.cls ClassName}`, `{.fn function_name}`,
`{.val value}`, `{.code expr}`.

**S7 validator messages** (the string returned from a class
`validator = function(self) {...}`) don’t go through `cli_abort()` since
S7 pastes them as bullets verbatim. Build them with
[`cli::format_inline()`](https://cli.r-lib.org/reference/format_inline.html)
instead of
[`sprintf()`](https://rdrr.io/r/base/sprintf.html)/[`paste()`](https://rdrr.io/r/base/paste.html),
using the same inline markup, e.g.:

``` r

cli::format_inline("@value must be one of {.val {self@variants}}")
```

### Base R vs rlang

Prefer the rlang equivalent of a base R function when one exists. In
particular, use
[`rlang::expr()`](https://rlang.r-lib.org/reference/expr.html) instead
of [`quote()`](https://rdrr.io/r/base/substitute.html) for capturing
unevaluated expressions
(e.g. [`S7::new_property()`](https://rconsortium.github.io/S7/reference/new_property.html)
promise defaults).

### Changelog

**Always update `NEWS.md`** with a bullet describing what changed.
Follow the existing format (version headers, plain bullet points).

### Version bumping

Use `usethis::use_version()` to increment the version. Do not edit
`DESCRIPTION` manually.

## Context

The S7 R package is at `../` do not modify it. But use it as a
reference.
