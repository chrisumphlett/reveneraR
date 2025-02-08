#' Get All Categories and Events for a List of Product Ids
#'
#' Returns all of the unique categories and events (basic and advanced)
#' for each product id.
#'
#' It is not recommended that your username be stored directly in your
#' code. There are various methods and packages available that are more
#' secure; this package does not require you to use any one in particular.
#'
#' @param rev_product_ids A vector of Revenera product id's for which
#' you want active user data.
#'
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom purrr "map_dfr"
#' @import httr
#' @import jsonlite
#'
#' @return Data frame with categories, events and event type by product id.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' rev_user <- "my_username"
#' rev_pwd <- "super_secret"
#' product_ids_list <- c("123", "456", "789")
#' session_id <- revenera_auth(rev_user, rev_pwd)
#' category_event <- get_categories_and_events(
#'   product_ids_list, session_id,
#'   rev_user
#' )
#' }
#'
get_categories_and_events <- function(rev_product_ids) {
  
  list_events_endpoint <- "event-tracking/"

  get_by_product <- function(x) {

    # body <- jsonlite::toJSON(request_body, auto_unbox = TRUE)
    request <- httr::RETRY("GET",
      url = paste0(base_url, list_events_endpoint, x),
      add_headers(.headers = headers),
      encode = "json",
      times = 4,
      pause_min = 10,
      terminate_on = NULL,
      terminate_on_success = TRUE,
      pause_cap = 5
    )

    check_status(request)

    request_content <- httr::content(request, "text", encoding = "ISO-8859-1")
    content_json <- jsonlite::fromJSON(request_content, flatten = TRUE)
    
    parse_json_into_df <- function(x) {
      category_name <- content_json$result$category[x]
      event_name <- as.data.frame(
        content_json$result$categoryEventNames[x]
      ) %>%
        cbind(category_name) %>%
        dplyr::mutate(category_name = as.character(category_name))
    }

    category_event <- purrr::map_dfr(seq_len(
      length(content_json$result$category)
    ), parse_json_into_df) %>%
      dplyr::mutate(
        event_type = case_when(
          advanced ~ "ADVANCED",
          basic ~ "BASIC",
          TRUE ~ "INACTIVE"
        ),
        date_first_seen = as.Date(dateFirstSeen),
        revenera_product_id = x
      ) %>%
      dplyr::select(
        revenera_product_id, category_name, eventName,
        event_type, date_first_seen
      ) %>%
      dplyr::rename(event_name = eventName)
  }

  category_event_by_prod <- purrr::map_dfr(rev_product_ids, get_by_product)
  return(category_event_by_prod)
}
