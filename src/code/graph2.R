library(tidyverse)

# Data invoeren
data <- tibble(
  Jaar = c(2003, 2006, 2009, 2012, 2015, 2018, 2022),
  OESO = c(494, 485, 490, 493, 490, 487, 476),
  EU14 = c(498, 493, 495, 499, 499, 493, 480),
  Nederland = c(513, 507, 508, 511, 503, 485, 459)
)

# Data transformeren naar long format
data_long <- data %>%
  pivot_longer(
    cols = c(OESO, EU14, Nederland),
    names_to = "Regio",
    values_to = "Waarde"
  ) %>%
  mutate(
    Regio = factor(Regio, levels = c("OESO", "EU14", "Nederland")),
    Jaar = factor(Jaar)
  )

# Kleuren consistent met zachtblauwe tint
kleuren <- c("OESO" = "#ff800f", "EU14" = "#016aa8", "Nederland" = "#ababab")

ggplot(data_long, aes(x = Jaar, y = Waarde, fill = Regio)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  scale_fill_manual(values = kleuren) +
  scale_y_continuous(
    limits = c(0, 520),
    breaks = seq(0, 520, 100),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "Vergelijking scores over tijd",
    subtitle = "Nederland scoort hoger dan EU14 en OESO tot 2018",
    x = "Jaar",
    y = "Score",
    fill = NULL,
    caption = "Grouped bar chart: maakt directe vergelijking tussen groepen per jaar makkelijk"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 10, color = "grey40", margin = margin(b = 15)),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 0, margin = margin(t = 10)),
    axis.text = element_text(size = 9, color = "grey40"),
    axis.title = element_text(size = 10, color = "grey20"),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10)),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = "grey90", linewidth = 0.3),
    legend.position = "top",
    legend.justification = "left",
    legend.text = element_text(size = 10),
    plot.margin = margin(15, 15, 15, 15)
  )

ggsave("grafiek.png", width = 8, height = 5, dpi = 600, bg = "white")