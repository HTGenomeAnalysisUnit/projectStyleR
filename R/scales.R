#' Creates a custom palette function for use with ggplot2 scales.
#'
#' This is a function factory. It takes a palette name and returns a new
#' function that ggplot2 can use to map data levels to colors. This allows
#' us to intercept the data levels, check for missing values, and assign a
#' default color.
#'
#' @param palette_name The name of the project palette (e.g., "primary").
#' @param unseen_color The hex code for the color to apply to unseen levels.
#' @return A function that takes a vector of data levels and returns a
#'   corresponding vector of color hex codes.
#' @noRd
create_project_paletter <- function(palette_name, unseen_color = "#B3B3B3") { # A medium grey
  
  # 1. Get the actual named vector of colors for the chosen palette
  project_palette <- get_project_palettes()[[palette_name]]
  
  if (is.null(project_palette)) {
    stop(paste("Palette '", palette_name, "' not found."), call. = FALSE)
  }

  # 2. Return a new function (a closure). This is what ggplot will call.
  function(data_levels) {
    warning("Data levels: ", paste(data_levels, collapse = ", "))
    # 3. Identify which data levels don't have a color in our palette
    unseen_levels <- setdiff(data_levels, names(project_palette))
    
    # 4. Issue a warning if there are any unseen levels
    if (length(unseen_levels) > 0) {
      warning(
        "The following data values were not found in the '", palette_name, 
        "' palette and have been set to grey: ", 
        paste(unseen_levels, collapse = ", "), 
        call. = FALSE
      )
    }
    
    # 5. Build the final color vector for all data levels
    output_colors <- vapply(data_levels, function(level) {
      project_palette[[level]] %||% unseen_color
    }, FUN.VALUE = character(1))
    
    return(output_colors)
  }
}

# Define the `%||%` inline operator for providing a default for NULL
`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}

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
  if (palette == "default") {
    return(ggsci::scale_color_npg(...))
  }
  
  pal_func <- create_project_paletter(palette_name = palette, unseen_color = unseen.color)
  ggplot2::discrete_scale("colour", palette = pal_func, ...)
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
  if (palette == "default") {
    return(ggsci::scale_fill_npg(...))
  }

  pal_func <- create_project_paletter(palette_name = palette, unseen_color = unseen.color)
  ggplot2::discrete_scale("fill", palette = pal_func, ...)
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
  if (palette == "default") {
    return(ggsci::scale_color_gsea(...))
  }

  pal <- get_project_palettes()[[palette]]
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
  if (palette == "default") {
    return(ggsci::scale_fill_gsea(...))
  }

  pal <- get_project_palettes()[[palette]]
  if (is.null(pal)) {
    stop(paste("Palette '", palette, "' not found."), call. = FALSE)
  }
  
  ggplot2::scale_fill_gradientn(colors = unname(pal), ...)
}

