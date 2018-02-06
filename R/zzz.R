#' @importFrom glue glue
.onLoad <- function(libname, pkgname) {
  path <- find.package('ouijaflow')
  if(!dir.exists(glue::glue("{path}/venv"))) {
    reinstall()
  }
}

#' @importFrom glue glue
reinstall <- function() {
  path <- find.package('ouijaflow')
  system(glue::glue("bash {path}/make {path}/venv"))
}
