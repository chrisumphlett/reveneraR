#' #' Get Event Timeline Data
#' #' 
#' #' For a given frequency (daily, weekly, or monthly) Revulytics' API
#' #' summarizes and returns the occurrences of events for that period.
#' #' This request is done by product id and the events must be 
#' #' explicitly named in a list.
#' #' 
#' #' You can specify a start and end date but Revulytics does not store
#' #' an indefinite period of historical data. In my experience this is 
#' #' three years but I do not know if this varies on a product or client
#' #' level.
#' #' 
#' #' It is not recommended that your username be stored directly in your
#' #' code. There are various methods and packages available that are more 
#' #' secure; this package does not require you to use any one in particular.
#' #' 
#' #' @param rev_product_ids A vector of revulytics product id's for which
#' #' you want active user data.
#' #' @param rev_date_type Level of aggregation, Revulytics will accept
#' #' "day", "week", or "month".
#' #' @param rev_start_date Date formatted YYYY-MM-DD. Revulytics may give
#' #' an error if you try to go back too far.
#' #' @param rev_end_date Date formatted YYYY-MM-DD.
#' #' @param rev_session_id Session ID established by the connection to
#' #' Revulytics API. This can be obtained with revulytics_auth().
#' #' @param rev_username Revulytics username.
#' #' 
#' #' @import dplyr
#' #' @importFrom magrittr "%>%"
#' #' @importFrom purrr "map_dfr"
#' #' @import httr
#' #' @import jsonlite
#' #' 
#' #' @return Data frame with active users for each product id and
#' #' unique date within the range
#' #' 
#' #' @export
#' #' 
#' #' @examples
#' #' \dontrun{
#' #' rev_user <- "my_username"
#' #' rev_pwd <- "super_secret"
#' #' product_ids_list <- c("123", "456", "789")
#' #' start_date <- lubridate::floor_date(Sys.Date(), unit = "months") - months(6)
#' #' end_date <- Sys.Date() - 1
#' #' session_id <- revulytics_auth(rev_user, rev_pwd)  
#' #' monthly_active_users <- get_active_users(product_ids_list,
#' #' "month",
#' #' start_date,
#' #' end_date,
#' #' session_id,
#' #' rev_user)
#' #' }
#' #' 
#' #' 
#' 
#' # events <- list(list(category = "Capture", name = "Image Panoramic Capture"),
#' #                list(category = "Capture", name = "Clipboard Capture"))
#' # 
#' # # build equivalent of events from category_event df
#' # ce <- category_event %>%
#' #   filter(event_name %in% c("Clipboard Capture", "Image Panoramic Capture", "File Capture")) %>%
#' #   select(category_name, event_name) %>%
#' #   rename(category = category_name, name = event_name)
#' # 
#' # 
#' 
#' 
#' # events2 <- list(list(category = "Capture", name = "Image Panoramic Capture"),
#' #                list(category = "Capture", name = "Clipboard Capture"))
#' 
#' # prods2 <- c(prods, prods)
#' # x0<-1
#' 
#' # NEED TO DO THIS BY LICENSE TYPE. HAVE AN OPTIONAL DIMENSION
#' 
#' get_event_timeline <- function(rev_product_ids, rev_date_type, rev_start_date, rev_end_date, rev_session_id, rev_username){
#'   
#'   get_by_product <- function(x) {
#'     
#'     # print(x)
#'     
#'     build_events_list <- function(x0) {
#'       df <- filter(category_event, revulytics_product_id == x)
#'       vv <- c(df$category_name[x0], df$event_name[x0])
#'       names(vv) <- c("category", "name")
#'       lv <- as.list(vv)
#'     }
#' 
#'     loops_required <- ceiling(nrow(category_event) / 10)
#'     loops_required <- 2
#'     
#'     for (i in 1:loops_required) {
#'     
#'       start <- (i - 1) * 10 + 2
#'       end <- start + 9
#'       print(paste0("start: ", start, " - end: ", end))
#'       events <- map(start:end, build_events_list)
#'       
#'       print(events)
#'       
#'       # print("A")
#'       
#'       request_body <- list(
#'         user = rev_username,
#'         sessionId = rev_session_id,
#'         productId = x,
#'         startDate = rev_start_date,
#'         stopDate = rev_end_date,
#'         dateSplit = "month",
#'         dataView = "usageCounts",
#'         events = events
#'       )
#'       
#'       body <- jsonlite::toJSON(request_body, auto_unbox = TRUE)
#'       request <- httr::POST("https://api.revulytics.com/reporting/eventTracking/basic/timeline",
#'                             body = body,
#'                             encode = "json")
#'       print(request$status_code)
#'       request_content <- httr::content(request, "text", encoding = "ISO-8859-1")
#'       content_json <- jsonlite::fromJSON(request_content, flatten = TRUE)
#'       
#'       # print(content_json)
#'       
#'       parse_json_into_df <- function(x1){
#'         event_count <- as.data.frame(content_json$results[x1]) %>%
#'           rename(category_name = 1, event_name = 2, value = 3) %>%
#'           mutate(event_date = names(content_json$results[x1]))
#'       }
#'       
#'       event_counts <- map_dfr(1:length(content_json$results), parse_json_into_df) %>%
#'         mutate(revulytics_product_id = x)
#'       
#'       # print(head(event_counts))
#'       
#'     }
#'     
#'   
#'   }
#'   
#'   events_by_prod <- purrr::map_dfr(rev_product_ids, get_by_product)
#'   return(events_by_prod)
#'   
#' }
#' 
#' timeline <- get_event_timeline(prods, "month", start_date, end_date, session_id, rev_user)
