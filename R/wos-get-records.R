#' Download references that match a given WOS query
#' 
#' @description
#' This function sends a query to the Web Of Science Lite API 
#' (\url{https://developer.clarivate.com/apis/woslite}) and returns references 
#' that match this query.
#' 
#' To learn how to write a WOS query, users can read the WOS documentation 
#' available at:
#' \url{https://images.webofknowledge.com/images/help/WOK/contents.html}.
#' A list of WOS field tags is available at: 
#' \url{https://images.webofknowledge.com/images/help/WOS/hs_wos_fieldtags.html}.
#' 
#' It's strongly recommended to use the function [wos_search] before to 
#' have an idea on how many records you will download.
#' 
#' **Important:** Due to WOS LITE API limitations, the total number of records 
#' cannot exceed 100,000.
#' 
#' @param limit an `numeric` of length 1. The number of records to retrieve.
#'   Must be < 100,000 (API limit). Default is `NULL` (all possible records
#'   will be retrieved).
#' 
#' @param sleep an `numeric` of length 1. To not stress the WOS LITE API, a 
#'   random number between 0 and `sleep` will be picked to suspend queries.
#' 
#' @inheritParams wos_search
#' 
#' @return A `data.frame` with `n` rows (where `n` is the total number of 
#' references) and the following 21 variables:
#' `ut`: the unique identifier of the reference in the Web of Science system;
#' `doc_type`: the document type;
#' `title`: the title of the reference;
#' `authors`: the authors of the reference;
#' `book_authors`: the book authors (if applicable);
#' `book_group_authors`: the book group authors (if applicable);
#' `keywords`: the authors keywords;
#' `source`: the title of the source (journal, book, etc.) in which the 
#'   reference was published;
#' `volume`: the volume number;
#' `issue`: the issue number;
#' `pages`: the pages range in the source;
#' `no_article`: the article number;
#' `published_date`: the published date;
#' `published_year`: the published year;
#' `supplement_number`: the supplement number (if applicable);
#' `special_issue`: `SI` in case of a special issue (if applicable);
#' `book_series_title`: the book series title (if applicable);
#' `doi`: the Digital Object Identifier;
#' `eissn`: the Electronic International Standard Identifier Number;
#' `issn`: the International Standard Identifier Number;
#' `isbn`: International Standard Book Number.
#'   
#' @export
#' 
#' @examples
#' \dontrun{
#' ## Download references of one author ----
#' query <- "AU=(\"Casajus N\")"
#' wos_search(query)
#' refs <- wos_get_records(query)
#' refs <- wos_get_records(query, limit = 1)
#' }

wos_get_records <- function(query, database = "WOS", limit = NULL, sleep = 1) {
  
  if (!is.null(limit)) {
    
    if (limit == 0) {
      stop("Argument 'limit' must be strictly positive", call. = FALSE)
    }
    
    if (limit > 100000) {
      stop("Argument 'limit' must be < 100,000", call. = FALSE)
    }
  }
  
  
  ## URL encoding ----
  
  query <- utils::URLencode(query, reserved = TRUE)
  
  
  ## Get total number of references ----
  
  n_refs <- wos_search(query, database)
  
  if (!is.null(limit)) {
    if (n_refs >= limit) {
      n_refs <- limit
    } else {
      limit <- n_refs
    }
  }
  
  
  ## Checks ----
  
  if (n_refs > 100000) {
    stop("Number of records found exceeds WOS LITE API limit (> 100,000).\n",
         "Please refine your search.", call. = FALSE)
  }
  
  if (n_refs == 0)
    stop("No reference found")
  
  
  ## Compute number of requests ----
  
  refs  <- data.frame()
  
  n_records_per_page <- 100
  
  if (!is.null(limit)) {
    if (limit <= n_records_per_page) {
      n_records_per_page <- limit
    }
  }
  
  pages <- seq(1, n_refs, by = n_records_per_page)
  
  
  for (page in pages) {
    
    
    ## Write query ----
    
    request <- paste0(api_url(), "?databaseId=", database, "&usrQuery=", query,
                      "&count=", n_records_per_page, "&firstRecord=", page)
    
    
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
    
    content <- content$"Data"
    

    ## Convert listed df to df ----
    
    data <- data.frame(
      "ut"                 = content$"UT",
      "doc_type"           = list_to_df(content$Doctype$"Doctype"),
      "title"              = list_to_df(content$Title$"Title"),
      "authors"            = list_to_df(content$Author$"Authors"),
      "book_authors"       = list_to_df(content$Author$"BookAuthors"),
      "book_group_authors" = list_to_df(content$Author$"BookGroupAuthors"),
      "keywords"           = list_to_df(content$Keyword$"Keywords"),
      "source"             = list_to_df(content$Source$"SourceTitle"),
      "volume"             = list_to_df(content$Source$"Volume"),
      "issue"              = list_to_df(content$Source$"Issue"),
      "pages"              = list_to_df(content$Source$"Pages"),
      "no_article"         = list_to_df(content$Other$"Identifier.article_no"),
      "published_date"     = list_to_df(content$Source$"Published.BiblioDate"),
      "published_year"     = list_to_df(content$Source$"Published.BiblioYear"),
      "supplement_number"  = list_to_df(content$Source$"SupplementNumber"),
      "special_issue"      = list_to_df(content$Source$"SpecialIssue"),
      "book_series_title"  = list_to_df(content$Source$"BookSeriesTitle"),
      "doi"                = list_to_df(content$Other$"Identifier.Doi"),
      "eissn"              = list_to_df(content$Other$"Identifier.Eissn"),
      "issn"               = list_to_df(content$Other$"Identifier.Issn"),
      "isbn"               = list_to_df(content$Other$"Identifier.Isbn"))
    
    refs <- rbind(refs, data)
    
    
    ## Do not stress the API ----
    
    if (length(pages) > 1) Sys.sleep(sample(seq(0, sleep, by = 0.01), 1))
  }
  
  if (!is.null(limit)) refs <- refs[1:limit, ]
  
  refs
}
