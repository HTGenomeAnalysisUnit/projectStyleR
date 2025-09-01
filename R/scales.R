#' Custom discrete color scale for ggplot2 plots
#'
#' Uses a predefined project palette loaded from a config file.
#' Falls back to ggsci if `palette` is "default".
#'
#' @param palette The name of the project palette to use (e.g., "primary", "vibrant").
#'   Defaults to "default", which uses `ggsci::scale_color_npg()`.
#' @param ... Additional arguments passed on to `ggplot2::scale_colour_manual` or `ggsci::scale_color_npg`.
#' @export
scale_color_project <- function(palette = "default", ...) {
  if (palette == "default") {
    return(ggsci::scale_color_npg(...))
  }
  
  project_palettes <- get_project_palettes() # Use the new helper function

  if (!palette %in% names(project_palettes)) {
    stop(paste("Palette not found. Available palettes are:", paste(names(project_palettes), collapse = ", ")))
  }
  
  pal <- project_palettes[[palette]]
  ggplot2::scale_colour_manual(values = pal, ...)
}


#' Custom discrete fill scale for ggplot2 plots
#'
#' Uses a predefined project palette loaded from a config file.
#' Falls back to ggsci if `palette` is "default".
#'
#' @param palette The name of the project palette to use (e.g., "primary", "vibrant").
#'   Defaults to "default", which uses `ggsci::scale_fill_npg()`.
#' @param ... Additional arguments passed on to `ggplot2::scale_fill_manual` or `ggsci::scale_fill_npg`.
#' @export
scale_fill_project <- function(palette = "default", ...) {
  if (palette == "default") {
    return(ggsci::scale_fill_npg(...))
  }
  
  project_palettes <- get_project_palettes() # Use the new helper function

  if (!palette %in% names(project_palettes)) {
    stop(paste("Palette not found. Available palettes are:", paste(names(project_palettes), collapse = ", ")))
  }
  
  pal <- project_palettes[[palette]]
  ggplot2::scale_fill_manual(values = pal, ...)
}
