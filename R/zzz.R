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
