# This environment will store the loaded palettes within the package
.palette_env <- new.env(parent = emptyenv())

# This function runs automatically when the package is loaded
.onLoad <- function(libname, pkgname) {
  # Find the default palettes file inside the installed package
  default_palette_path <- system.file("palettes.yaml", package = pkgname)
  if (file.exists(default_palette_path)) {
    load_project_palettes(default_palette_path)
  }
}

#' Load project color palettes from a YAML file
#'
#' Reads a YAML file from a local path or a URL and sets it as the
#' active list of palettes for the sciplotR package.
#'
#' @param path A file path or a URL pointing to a valid .yaml file.
#' @export
#' @examples
#' \dontrun{
#' # Load from a local file
#' load_project_palettes("path/to/my_palettes.yaml")
#'
#' # Load from a file on GitHub
#' url <- "https://raw.githubusercontent.com/user/repo/main/custom_palettes.yaml"
#' load_project_palettes(url)
#' }
load_project_palettes <- function(path) {
  tryCatch({
    palettes <- yaml::read_yaml(path)
    
    # Basic validation of the file structure
    if (!is.list(palettes) || any(sapply(palettes, function(p) !is.character(p) || is.null(names(p))))) {
        stop("Palette file must be a YAML list where each entry is a named character vector of colors.")
    }
    
    .palette_env$palettes <- palettes
    message("Successfully loaded palettes from: ", basename(path))
    invisible(NULL)
  }, error = function(e) {
    warning("Failed to load palettes from: ", path, "\nError: ", e$message)
  })
}

#' Get the currently loaded project palettes
#'
#' Internal helper function to safely retrieve palettes from the environment.
#' @return A list of palettes.
#' @noRd
get_project_palettes <- function() {
  palettes <- .palette_env$palettes
  if (is.null(palettes)) {
    stop("No palettes loaded. Please use load_project_palettes() or reload the package.", call. = FALSE)
  }
  palettes
}

#' Load Project Themes from a YAML file
#'
#' @param path A file path or URL pointing to a valid YAML theme configuration file.
#' @export
load_project_themes <- function(path) {
  tryCatch({
    .palette_env$themes <- yaml::read_yaml(path)
    message("Successfully loaded themes from: ", path)
  }, error = function(e) {
    stop("Failed to load or parse the theme YAML file: ", e$message)
  })
}

#' Get the currently loaded project theme
#'
#' Internal helper function to safely retrieve themes from the environment.
#' @return A list of themes.
#' @noRd
get_project_themes <- function() {
  themes <- .palette_env$themes
  if (is.null(themes)) {
    stop("No themes loaded. Please use load_project_themes() or reload the package.", call. = FALSE)
  }
  themes
}
