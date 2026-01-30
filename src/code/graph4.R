library(ggplot2)
library(dplyr)
library(forcats)
library(ggrepel)

# Data invoeren
data <- data.frame(
  Kleur = c("Overige", "Oranje", "Geel", "Beige", "Bruin", "Groen",
            "Rood", "Wit", "Blauw", "Zwart", "Grijs"),
  Percentage = c(1, 1, 1, 1, 2, 3, 6, 13, 14, 24, 34)
)

# Kleuren definiëren (zo realistisch mogelijk)
kleur_mapping <- c(
  "Grijs" = "#8C8C8C",
  "Zwart" = "#1a1a1a",
  "Blauw" = "#1E3A8A",
  "Wit" = "#F5F5F5",
  "Rood" = "#DC2626",
  "Groen" = "#16A34A",
  "Bruin" = "#78350F",
  "Beige" = "#D4C5B9",
  "Geel" = "#EAB308",
  "Oranje" = "#EA580C",
  "Overige" = "#A78BFA"
)

# Sorteer data
data <- data %>%
  mutate(Kleur = fct_reorder(Kleur, Percentage))

# Voor treemap moeten we wat berekenen
library(treemapify)

data_tree <- data %>%
  mutate(
    label = paste0(Kleur, "\n", Percentage, "%"),
    text_color = ifelse(Kleur %in% c("Zwart", "Blauw", "Bruin", "Groen"), "white", "black")
  )

p2 <- ggplot(data_tree, aes(area = Percentage, fill = Kleur, label = label)) +
  geom_treemap(color = "white", size = 2) +
  geom_treemap_text(
    aes(color = text_color),
    place = "centre",
    size = 12,
    fontface = "bold",
    lineheight = 0.9
  ) +
  scale_fill_manual(values = kleur_mapping) +
  scale_color_identity() +
  labs(
    title = "Autokleuren in Nederland",
    subtitle = "",
    caption = ""
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 14, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 11, color = "grey40", margin = margin(b = 15)),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 0, margin = margin(t = 10)),
    plot.margin = margin(15, 15, 15, 15),
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

ggsave("autokleur_alt2_treemap.png", p2, width = 10, height = 7, dpi = 600, bg = "white")