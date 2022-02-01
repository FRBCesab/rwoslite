#' R Client for WOS API
#'
#' @description 
#' ...
#' 
#' @author Nicolas Casajus \email{nicolas.casajus@fondationbiodiversite.fr}
#' 
#' @date 2022/02/01



## Install `remotes` package ----

if (!("remotes" %in% installed.packages())) install.packages("remotes")


## Install required packages (listed in DESCRIPTION) ----

remotes::install_deps(upgrade = "never")


## Load project dependencies ----

devtools::load_all(here::here())


## Create 'outputs' folder ----

dir.create(here::here("outputs"), showWarnings = FALSE)


## ----

n_records <- get_records(query = "TS=((salmo AND salar) AND conservation)", 
                         database = "WOK")
