# This environment will store the loaded palettes within the package
.palette_env <- new.env(parent = emptyenv())

# This function runs automatically when the package is loaded
.onLoad <- function(libname, pkgname) {
  # Find the default palettes file inside the installed package
  default_palette_path <- system.file("palettes.yaml", package = pkgname)
  if (file.exists(default_palette_path)) {
    load_project_palettes(default_palette_path)
  }
  # Find the default themes file inside the installed package
  default_theme_path <- system.file("themes.yaml", package = pkgname)
  if (file.exists(default_theme_path)) {
    load_project_themes(default_theme_path)
  }
}

#' Load project color palettes from a YAML file or URL
#'
#' Reads a YAML file from a local path or a URL and sets it as the
#' active list of palettes for the sciplotR package.
#'
#' @param path A file path or a URL pointing to a valid .yaml file.
#' @param github_pat A GitHub Personal Access Token (PAT) for accessing private repositories.
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
load_project_palettes <- function(path, github_pat) {
  content <- .fetch_config_content(path, github_pat)
  tryCatch({
    palettes <- yaml::read_yaml(text = content)
        
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

#' Load Project Themes from a YAML file or URL
#'
#' @param path A file path or URL pointing to a valid YAML theme configuration file.
#' @param github_pat A GitHub Personal Access Token (PAT) for accessing private repositories.
#' @export
load_project_themes <- function(path, github_pat = NULL, github_pat_fonts = NULL) {
  content <- .fetch_config_content(path, github_pat)
  tryCatch({
    .palette_env$themes <- yaml::read_yaml(text = content)
    message("Successfully loaded themes from: ", path)
  }, error = function(e) {
    stop("Failed to load or parse the theme YAML file: ", e$message)
  })

  # Download and register any custom fonts specified in the themes
  tryCatch({
    pat_for_fonts <- if (!is.null(github_pat_fonts)) {
      if (tolower(github_pat_fonts) == "none") NULL else github_pat_fonts
    } else {
      github_pat
    }
    
    # Iterate through each theme to find font definitions
    for (theme_name in names(.palette_env$themes)) {
      theme <- .palette_env$themes[[theme_name]]
      if (!is.null(theme$fonts) && is.list(theme$fonts)) {
        message("Processing custom fonts for theme: '", theme_name, "'")
        # For each font family (e.g., "Open Sans")
        for (font_family in names(theme$fonts)) {
          .process_font_family(font_family, theme$fonts[[font_family]], pat_for_fonts)
        }
      }
    }
    message("Successfully loaded custom fonts specified in themes.")
  }, error = function(e) {
    stop("Failed to load or process custom fonts: ", e$message)
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

#' Log a list of available palettes
#'
#' @export
available_palettes <- function() {
  palettes <- get_project_palettes()
  message("Available palettes:")
  for (name in names(palettes)) {
    message(" - ", name)
  }
}

#' Log a list of available themes
#'
#' @export
available_themes <- function() {
  themes <- get_project_themes()
  message("Available themes:")
  for (name in names(themes)) {
    message(" - ", name)
  }
}

#' Internal helper to fetch content from local path or URL
#' @noRd
.fetch_config_content <- function(path, github_pat = NULL) {
  # Check if the path is a URL
  if (grepl("^https?://", path)) {
    headers <- NULL
    # If it's a GitHub URL and a PAT is provided, create an auth header
    if ((grepl("raw\\.githubusercontent\\.com", path) || grepl("github\\.com", path)) && !is.null(github_pat)) {
      headers <- httr::add_headers(Authorization = paste("token", github_pat))
      message("Using GitHub PAT for authenticated access.")
    }

    response <- httr::GET(path, config = headers)
    httr::stop_for_status(response, task = "fetch remote configuration file")
    return(httr::content(response, "text", encoding = "UTF-8"))

  } else {
    # It's a local file path
    if (!file.exists(path)) {
      stop("Local configuration file not found at: ", path)
    }
    return(readLines(path, warn = FALSE, encoding = "UTF-8"))
  }
}

#' Processes a list of font files for a given family
#' @noRd
.process_font_family <- function(family, files, pat) {
  font_paths <- list()
  
  # Download and categorize each font file
  for (file_path in files) {
    local_path <- .fetch_font_file(file_path, pat)
    if (!is.null(local_path)) {
      # Guess style from filename
      if (grepl("bolditalic|bold_italic|bold-italic|boldoblique|bold_oblique|bold-oblique", file_path, ignore.case = TRUE)) {
        font_paths$bolditalic <- local_path
      } else if (grepl("italic|oblique", file_path, ignore.case = TRUE)) {
        font_paths$italic <- local_path
      } else if (grepl("bold", file_path, ignore.case = TRUE)) {
        font_paths$bold <- local_path
      } else {
        font_paths$regular <- local_path
      }
    }
  }
  
  if (length(font_paths) > 0) {
    message("  Registering font family: '", family, "' with ", paste(names(font_paths), collapse=", "))
    do.call(sysfonts::font_add, c(list(family = family), font_paths))
  }
}

#' Fetches a single font file from a URL or local path
#' @noRd
.fetch_font_file <- function(path, pat) {
  tmp_file <- tempfile(fileext = paste0(".", tools::file_ext(path)))
  
  tryCatch({
    if (grepl("^https?://", path)) {
      headers <- NULL
      if ((grepl("raw\\.githubusercontent\\.com", path) || grepl("github\\.com", path)) && !is.null(pat)) {
        headers <- add_headers(Authorization = paste("token", pat))
      }
      response <- GET(path, config = headers, write_disk(tmp_file, overwrite = TRUE))
      stop_for_status(response, task = paste("download font from", path))
    } else {
      if (!file.exists(path)) {
        warning("Local font file not found: ", path)
        return(NULL)
      }
      file.copy(path, tmp_file, overwrite = TRUE)
    }
    return(tmp_file)
  }, error = function(e) {
    warning("Failed to fetch font file '", path, "': ", e$message)
    return(NULL)
  })
}
