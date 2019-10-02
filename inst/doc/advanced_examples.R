## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, warning=FALSE, message=FALSE---------------------------------
library(povcalnetR)
library(dplyr)
library(purrr)

## ------------------------------------------------------------------------
# Read values from a table
data("sample_input")
sample_input

## ---- message=FALSE, warning=FALSE---------------------------------------
# Use table values to send a request to the API
# Only works for survey years
povcalnet_cl(country = sample_input$country,
             povline = sample_input$poverty_line,
             year = sample_input$year,
             ppp = sample_input$ppp)

## ---- message=FALSE, warning=FALSE---------------------------------------
povcalnet_info() %>%
glimpse()

## ---- message=FALSE, warning=FALSE---------------------------------------
get_countries(c("ECA"))

## ---- message=FALSE, warning=FALSE---------------------------------------
get_countries(c("LIC"))

## ---- message=FALSE, warning=FALSE---------------------------------------
income_groups <- c("LIC", "LMC", "UMC")
poverty_lines <- c(1.9, 3.2, 5.5)
map2_df(income_groups, poverty_lines, ~povcalnet(country = get_countries(.x),
                                                 povline = .y,
                                                 year = 2015,
                                                 aggregate = TRUE)
        )

