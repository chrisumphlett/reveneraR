#' Get Metadata on Client Ids for a List of Product Ids
#'
#' Returns metadata (what Revenera calls "properties") for every
#' Client Id installed during user-provided date range for all product
#' Ids in a list.
#'
#' It is not recommended that your username be stored directly in your
#' code. There are various methods and packages available that are more
#' secure; this package does not require you to use any one in particular.
#'
#' This API call can only return 200 Client Ids at a time. It will take a
#' long time to execute if you have many Client Ids, as the function will
#' submit requests to the API repeatedly; this may even result in a timeout
#' error from the server. In order to provide data for troubleshooting
#' this function will write a message to the console after each call.
#' It is recommended that you divert the console output to a text file.
#' You can do this in multiple ways, including with the sink function (see
#' example for how to do this).
#'
#' For the same reason you are encouraged to break your request into
#' smaller chunks using the install dates and/or splitting up your
#' product Ids.
#'
#' @param rev_product_ids A vector of Revenera product id's for which
#' you want active user data.
#' @param product_properties_df Data frame with available properties
#' for all product ids. Can obtain with the get_product_properties function.
#' @param desired_properties The property names of the metadata you want
#' to collect.
#' @param installed_start_date Date object for the starting date of
#' product installations.
#' @param installed_end_date Date object for the ending date of
#' product installations.
#' @param chatty The function can be chatty, sending a message to the console
#' for every iteration through a product Id. Many API calls may be required
#' and the console may get very long and it may slow down the execution.
#'
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom purrr
#' @import httr
#' @import jsonlite
#' @importFrom tidyr
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
#' product_properties <- get_product_properties(product_ids_list)
#' sink("output_filename.txt") # write out chatty messages to a file
#' sink(stdout(), type = "message")
#' client_metadata <- get_client_metadata(
#'   product_ids_list, product_properties, c("Property1", "Property2"),
#'   start_date, end_date, chatty = TRUE
#' )
#' sink()
#' }
#'
get_client_metadata <- function(rev_product_ids,
                                product_properties_df, desired_properties,
                                installed_start_date, installed_end_date,
                                chatty = FALSE) {

  #if an object with this name exists in the session, 
  #it will cause a problem further down
  if (exists("content_json")) {
    rm(content_json)
  }  
  
  final_df <- data.frame()

  get_one_product_metadata <- function(x) {
    if (chatty) {
      message(paste0("Starting product id ", x))
    }

    custom_property_names <- product_properties_df %>%
      filter(
        revenera_product_id == x,
        property_friendly_name %in% desired_properties
      ) %>%
      select(property_name) %>%
      pull()

    i <- 0

    keep_going <- TRUE

    while (keep_going == TRUE) {
      if (chatty) {
        message(paste0("iteration ", i))
      }

      i <- i + 1

      body <- paste0("{",
                     "\"startAtClientId\":",
                    jsonlite::toJSON(ifelse(exists("content_json"),
                      content_json$nextClientId,
                      NA_character_
                    ), auto_unbox = TRUE),
                    paste0(
                      ",\"globalFilters\":{\"dateInstalled\":",
                      "{\"type\":\"dateRange\",\"min\":\"",
                      installed_start_date,
                      "\",\"max\":\"",
                      installed_end_date,
                      "\"}},"
                    ),
                    paste0(
                      "\"properties\":",
                      jsonlite::toJSON(array(c(custom_property_names)),
                        auto_unbox = TRUE
                      ), "}"
                    ),
                    sep = ""
      )

      client_metadata_endpoint <- "reporting/clientPropertyList/"
      
      request <- httr::RETRY("POST",
                             url = paste0(base_url, client_metadata_endpoint, x),
                             add_headers(.headers = headers),
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
      # if there are not results for this product id, skip all of this
      if (length(content_json$result) > 0){
            if (chatty) {
          if (content_json$reachedEnd == "TRUE") {
            message("Reached end - no more clients")
          } else {
            message(paste0("nextClientId = ", content_json$nextClientId))
          }
        }
  
        build_data_frame <- function(c) {
          properties <- as.data.frame(content_json$result[c])
        }
  
        product_df <- purrr::map_dfc(
          seq_len(length(content_json$result)),
          build_data_frame
        ) %>%
          rename(client_id = clientId)
        names(product_df)[2:length(content_json$result)] <-
          c(desired_properties)
        
        # keep first date for each distinct property value
        client_df <- product_df %>%
          tidyr::pivot_longer(
            cols = -c("client_id"),
            names_to = "property_name",
            values_to = "property_value"
          ) %>%
          filter(!is.na(property_value) & property_value != "<NULL>") %>%
          mutate(revenera_product_id = as.character(x))
        
        final_df <- dplyr::bind_rows(final_df, client_df)
      } else {
        if (chatty) {
          message("No results for this product id")
        }
      }
      keep_going <- ifelse(content_json$reachedEnd == "FALSE", TRUE, FALSE)
    }
    return(final_df)
  }

  all_products_df <- purrr::map_dfr(rev_product_ids, get_one_product_metadata)
  return(all_products_df)
}
