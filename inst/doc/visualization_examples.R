## ---- include = FALSE, message=FALSE, warning=FALSE---------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.height=7, 
  fig.width=9,
  purl = NOT_CRAN
)

## ----setup, message=FALSE, warning=FALSE--------------------------------------
library(povcalnetR)
library(ggplot2)
library(tidyr)
library(ggthemes)
library(forcats)
library(scales)
library(dplyr)
library(purrr)

## ---- message=FALSE, warning=FALSE, eval=NOT_CRAN-----------------------------
df <- povcalnet_wb() %>%
  filter(year > 1989, regioncode == "WLD") %>%
  mutate(
    poor_pop = round(headcount * population, 0),
    headcount = round(headcount, 3)
  )

headcount_col <- "#E69F00"

ggplot(df, aes(x = year)) +
  geom_text(aes(label = headcount * 100, y = headcount), vjust = 1, nudge_y = -0.02, color = headcount_col) +
  geom_text(aes(label = poor_pop, y = poor_pop / 5000), vjust = 0, nudge_y = 0.02) +
  geom_line(aes(y = headcount), color = headcount_col) +
  geom_line(aes(y = poor_pop / 5000)) +
  geom_point(aes(y = headcount), color = headcount_col) +
  geom_point(aes(y = poor_pop / 5000)) +
  scale_y_continuous(
    labels = scales::percent,
    limits = c(0, 0.5),
    breaks = c(0, 0.1, 0.2, 0.3, 0.4),
    sec.axis = sec_axis(~.*5000, name = "Number of poor (million)",
                        breaks = c(0, 500, 1000, 1500, 2000))) +
  labs(
    y = "Poverty rate (%)",
    x = ""
  ) +
  theme_classic()

## ----message=FALSE, warning=FALSE, eval=NOT_CRAN------------------------------
df <- povcalnet_wb() %>%
  filter(year > 1989) %>%
  mutate(
    poor_pop = round(headcount * population, 0),
    headcount = round(headcount, 3)
  )

regions <- df %>%
  filter(regioncode != "WLD") %>%
  mutate(
    regiontitle = fct_relevel(regiontitle,
                               c("Other high Income",
                                 "Europe and Central Asia",
                                 "Middle East and North Africa",
                                 "Latin America and the Caribbean",
                                 "East Asia and Pacific",
                                 "South Asia",
                                 "Sub-Saharan Africa"
                                 ))
  )
world <- df %>%
  filter(regioncode == "WLD")

ggplot(regions, aes(y = poor_pop, x = year, fill = regiontitle)) +
  geom_area() +
  scale_y_continuous(
    limits = c(0, 2000),
    breaks = c(0, 500, 1000, 1500, 2000)
  ) +
  scale_fill_tableau(palette = "Tableau 10") +
  labs(
    y = "Number of poor (million)",
    x = ""
  ) +
  theme_classic() +
  theme(
    legend.position = "bottom"
  ) +
  geom_line(data = world, size = rel(1.5), alpha =.5, linetype = "longdash")

## ---- message=FALSE, warning=FALSE, eval=NOT_CRAN-----------------------------
df <- povcalnet(country = c("ARG", "GHA", "THA"),
                coverage = "all") %>%
  filter(year > 1989) %>%
  select(countrycode:isinterpolated, gini)

ggplot(df, aes(x = year, y = gini, color = countryname)) +
  geom_line() +
  geom_point(data = df[df$isinterpolated == 0, ]) +
  scale_y_continuous(
    limits = c(0.35, 0.55),
    breaks = c(0.35, 0.40, 0.45, 0.50, 0.55)
  ) +
  scale_color_colorblind() +
  labs(
    y = "Gini Index",
    x = ""
  ) +
  theme_classic() +
  theme(
    legend.position = "bottom"
  )


