#' Custom discrete color scale for ggplot2 plots
#'
#' Uses a predefined project palette. If a data value is not found in the
#' palette's names, it will be colored grey and a warning will be issued.
#'
#' @param palette The name of the project palette to use (e.g., "primary", "vibrant").
#'   Defaults to "default", which uses `ggsci::scale_color_npg()`.
#' @param unseen.color The color to use for data values not defined in the palette.
#' @param ... Additional arguments passed to `ggplot2::discrete_scale`.
#' @export
scale_color_project <- function(palette = "default", unseen.color = "#B3B3B3", ...) {
  palettes <- get_project_palettes() 
  if (palette == "default" && is.null(palettes[["default"]])) {
    return(ggsci::scale_color_npg(...))
  }
  
  pal <- palettes[[palette]]
  if (is.null(pal)) {
    stop(paste("Palette '", palette, "' not found."), call. = FALSE)
  }

  # Use scale_colour_manual, and uses na.value for anything not in the palette's names.
  ggplot2::scale_colour_manual(values = pal, na.value = unseen.color, ...)
}

#' Custom discrete fill scale for ggplot2 plots
#'
#' Uses a predefined project palette. If a data value is not found in the
#' palette's names, it will be colored grey and a warning will be issued.
#'
#' @param palette The name of the project palette to use (e.g., "primary", "vibrant").
#' @param unseen.color The color to use for data values not defined in the palette.
#' @param ... Additional arguments passed to `ggplot2::discrete_scale`.
#' @export
scale_fill_project <- function(palette = "default", unseen.color = "#B3B3B3", ...) {
  palettes <- get_project_palettes() 
  if (palette == "default" && is.null(palettes[["default"]])) {
    return(ggsci::scale_fill_npg(...))
  }

  pal <- palettes[[palette]]
  if (is.null(pal)) {
    stop(paste("Palette '", palette, "' not found."), call. = FALSE)
  }

  # Use scale_colour_manual, and uses na.value for anything not in the palette's names.
  ggplot2::scale_fill_manual(values = pal, na.value = unseen.color, ...)
}


# --- CONTINUOUS SCALES ---

#' Custom continuous color scale for ggplot2 plots
#'
#' Creates a color gradient from a predefined project palette.
#'
#' @param palette The name of the project palette to use (e.g., "npg_continuous").
#' @param ... Additional arguments passed to `ggplot2::scale_color_gradientn`.
#' @export
scale_color_project_c <- function(palette = "default", ...) {
  palettes <- get_project_palettes() 
  if (palette == "default" && is.null(palettes[["default"]])) {
    return(ggsci::scale_color_gsea(...))
  }

  pal <- palettes[[palette]]
  if (is.null(pal)) {
    stop(paste("Palette '", palette, "' not found."), call. = FALSE)
  }
  
  ggplot2::scale_color_gradientn(colors = unname(pal), ...)
}

#' Custom continuous fill scale for ggplot2 plots
#'
#' Creates a fill gradient from a predefined project palette.
#'
#' @param palette The name of the project palette to use (e.g., "npg_continuous").
#' @param ... Additional arguments passed to `ggplot2::scale_fill_gradientn`.
#' @export
scale_fill_project_c <- function(palette = "default", ...) {
  palettes <- get_project_palettes() 
  if (palette == "default" && is.null(palettes[["default"]])) {
    return(ggsci::scale_fill_gsea(...))
  }

  pal <- palettes[[palette]]
  if (is.null(pal)) {
    stop(paste("Palette '", palette, "' not found."), call. = FALSE)
  }
  
  ggplot2::scale_fill_gradientn(colors = unname(pal), ...)
}

