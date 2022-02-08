#' Retrieve total number of publications from a request
#' 
#' https://developer.clarivate.com/apis/woslite
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
#' wos_search(query)

wos_search <- function(query, database = "WOK") {
  
  ## URL encoding ----
  
  query <- utils::URLencode(query, reserved = TRUE)
  
  request <- paste0(api_url(), "?databaseId=", database, "&usrQuery=", query,
                    "&count=", 0, "&firstRecord=", 1)
  
  response <- httr::GET(url    = request, 
                        config = httr::add_headers(
                          `accept`   = 'application/json',
                          `X-ApiKey` = get_token()))
  
  httr::stop_for_status(response)
  
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  content <- jsonlite::fromJSON(content)
  
  content$"QueryResult"$"RecordsFound"
}
