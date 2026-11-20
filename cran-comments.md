## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new release.
* "Namespaces in Imports field not imported from: 'utils' 'yyjsonr'". s7x
  calls both with `::`. The `yyjsonr` calls sit inside S7 method bodies, and
  `utils::globalVariables()` runs at the top level, so the check can't see
  them.
