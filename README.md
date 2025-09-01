# projectStyleR: Consistent Plotting Styles for R

`projectStyleR` is a utility package for R designed to enforce a consistent visual identity across all `ggplot2` plots generated for a scientific project. By centralizing color palettes and theme definitions in simple, editable YAML files, it ensures that every team member produces plots with the same branding. 

This package is the R component of the projectStyler ecosystem, with a sister package, projet_style_py, available for Python users. 

## Core Features

- Centralized Configuration: Define all color palettes and plot themes in human-readable `YAML` files.
- ggplot2 Integration: A suite of `scale_*` and `theme_*` functions that feel native to `ggplot2`.
- Easy to Use: Apply complex styling with simple, one-line functions.
- Dynamic Loading: Load configurations from a local file or a remote URL (e.g., a raw GitHub file), allowing for project-wide updates without changing code.
- Flexible Palettes: Supports named palettes for precise color mapping and falls back to `ggsci` for robust defaults.

## 📦 Installation

You can install the R package directly from its GitHub repository using the `devtools` or `remotes` package.

```R
# First, install devtools if you don't have it
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install the package from GitHub
devtools::install_github("https://github.com/HTGenomeAnalysisUnit/projectStyleR")
remotes::install_github("https://github.com/HTGenomeAnalysisUnit/projectStyleR")
```

## 📊 Usage

1. **Applying a Project Theme**

The `theme_project()` function applies a predefined theme from your `themes.yaml` file.

```R
library(ggplot2)
library(sciplotR)

# Apply the 'default' theme
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) +
  geom_point() +
  theme_project("default") +
  labs(title = "Default Project Theme")

# Apply the 'publication' theme for a different style
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width)) +
  geom_point() +
  theme_project("publication") +
  labs(title = "Publication-Ready Theme")
```

2. **Using Color Palettes**

The `scale_color_project()` and `scale_fill_project()` functions apply palettes from your `palettes.yaml`.

```R
# Use the default ggsci::scale_color_npg() fallback
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point(size = 3) +
  scale_color_project() +
  theme_project()

# Use a specific project palette and add a custom legend title
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point(size = 3) +
  scale_color_project(palette = "vibrant", name = "Iris Species") +
  theme_project()
```

3. **Viewing Palettes**

Visualize any available palette to see its colors and names.

```R
display_project_palette("primary")
```

4. **Advanced: Custom Configurations**

By default, the package uses the `YAML` files it was installed with. You can override this by pointing to your own local or remote files.

```R
# Load palettes from a local file
load_project_palettes("path/to/my_palettes.yaml")

# Load themes from a raw GitHub URL
load_project_themes("[https://raw.githubusercontent.com/user/repo/main/configs/project_themes.yaml](https://raw.githubusercontent.com/user/repo/main/configs/project_themes.yaml)")

# All subsequent plots will use these new configurations
```

## ⚙️ Configuration Files

The `palettes.yaml` and `themes.yaml` files are the heart of this system. 

To achieve consistent styling across your project you can either 

- fork this repository and editing the files in the `inst/` directory to match your project's brand identity and then install the package from your forked repository to share the new defaults with your team.
- create dedicated `palettes.yaml` and `themes.yaml` files for your project and ideally host them in the project GitHub repository. Then configure your scripts to always load these files from the centralized project source using the `load_project_palettes()` and `load_project_themes()` functions.

## 📝 License

This project is licensed under the MIT License.