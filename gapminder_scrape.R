## FIXME: can I use fewer web-related pkgs?
library(XML) ## htmlParse/readHTMLTable
library(httr) ## HEAD()
library(dplyr)
library(tidyr)
library(stringr)
library(googlesheets)
library(readr)
library(purrr)

## need to first DOWNLOAD Data page from https://www.gapminder.org/data/
## (after clicking "show all")

h0 <- suppressWarnings(htmlParse(readLines("Data.html")))

ind_tab <- (h0
    %>% readHTMLTable(stringsAsFactors=FALSE)
    %>% purrr::pluck("indicators-table")
    %>% as_tibble()
    %>% rename(indicator="Indicator name",
               provider="Data provider",
               category="Category",
               subcategory="Subcategory")
    %>% select_if(~sum(nzchar(.))>0)
)

## extract relevant links from HTML page
hrefs <- (xpathSApply(h0, "//a/@href")
    %>% str_subset("https.*docs.google.com/spreadsheet/.*xlsx")
)

## Extract URLs. There is some URL-redirection going on; if we try to
## grab these directly via gs_read(gs_url(.)) it doesn't seem to work.
## This is a way to retrieve all of the proper GS URLs.

## may fail on timeouts
## use future package, or something, to keep retrying? tryCatch?
## get HEAD of URL response
hlist <- plyr::llply(hrefs, httr::HEAD, .progress="text")
hrefs2 <- hlist %>% map_chr(~.$url)
ind_tab$URL <- hrefs2

## test
## g1 <- gs_read(gs_url(hrefs2[1]))


## write csv and upload
write_csv(ind_tab,path="gapminder_index.csv")

if (interactive()) {
    system("scp gapminder_index.csv ms.mcmaster.ca:~/public_html/misc")
    ## FIXME: put on github instead?
}

## https://www.npmjs.com/package/country-region-data
## http://www.unicode.org/cldr/charts/latest/supplemental/territory_containment_un_m_49.html
## h1 <- suppressWarnings(htmlParse(readLines("http://www.unicode.org/cldr/charts/latest/supplemental/territory_containment_un_m_49.html")))
## rtab <- readHTMLTable(h1,stringsAsFactors=FALSE)[[5]]

## xapply
## xpathSApply(h1, '//*[contains(concat( " ", @class, " " ), concat( " ", "z3", " " ))]')

## h1 <- xmlParse(readLines("http://unicode.org/repos/cldr/trunk/common/supplemental/supplementalData.xml"))

region_url <- "https://meta.wikimedia.org/wiki/List_of_countries_by_regional_classification"
rtab <- (readLines(region_url)
    %>% htmlParse()
    %>% readHTMLTable(,header=TRUE,stringsAsFactors=FALSE)
    %>% .[[1]]
    %>% setNames(trimws(names(.)))
    %>% as_tibble()
    %>% rename(country=Country, region=Region, global_region="Global South")
)
write_csv(rtab, "country_regions.csv")
system("scp country_regions.csv ms.mcmaster.ca:~/public_html/misc")
