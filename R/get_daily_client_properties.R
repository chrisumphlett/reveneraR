#' Get Daily Property Values for All Clients for a List of Product Ids
#'
#' Returns the list of daily client properties for all the client Ids
#' installed during a user provided date range for all the Product Ids.
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
#' @param rev_product_ids A vector of Revenera product id.
#' @param product_properties_df Data frame with available properties
#' for all product ids. Can obtain with the get_product_properties function.
#' @param desired_properties The property names of the metadata you want
#' to collect.
#' @param installed_start_date Date object for the starting date of
#' product installations.
#' @param installed_end_date Date object for the ending date of
#' product installations.
#' @param daily_start_date Date object for the starting date of desired
#' properties of the product.
#' @param daily_end_date Date object for the ending date of desired
#' properties of the product.
#' @param chatty The function can be chatty, sending a message to the console
#' for every iteration through a product Id. Many API calls may be required
#' and the console may get very long and it may slow down the execution.
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
#' product_properties <- get_product_properties(product_ids_list)
#' sink("output_filename.txt")
#' sink(stdout(), type = "message")
#' daily_client_properties <- get_daily_client_properties(product_ids_list,
#'   product_properties, c("Property1", "Property2"), start_date, end_date,
#'   daily_start_date = "01-01-2020", daily_end_date = "01-31-2020"
#' )
#' sink()
#' }
#'
get_daily_client_properties <- function(rev_product_ids,
                                        product_properties_df,
                                        desired_properties,
                                        installed_start_date,
                                        installed_end_date,
                                        daily_start_date, daily_end_date,
                                        chatty = FALSE) {
  
  #if an object with this name exists in the session, 
  #it will cause a problem further down
  if (exists("content_json")) {
    rm(content_json)
  }

  trialpurchase_df <- data.frame()
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
                       "\"retDailyData\":{\"startDate\":\"",
                       daily_start_date,
                       "\",\"stopDate\":\"",
                       daily_end_date,
                       "\",\"properties\":",
                       jsonlite::toJSON(array(c(custom_property_names)),
                                        auto_unbox = TRUE
                       ),
                       "}}"
                     ),
                     sep = ""
      )

      client_property_endpoint <- "reporting/clientPropertyList/"
      
      request <- httr::RETRY("POST",
        url = paste0(base_url, client_property_endpoint, x),
        add_headers(.headers = headers),
        body = body,
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
        )
        colnames(product_df)[1] <- "client_id"
        daily_propertytype <- product_df$dailyData
        
        daily_propertytype_flat <- bind_rows(daily_propertytype,
                                             .id = "column_label"
        ) %>%
          mutate(
            id = as.numeric(column_label),
            property_date = as.Date(date)
          ) %>%
          select(-column_label, -date)

        names(daily_propertytype_flat)[seq_len(
          length(desired_properties))
        ] <-
          c(desired_properties)
        message("got here4")
        suppressMessages(
          client_df <- purrr::map_dfc(
            seq_len(nrow(product_df)),
            ~ (nrow(product_df[[3]][[.x]]))
          ) %>%
            tidyr::pivot_longer(everything(), names_to = "a", values_to = "b") %>%
            cbind(product_df) %>%
            dplyr::filter(b != 0) %>%
            dplyr::select(3) %>%
            dplyr::mutate(id = row_number())
        )
        message("got here5")
        client_df_merged <- merge(
          x = daily_propertytype_flat, y = client_df,
          by = "id", all.x = TRUE
        ) %>%
          tidyr::pivot_longer(
            cols = -c("id", "property_date", "client_id"),
            names_to = "property_name",
            values_to = "property_value"
          ) %>%
          select(-id)
        message("got here6")
        final_df <- client_df_merged %>%
          dplyr::group_by(client_id, property_value) %>%
          dplyr::slice(which.min(as.Date(property_date, "%Y-%m-%d"))) %>%
          dplyr::ungroup()
        
        trialpurchase_df <- dplyr::bind_rows(final_df, trialpurchase_df) %>%
          dplyr::mutate(revenera_product_id = product_iter)
        
      } else {
        if (chatty) {
          message("No results for this product id")
        }
      }

      keep_going <- ifelse(content_json$reachedEnd == "FALSE", TRUE, FALSE)
    }

    return(trialpurchase_df)
  }

  all_products_df <- purrr::map_dfr(rev_product_ids, get_one_product_metadata)
  return(all_products_df)
}
