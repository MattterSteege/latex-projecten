library(ggplot2)
library(tidyr)
library(dplyr)

# Data invoeren
data <- data.frame(
  Periode = c("1987-1991", "1993-1997", "1998-2002", "2003-2007"),
  Vrouwen_Overgewicht = c(16.2, 28.1, 39.1, 45.8),
  Vrouwen_Obesitas = c(3.1, 7.6, 10.3, 15.3),
  Vrouwen_Bloeddrukverlagers = c(0.3, 1.2, 3.3, 6.9),
  Mannen_Overgewicht = c(27, 38.9, 52.1, 61.5),
  Mannen_Obesitas = c(2.8, 6.6, 8.5, 10.7),
  Mannen_Bloeddrukverlagers = c(0.2, 0.5, 1.1, 3.5)
)

# Data omzetten naar long format
data_long <- data %>%
  pivot_longer(
    cols = -Periode,
    names_to = c("Geslacht", "Categorie"),
    names_sep = "_",
    values_to = "Percentage"
  ) %>%
  mutate(
    Periode_num = case_when(
      Periode == "1987-1991" ~ 1989,
      Periode == "1993-1997" ~ 1995,
      Periode == "1998-2002" ~ 2000,
      Periode == "2003-2007" ~ 2005
    )
  )

# Kleuren
kleuren <- c(
  "Overgewicht" = "#E69F00",
  "Obesitas" = "#D55E00",
  "Bloeddrukverlagers" = "#0072B2"
)

kleuren_geslacht <- c("Vrouwen" = "#CC79A7", "Mannen" = "#009E73")

p4 <- ggplot(data_long, aes(x = Periode_num, y = Percentage, color = Geslacht, group = Geslacht)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  facet_wrap(~Categorie, ncol = 3) +
  scale_color_manual(values = kleuren_geslacht) +
  scale_x_continuous(
    breaks = c(1989, 1995, 2000, 2005),
    labels = c("'87-'91", "'93-'97", "'98-'02", "'03-'07")
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Toenemende gezondheidsrisico's 20ers",
    subtitle = "",
    caption = "",
    x = NULL,
    y = "",
    color = "Geslacht"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 14, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 11, color = "grey40", margin = margin(b = 15)),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 0, margin = margin(t = 10)),
    plot.margin = margin(15, 15, 15, 15),
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold", size = 11),
    legend.position = "bottom"
  )

ggsave("plot4_small_multiples.png", p4, width = 11, height = 5, dpi = 600, bg = "white")