#' Event Tracking
#' 
#' Get aggregated data across clients on different types of event usage 
#' over time for all product ids in a list.
#' 
#' Revenera provides separate endpoints for lifetime event tracking, 
#' basic event tracking, and advanced event tracking. More information
#' on each of these is available at 
#' <https://docs.revenera.com/ui560/report/Content/helplibrary/Event_Tracking_Reports.htm>.
#' 
#' Not all possible parameters for each endpoint have been included in
#' this function. For now the function allows specifying the products,
#' date range, events (if applicable), and global filters (if applicable).
#' You can specify a start and end date but Revenera does not store
#' an indefinite period of historical data. In my experience this is 
#' three years but I do not know if this varies on a product or client
#' level.
#' 
#' It is not recommended that your username be stored directly in your
#' code. There are various methods and packages available that are more 
#' secure; this package does not require you to use any one in particular.
#' 
#' WHAT IS THE API LIMIT??? For the same reason you are encouraged to break your request into
#' smaller chunks using the install dates and/or splitting up your
#' product Ids.
#' 
#' @param rev_product_ids A vector of Revenera product id's for which
#' you want active user data.
#' @param rev_session_id Session ID established by the connection to
#' Revenera API. This can be obtained with revenera_auth().
#' @param rev_username Revenera username.
#' @param event_type Choose type of event tracking, one of "lifetime", 
#' "basic", or "advanced".
#' @param product_properties_df Data frame with available properties 
#' for all product ids. Can obtain with the get_product_properties function.
#' @param desired_properties The property names of the metadata you want
#' to collect.
#' @param installed_start_date Date object for the starting date of 
#' product installations.
#' @param installed_end_date Date object for the ending date of 
#' product installations.
#' 
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom purrr "map_dfr"
#' @importFrom purrr "map_dfc"
#' @import httr
#' @import jsonlite
#' @importFrom tidyselect "all_of"
#' @importFrom tidyr "pivot_longer"
#' @importFrom tibble "tibble"
#' 
#' @return Data frame with selected properties for each Client Id.
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' rev_user <- "my_username"
#' rev_pwd <- "super_secret"
#' product_ids_list <- c("123", "456", "789")
#' session_id <- revenera_auth(rev_user, rev_pwd)  
#' product_properties <- get_product_properties(product_ids_list, session_id, rev_user)
#' sink("output_filename.txt") 
#' sink(stdout(), type = "message")
#' client_metadata <- get_client_metadata(product_ids_list, session_id, rev_user,
#' product_properties, c("Property1", "Property2"), start_date, end_date)
#' sink()
#' }


event_tracking <- function(rev_product_ids, rev_session_id, rev_username, event_type, product_properties_df, 
                           desired_properties, installed_start_date, installed_end_date) {
  
  . <- NA # prevent variable binding note for the dot in the get_by_product function
  
  if(tolower(event_type) == "basic"){
    get_by_product <- function(x, rev_date_type) {
      request_body <- list(
        user = rev_username,
        sessionId = rev_session_id,
        productId = x,
        startDate = rev_start_date,
        stopDate = rev_end_date
      )
      
    url_path <- "https://api.revulytics.com/reporting/eventTracking/basic/dataTable"
  }
  
    request <- httr::RETRY("POST",
                           url = url_path,
                           body = request_body,
                           encode = "json",
                           times = 4,
                           pause_min = 10,
                           terminate_on = NULL,
                           terminate_on_success = TRUE,
                           pause_cap = 5)
    
    check_status(request)
    
    request_content <- httr::content(request, "text", encoding = "ISO-8859-1")
    content_json <- jsonlite::fromJSON(request_content, flatten = TRUE)
    
    ## basic ##
    iteration_df <- as.data.frame(unlist(content_json$results)) %>%
      cbind(rownames(.)) %>%
      dplyr::rename(metric = 2, value = 1) %>%
      filter(!is.na(value))
    rownames(iteration_df) <- NULL
  
  }
}