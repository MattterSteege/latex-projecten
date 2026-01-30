library(ggplot2)
library(tidyr)
library(dplyr)
library(readr)

# Data inline
data <- data.frame(
  Maand = c("mrt 2020", "apr 2020", "mei 2020", "jun 2020", "jul 2020", "aug 2020",
            "sep 2020", "okt 2020", "nov 2020", "dec 2020", "jan 2021", "feb 2021",
            "mrt 2021", "apr 2021", "mei 2021", "jun 2021", "jul 2021", "aug 2021",
            "sep 2021", "okt 2021", "nov 2021"),
  `Supermarkt en apotheek` = c(15, 10, 5, 0, -5, -5, 0, 0, 0, 5, 10, 5, 0, 5, 10, 10, 15, 15, 12, 10, 10),
  `Detailhandel en recreatie` = c(-50, -45, -30, -20, -15, -10, -5, -5, -10, -15, -25, -20, -15, -20, -30, -25, -20, -15, -10, -5, -10),
  `Stations openbaar vervoer` = c(-60, -50, -40, -30, -25, -20, -15, -10, -20, -35, -55, -60, -50, -55, -45, -40, -25, -20, -15, -10, -20),
  Werk = c(-45, -50, -45, -40, -35, -30, -30, -25, -30, -40, -50, -45, -40, -45, -35, -30, -20, -15, -10, -15, -20),
  check.names = FALSE
)

# Verwijder deze regel:
# data = pd.read_csv('mobility_data.csv')

# Data omzetten naar long format
data_long <- data %>%
  pivot_longer(
    cols = -Maand,
    names_to = "Categorie",
    values_to = "Percentage"
  ) %>%
  mutate(
    Maand_date = as.Date(paste0(Maand, " 01"), format = "%b %Y %d"),
    Categorie_kort = case_when(
      Categorie == "Supermarkt en apotheek" ~ "Supermarkt\nApotheek",
      Categorie == "Detailhandel en recreatie" ~ "Detailhandel\nRecreatie",
      Categorie == "Stations openbaar vervoer" ~ "OV Stations",
      Categorie == "Werk" ~ "Werk "
    )
  )

# Kleuren zoals in de originele grafiek
kleuren <- c(
  "Supermarkt\nApotheek" = "#D81B60",
  "Detailhandel\nRecreatie" = "#1E88E5",
  "OV Stations" = "#FFC107",
  "Werk " = "#004D40"
)

# Lockdown periodes definiëren
lockdown1_start <- as.Date("2020-03-15")
lockdown1_end <- as.Date("2020-05-31")
lockdown2_start <- as.Date("2020-12-15")
lockdown2_end <- as.Date("2021-04-28")

p2 <- ggplot(data_long, aes(x = Maand_date, y = Percentage, color = Categorie_kort, group = Categorie_kort)) +
  # Lockdown achtergronden
  annotate("rect", xmin = lockdown1_start, xmax = lockdown1_end,
           ymin = -Inf, ymax = Inf, alpha = 0.1, fill = "gray50") +
  annotate("rect", xmin = lockdown2_start, xmax = lockdown2_end,
           ymin = -Inf, ymax = Inf, alpha = 0.1, fill = "gray50") +
  # Verticale lijnen voor lockdown starts
  geom_vline(xintercept = as.numeric(lockdown1_start), linetype = "dashed",
             color = "gray30", linewidth = 0.8) +
  geom_vline(xintercept = as.numeric(lockdown2_start), linetype = "dashed",
             color = "gray30", linewidth = 0.8) +
  # Data lijnen
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  # Labels aan het begin van de lijnen met percentage
  geom_text(data = data_long %>%
              group_by(Categorie_kort) %>%
              slice_min(Maand_date, n = 1),
            aes(label = paste0(Categorie_kort)),
            hjust = 1.1, vjust = 0.5, size = 3.5, fontface = "bold") +
  # Lockdown labels
  annotate("text", x = lockdown1_start + 30, y = 18,
           label = "eerste lockdown", size = 3, color = "gray30", fontface = "italic") +
  annotate("text", x = lockdown2_start + 40, y = 18,
           label = "lockdown 2e golf", size = 3, color = "gray30", fontface = "italic") +
  scale_color_manual(values = kleuren) +
  scale_x_date(date_breaks = "2 months", date_labels = "%b\n%Y",
               limits = c(as.Date("2020-01-15"), max(data_long$Maand_date))) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Verschil bezoekersaantal t.o.v. voor de coronacrisis",
    subtitle = "",
    caption = "Bron: Google Mobility Reports",
    x = NULL,
    y = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 14, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 11, color = "grey40", margin = margin(b = 15)),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 0, margin = margin(t = 10)),
    plot.margin = margin(15, 35, 15, 15),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

ggsave("plot2_alle_lijnen.png", p2, width = 11, height = 6, dpi = 600, bg = "white")