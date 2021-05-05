#' Login and Obtain Revenera API Session Id
#' 
#' A session must first be established before querying the API.
#' This is done using your Revenera username and password.
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
#' @importFrom magrittr "%>%"
#' 
#' @return A list with details on connection to the Revenera API.
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' rev_user <- "my_username"
#' rev_pwd <- "super_secret"
#' product_ids_list <- c("123", "456", "789")
#' start_date <- lubridate::floor_date(Sys.Date(), unit = "months") - months(6)
#' end_date <- Sys.Date() - 1
#' session_id <- revenera_auth(rev_user, rev_pwd)
#' }
 
revenera_auth <- function(rev_username, rev_password) {

  revenera_login <- httr::RETRY("POST",
                                 url = "https://api.revulytics.com/auth/login",
                                 body = list(user = rev_username,
                                             password = rev_password,
                                             useCookies = FALSE),
                                 encode = "json",
                                 times = 4,
                                 pause_min = 10,
                                 terminate_on = NULL,
                                 terminate_on_success = TRUE,
                                 pause_cap = 5)
  
  check_status(revenera_login)
  
  rev_session_id <- httr::content(revenera_login)$sessionId
  
  return(rev_session_id)
}

