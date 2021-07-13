#' Get All Properties for a List of Product Ids
#'
#' Returns all of the unique properties (standard and custom)
#' for each product id by property category.
#'
#' It is not recommended that your username be stored directly in your
#' code. There are various methods and packages available that are more
#' secure; this package does not require you to use any one in particular.
#'
#' @param rev_product_ids A vector of Revenera product id's for which
#' you want active user data.
#' @param rev_session_id Session ID established by the connection to
#' Revenera API. This can be obtained with revenera_auth().
#' @param rev_username Revenera username.
#'
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom purrr "map_dfr"
#' @importFrom purrr "map_df"
#' @import httr
#' @import jsonlite
#'
#' @return Data frame with properties and property attributes by
#' product id.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' rev_user <- "my_username"
#' rev_pwd <- "super_secret"
#' product_ids_list <- c("123", "456", "789")
#' session_id <- revenera_auth(rev_user, rev_pwd)
#' product_properties <- get_product_properties(
#'   product_ids_list,
#'   session_id, rev_user
#' )
#' }
#'
get_product_properties <- function(rev_product_ids, rev_session_id,
                                   rev_username) {
  get_one_product_properties <- function(x) {
    request_body <- list(
      user = rev_username,
      sessionId = rev_session_id,
      productId = x
    )

    body <- jsonlite::toJSON(request_body, auto_unbox = TRUE)
    request <- httr::RETRY("POST",
      url = paste0(
        "https://api.revulytics.com/",
        "meta/productProperties"
      ),
      body = body,
      encode = "json",
      times = 4,
      pause_min = 10,
      terminate_on = NULL,
      terminate_on_success = TRUE,
      pause_cap = 5
    )

    # nolint start
    check_status(request)
    # nolint end

    request_content <- httr::content(request, "text", encoding = "ISO-8859-1")
    content_json <- jsonlite::fromJSON(request_content, flatten = TRUE)

    build_data_frame <- function(y) {
      properties_category <- content_json$results$category[y]
      properties <- as.data.frame(content_json$results$properties[y]) %>%
        cbind(properties_category) %>%
        mutate(
          properties_category = as.character(.data$properties_category),
          revenera_product_id = x,
          property_name = as.character(.data$name),
          property_friendly_name = as.character(.data$friendlyName),
          filter_type = as.character(.data$filterType),
          data_type = as.character(.data$dataType),
          supports_regex_f = as.character(if_else(.data$supportsRegex,
            1, 0
          )),
          supports_meta_f = as.character(if_else(.data$supportsMeta,
            1, 0
          )),
          supports_null_f = as.character(if_else(.data$supportsNull,
            1, 0
          ))
        ) %>%
        select(
          .data$revenera_product_id, .data$properties_category,
          .data$property_name, .data$property_friendly_name,
          .data$filter_type, .data$data_type, .data$supports_regex_f,
          .data$supports_meta_f, .data$supports_null_f
        )
    }

    product_df <- map_df(
      seq_len(length(content_json$results$category)),
      build_data_frame
    )
  }

  all_products_df <- purrr::map_dfr(rev_product_ids, get_one_product_properties)
  return(all_products_df)
}
