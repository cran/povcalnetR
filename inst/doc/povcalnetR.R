## ---- include = FALSE---------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN
)

## ----setup--------------------------------------------------------------------
library(povcalnetR)

## ----message=FALSE, warning=FALSE, eval=NOT_CRAN------------------------------
povcalnet()

## ---- warning=FALSE, message=FALSE, eval=NOT_CRAN-----------------------------
# Specify ONE country
povcalnet(country = "ALB")

# Specify MULTIPLE countries
povcalnet(country = c("ALB", "CHN"))

## ---- warning=FALSE, message=FALSE, eval=NOT_CRAN-----------------------------
# Survey year NOT available
povcalnet(country = "ALB", year = 2012)

# Survey year NOT available - Empty response
povcalnet(country = "ALB", year = 2018)

## ---- warning=FALSE, message=FALSE, eval=NOT_CRAN-----------------------------
povcalnet(country = "ALB", povline = 3.2)

## ---- warning=FALSE, message=FALSE, eval=NOT_CRAN-----------------------------
# fill_gaps = FALSE (default)
povcalnet(country = "HTI")

# fill_gaps = TRUE
povcalnet(country = "HTI", fill_gaps = TRUE)

## ---- warning=FALSE, message=FALSE, eval=NOT_CRAN-----------------------------
# World aggregate
povcalnet(country = "all", aggregate = TRUE)

# Custom aggregate
povcalnet(country = c("CHL", "ARG", "BOL"), aggregate = TRUE)

