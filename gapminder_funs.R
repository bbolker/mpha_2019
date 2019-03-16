require(googlesheets)
require(dplyr)
gm_ind <- readr::read_csv("http://ms.mcmaster.ca/bolker/misc/gapminder_index.csv")
region_tab <- readr::read_csv("http://ms.mcmaster.ca/bolker/misc/country_regions.csv")


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
if (FALSE) system("scp gapminder_funs.R ms.mcmaster.ca:~/public_html/misc")

