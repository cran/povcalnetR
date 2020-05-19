## ---- include = FALSE---------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN
)


## ----setup, warning=FALSE, message=FALSE--------------------------------------
library(povcalnetR)
library(dplyr)
library(purrr)

## -----------------------------------------------------------------------------
# Read values from a table
data("sample_input")
sample_input

## ---- message=FALSE, warning=FALSE, eval=NOT_CRAN-----------------------------
# Use table values to send a request to the API
# Only works for survey years
povcalnet_cl(country = sample_input$country,
             povline = sample_input$poverty_line,
             year = sample_input$year,
             ppp = sample_input$ppp)

## ---- message=FALSE, warning=FALSE, eval=NOT_CRAN-----------------------------
povcalnet_info() %>%
glimpse()

## ---- message=FALSE, warning=FALSE, eval=NOT_CRAN-----------------------------
get_countries(c("ECA"))

## ---- message=FALSE, warning=FALSE, eval=NOT_CRAN-----------------------------
get_countries(c("LIC"))

## ---- message=FALSE, warning=FALSE, eval=NOT_CRAN-----------------------------
income_groups <- c("LIC", "LMC", "UMC")
poverty_lines <- c(1.9, 3.2, 5.5)
map2_df(income_groups, poverty_lines, ~povcalnet(country = get_countries(.x),
                                                 povline = .y,
                                                 year = 2015,
                                                 aggregate = TRUE)
        )

