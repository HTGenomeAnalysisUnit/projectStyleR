#' Custom ggplot2 Theme for the Project
#'
#' Applies a predefined theme from the loaded configuration file.
#' Additional arguments can be passed via `...` to override or add
#' theme elements on the fly.
#'
#' @param theme_name The name of the theme to apply (e.g., "default", "publication").
#' @param ... Additional arguments passed to `ggplot2::theme()` to override the loaded settings.
#' @export
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot(iris, aes(x=Sepal.Length, y=Sepal.Width)) +
#'   geom_point() +
#'   theme_project("publication", legend.position = "none") # Override
#' }
theme_project <- function(theme_name = "default", ...) {
  # 1. Get all themes and select the correct one
  project_themes <- get_project_themes()
  if (!theme_name %in% names(project_themes)) {
    stop(paste("Theme not found. Available themes are:", paste(names(project_themes), collapse = ", ")))
  }
  theme_config <- project_themes[[theme_name]]

  # 2. Get the base theme function (e.g., theme_minimal)
  base_theme_func <- get(theme_config$base_theme, as.environment("package:ggplot2"))

  # 3. Handle the font
  font_family <- theme_config$font_family
  tryCatch({
    sysfonts::font_add_google(font_family, font_family)
    showtext::showtext_auto()
  }, error = function(e) {
    warning(paste("Could not download or register font:", font_family, ". It may need to be installed manually."))
  })

  # 4. Construct theme() arguments from YAML config
  theme_args <- list()
  theme_args$axis.text <- ggplot2::element_text(size = theme_config$axis_text_size)
  theme_args$axis.title <- ggplot2::element_text(size = theme_config$axis_title_size)

  # 5. Parse and add 'other_settings' from YAML
  if (!is.null(theme_config$other_settings)) {
    other_args <- lapply(theme_config$other_settings, function(val) {
      if (is.character(val) && grepl("\\(", val)) {
        # If the value looks like a function call (e.g., "element_text(...)"), parse and evaluate it
        eval(parse(text = val))
      } else {
        val # Otherwise, use the value as is
      }
    })
    theme_args <- c(theme_args, other_args)
  }
  
  # 6. Capture override arguments from the function call (...)
  override_args <- list(...)
  
  # 7. Merge the YAML args with the override args. Overrides take precedence.
  final_args <- utils::modifyList(theme_args, override_args)

  # 8. Build the final theme object
  final_theme <- base_theme_func(base_family = font_family) +
                 do.call(ggplot2::theme, final_args)
  
  return(final_theme)
}
