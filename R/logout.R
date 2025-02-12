#' Remove authorization cookies (logout).
#'
#' Use this to remove the current authorization before re-authorizing.
#'
#' It is not recommended that these values be stored directly
#' in your code. There are various methods and packages
#' available that are more secure; this package does not require
#' you to use any one in particular.
#'
#' @param rev_username Revenera username.
#' @param rev_password Revenera password.
#'
#' @import httr
#' @import jsonlite
#'
#' @return Nothing (successful logout), or an error message.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' rev_user <- "my_username"
#' rev_pwd <- "super_secret"
#' revenera_auth(rev_user, rev_pwd)
#' logout(rev_user, rev_pwd)
#' }
#'
logout <- function(rev_username, rev_password) {
  
  logout_endpoint <- "auth/logout"
  body <- list(
    userName = rev_username,
    password = rev_password
  )
  
  logout <- httr::RETRY("POST",
              url = paste0(base_url, logout_endpoint),
              add_headers(.headers = headers),
              body = jsonlite::toJSON(body, auto_unbox = TRUE),
              encode = "json",
              times = 4,
              pause_min = 10,
              terminate_on = NULL,
              terminate_on_success = TRUE,
              pause_cap = 5
  )
  
  check_status(logout)
}
