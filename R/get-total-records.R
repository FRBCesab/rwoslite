#' Retrieve total number of publications from a request
#'
#' @param query a character of length 1. The query to send to the WOS lite API.
#' 
#' @param database a character of length 1. One among... See ... for further 
#'   information.
#'
#' @return The total number of publications (integer of length 1) matching the 
#'   query.
#'   
#' @export
#'
#' @examples
#' query <- "TS=((salmo AND salar) AND conservation)"
#' get_total_records(query, database = "WOK")

get_total_records <- function(query, database = "WOK") {
  
  ## URL encoding ----
  
  query <- gsub("=", "%3D", query)
  query <- gsub("\\(", "%28", query)
  query <- gsub("\\)", "%29", query)
  query <- gsub("\\s", "%20", query)
  
  request <- paste0(api_url(), 
                    "?databaseId=", database, 
                    "&usrQuery=", query,
                    "&count=", 100,
                    "&firstRecord=", 301)
  
  response <- httr::GET(url    = request, 
                        config = httr::add_headers(
                          `accept`  = 'application/json',
                          `X-ApiKey` = get_token()))
  
  httr::stop_for_status(response)
  
  response <- httr::content(response, as = "text")
  response <- jsonlite::fromJSON(response)
  
  response$"QueryResult"$"RecordsFound"
}
