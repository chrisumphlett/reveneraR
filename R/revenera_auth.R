#' Login and Obtain Revenera API Session Id
#'
#' An authorizaton cookie must first be established before querying for data.
#' This is done using your Revenera username and password. If there is an 
#' active cookie this function will fail. You must `logout()` first then
#; re-authenticate.
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
#' @return Cookie authorization (which you won't see), or an error message.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' rev_user <- "my_username"
#' rev_pwd <- "super_secret"
#' authorize <- revenera_auth(rev_user, rev_pwd)
#' }
#'
revenera_auth <- function(rev_username, rev_password) {
  
  auth_endpoint <- "auth/web"
  body <- list(
    userName = rev_username,
    password = rev_password
  )
  auth <- httr::authenticate(rev_username, rev_password, type = "basic")
  
  generate_auth_cookie <- httr::RETRY("POST",
    url = paste0(base_url, auth_endpoint),
    add_headers(.headers = headers),
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    auth,
    encode = "json",
    times = 4,
    pause_min = 10,
    terminate_on = NULL,
    terminate_on_success = TRUE,
    pause_cap = 5
  )

  check_status(generate_auth_cookie)
}
