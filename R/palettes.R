#' Display a project color palette
#'
#' Creates a simple ggplot visualization of a specified, loaded color palette.
#'
#' @param palette_name The name of the palette to display (e.g., "primary", "vibrant").
#' @return A ggplot object visualizing the color palette.
#' @export
#' @examples
#' # This will display the default 'primary' palette on package load
#' display_project_palette("primary")
display_project_palette <- function(palette_name) {
  project_palettes <- get_project_palettes() # Use the new helper function
  
  if (!palette_name %in% names(project_palettes)) {
    stop(paste("Palette not found. Available palettes are:", paste(names(project_palettes), collapse = ", ")))
  }

  pal <- project_palettes[[palette_name]]
  pal_df <- data.frame(
    name = names(pal),
    color = unliast(unname(pal)),
    stringsAsFactors = FALSE
  )
  
  pal_df$name <- factor(pal_df$name, levels = names(pal))
  
  ggplot2::ggplot(pal_df, ggplot2::aes(x = name, y = 1, fill = color)) +
    ggplot2::geom_col(width = 1) +
    ggplot2::geom_text(ggplot2::aes(label = color), vjust = 1.5, color = "white", size = 3.5, fontface = "bold") +
    ggplot2::geom_text(ggplot2::aes(label = names(pal)), vjust = -0.5, color = "black", size = 3.5) +
    ggplot2::scale_fill_identity() +
    ggplot2::labs(title = paste("Project Palette:", palette_name)) +
    ggplot2::theme_void() +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
}
