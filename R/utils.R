# The name of the package whose namespace `env` belongs to, or `NULL` if
# `env` isn't inside a package (e.g. a plain script or the global env).
# Mirrors S7's internal `topNamespaceName()`, used to detect the caller's
# package so `new_*_class()` helpers can attribute classes the same way
# `S7::new_class()` would if called directly.
topenv_package_name <- function(env) {
  env <- topenv(env)
  if (!isNamespace(env)) {
    return(NULL)
  }
  as.character(getNamespaceName(env))
}
