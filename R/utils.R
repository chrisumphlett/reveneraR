#' Check Request Status
#' 
#' This function is called by other functions that submit a 
#' requests to revulytics API. It checks the status code
#' returned and tells the user if there was an error code and
#' exits the function.

#' 
#' @return If status code is not 200, returns a message to console and stops execution 
#' 
#' @keywords internal

check_status <- function(request_obj) {
    if (request_obj$status_code != 200) {
      message(paste0("The API request returned error. Please check the request: ", request_obj$status_code))
      stop()
    }
} 
