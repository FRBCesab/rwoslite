list_to_df <- function(x) {

  if (is.null(x)) {
    NA
  } else {
    x <- unlist(lapply(x, function(y) paste0(y, collapse = " | ")))
    pos <- which(x == "")
    if (length(pos)) x[pos] <- NA
    x
  }
}

