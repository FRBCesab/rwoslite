#' Retrieve the number of records that match a given WOS query
#' 
#' @description
#' This function sends a query to the 
#' [Web Of Science Lite API](https://developer.clarivate.com/apis/woslite)
#' and returns the total number of records that match this query.
#' 
#' To learn how to write a WOS query, users can read the 
#' [WOS documentation](https://images.webofknowledge.com/images/help/WOK/contents.html).
#' A list of WOS field tags is available 
#' [here](https://images.webofknowledge.com/images/help/WOS/hs_wos_fieldtags.html).
#' 
#' It's strongly recommended to use this function before [wos_get_records] to 
#' have an idea on how many records you will download.
#' 
#' @param query a character of length 1. The query to send to the WOS lite API.
#'   Visit the [WOS documentation](https://images.webofknowledge.com/images/help/WOK/contents.html) 
#'   on how to write a query.
#' 
#' @param database a character of length 1. One among `BCI` (BIOSIS Citation 
#'   Index), `BIOABS` (Biological Abstracts), `BIOSIS` (BIOSIS Previews), 
#'   `CCC` (Current Contents Connect), `DCI` (Data Citation Index), `DIIDW` 
#'   (Derwent Innovations Index), `MEDLINE` (Medline), `WOS` (Web of Science 
#'   Core Collection), `ZOOREC` (Zoological Record), and `WOK` (all databases).
#'   Default is `WOK` (all databases).
#'
#' @return The total number of records (integer of length 1) that match the 
#'   query.
#'   
#' @export
#'
#' @examples
#' \dontrun{
#' ## Search in TOPIC an exact expression ----
#' query <- "TS=\"salmo salar\""
#' wos_search(query)
#' 
#' ## Search in TOPIC an exact expression and another term ----
#' query <- "TS=(\"salmo salar\" AND conservation)"
#' wos_search(query)
#' 
#' ## Search for a specific year ----
#' query <- "TS=(\"salmo salar\" AND conservation) AND PY=2021"
#' wos_search(query)
#' 
#' ## Search for a time span ----
#' query <- "TS=(\"salmo salar\" AND conservation) AND PY=2010-2021"
#' wos_search(query)
#' 
#' ## Search for an author ----
#' query <- "AU=(\"Casajus N\")"
#' wos_search(query)
#' }

wos_search <- function(query, database = "WOK") {
  
  
  ## Checks ----
  
  if (!is.character(query))
    stop("Argument 'query' must be a character", call. = FALSE)
  
  if (length(query) != 1)
    stop("Argument 'query' must be a character of length 1", call. = FALSE)
  
  if (!is.character(database))
    stop("Argument 'database' must be a character", call. = FALSE)
  
  if (length(database) != 1)
    stop("Argument 'database' must be a character of length 1", call. = FALSE)
  
  database <- toupper(database)
  
  valid_databases <- c("BCI", "BIOABS", "BIOSIS", "CCC", "DCI", "DIIDW", 
                       "MEDLINE", "WOS", "ZOOREC", "WOK")
  
  if (!(database %in% valid_databases))
    stop("Invalid 'database' value", call. = FALSE)
  
  
  ## URL encoding ----
  
  query <- utils::URLencode(query, reserved = TRUE)
  
  
  ## Write query ----
  
  request <- paste0(api_url(), "?databaseId=", database, "&usrQuery=", query,
                    "&count=", 0, "&firstRecord=", 1)
  
  
  ## Send query ----
  
  response <- httr::GET(url    = request, 
                        config = httr::add_headers(
                          `accept`   = 'application/json',
                          `X-ApiKey` = get_token()))
  
  
  ## Check response ----
  
  httr::stop_for_status(response)
  
  
  ## Extract total number of records ----
  
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  content <- jsonlite::fromJSON(content)
  
  content$"QueryResult"$"RecordsFound"
}
