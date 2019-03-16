require(googlesheets)
require(dplyr)
loc <- "https://bbolker.github.io/mpha_2019/"
gm_ind <- readr::read_csv(paste0(loc,"gapminder_index.csv"))
region_tab <- readr::read_csv(paste0(loc,"country_regions.csv"))

##' retrieve a gapminder data sheet from Google Docs
##' @param target
get_data <- function(target, multiple_ok=FALSE) {
    ss <- filter(gm_ind,stringr::str_detect(indicator,target))
    if (!multiple_ok && nrow(ss)>1) {
        msg <- paste0("multiple sheets detected: ",
                      paste(ss$indicator,collapse="; "))
        stop(msg)
    }
    return(gs_read(gs_url(ss$URL)))
}

