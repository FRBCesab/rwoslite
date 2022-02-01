api_url <- function() "https://wos-api.clarivate.com/api/woslite/"

get_token <- function(key = "WOS") {
  
  wos_token <- Sys.getenv(key)
  
  if (wos_token == "") {
    stop("Missing WOS API Token.\n",
         "Please make sure you:\n",
         " 1. have obtained you own token, and\n",
         " 2. have stored the token in the `~/.Renviron` file ",
         "using the function `usethis::edit_r_environ()`.\n",
         "    Add this line: WOS='XXX' and restart R.")
  }
  
  wos_token
}


get_records <- function(query = "TS=((salmo AND salar) AND conservation)", database = "WOK") {
  
  ## URL encoding ----
  
  query <- gsub("=", "%3D", query)
  query <- gsub("\\(", "%28", query)
  query <- gsub("\\)", "%29", query)
  query <- gsub("\\s", "%20", query)
  
  request <- paste0(api_url(), 
                    "?databaseId=", database, 
                    "&usrQuery=", query,
                    "&count=", 1,
                    "&firstRecord=", 1)
  
  response <- httr::GET(url    = request, 
                        config = httr::add_headers(
                          `accept`  = 'application/json',
                          `X-ApiKey` = get_token()))
  
  httr::stop_for_status(response)
  
  response <- httr::content(response, as = "text")
  response <- jsonlite::fromJSON(response)
  
  response$"QueryResult"$"RecordsFound"
}