## ---- message=FALSE, warning=FALSE, eval=NOT_CRAN-----------------------------
poverty_lines <- c(1.9, 3.2, 5.5, 15)
df <- map_dfr(poverty_lines, povcalnet_wb)
out <- df %>%
  filter(year >= 1990,
         regioncode %in% c("SSA", "EAP")) %>%
  select(povertyline, regioncode, regiontitle, year, headcount) %>%
  mutate(
    povertyline = round(povertyline * 100, 1),
    headcount = headcount * 100
  ) %>%
  pivot_wider(names_from = povertyline,
              names_prefix = "headcount",
              values_from = headcount) %>%
  mutate(
    percentage_0 = headcount190,
    percentage_1 = headcount320 - headcount190,
    percentage_2 = headcount550 - headcount320,
    percentage_3 = headcount1500 - headcount550,
    percentage_4 = 100 - headcount1500
  ) %>%
  select(regioncode, regiontitle, year, starts_with("percentage_")) %>%
  pivot_longer(cols = starts_with("percentage_"), 
               names_to = "income_category", 
               values_to = "percentage") %>%
  mutate(
    income_category = recode(income_category,
                             percentage_0 = "Poor IPL (<$1.9)",
                             percentage_1 = "Poor LMIC ($1.9-$3.2)",
                             percentage_2 = "Poor UMIC ($3.2-$5.5)",
                             percentage_3 = "$5.5-$15",
                             percentage_4 = "Middle class (>$15)"),
    income_category = as_factor(income_category),
    income_category = fct_relevel(income_category, rev)
  )

ggplot(out[out$regioncode == "EAP",], aes(x = year, y = percentage, fill = income_category)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(percentage, 1)), 
            position = position_stack(0.5),
            size = rel(2.9)) +
  scale_fill_manual(values = c("#a7b6ba", "#e6a14a", "#859a6a", "#ad6e72", "#5d7a96")) +
  scale_y_continuous(breaks = c(0, 20, 40, 60, 80, 100)) +
  scale_x_continuous(breaks = unique(out$year)) +
  labs(
    title = "Distribution of income in East Asia and Pacific over time",
    y = "Population share in each income category (%)",
    x = ""
  ) +
  coord_cartesian(ylim = c(0, 105), expand = FALSE) +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme_classic(base_size = 14) +
  theme(plot.title = element_text(face = "bold",
                                  size = rel(1.2)),
        axis.text.x = element_text(angle = 45,
                                   margin = margin(t = 10)), 
        axis.line.y = element_blank(),
        axis.line.x = element_line(colour="black"),
        axis.ticks = element_blank(),
        panel.grid.major.y = element_line(colour="#f0f0f0"),
        legend.position = "bottom",
        legend.direction = "horizontal",
        legend.key.size= unit(0.5, "cm"),
        legend.margin = unit(0, "cm"),
        legend.title = element_blank(),
        plot.margin=unit(c(10,5,5,5),"mm"),
        strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
        strip.text = element_text(face="bold")
  )

ggplot(out[out$regioncode == "SSA",], aes(x = year, y = percentage, fill = income_category)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(percentage, 1)), 
            position = position_stack(0.5),
            size = rel(2.9)) +
  scale_fill_manual(values = c("#a7b6ba", "#e6a14a", "#859a6a", "#ad6e72", "#5d7a96")) +
  scale_y_continuous(breaks = c(0, 20, 40, 60, 80, 100)) +
  scale_x_continuous(breaks = unique(out$year)) +
  labs(
    title = "Distribution of income in Sub-Saharan Africa over time\n",
    y = "Population share in each income category (%)",
    x = ""
  ) +
  coord_cartesian(ylim = c(0, 105), expand = FALSE) +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme_classic(base_size = 14) +
  theme(plot.title = element_text(face = "bold",
                                  size = rel(1.2)),
        axis.text.x = element_text(angle = 45,
                                   margin = margin(t = 10)), 
        axis.line.y = element_blank(),
        axis.line.x = element_line(colour="black"),
        axis.ticks = element_blank(),
        panel.grid.major.y = element_line(colour="#f0f0f0"),
        legend.position = "bottom",
        legend.direction = "horizontal",
        legend.key.size= unit(0.5, "cm"),
        legend.margin = unit(0, "cm"),
        legend.title = element_blank(),
        plot.margin=unit(c(10,5,5,5),"mm"),
        strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
        strip.text = element_text(face="bold")
  )


