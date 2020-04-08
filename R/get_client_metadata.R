#' Get All Properties a List of Product Ids
#' 
#' Returns all of the unique properties (standard and custom)
#' for each product id by property category.
#' 
#' It is not recommended that your username be stored directly in your
#' code. There are various methods and packages available that are more 
#' secure; this package does not require you to use any one in particular.
#' 
#' @param rev_product_ids A vector of revulytics product id's for which
#' you want active user data.
#' @param rev_session_id Session ID established by the connection to
#' Revulytics API. This can be obtained with revulytics_auth().
#' @param rev_username Revulytics username.
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
#' session_id <- revulytics_auth(rev_user, rev_pwd)  
#' product_properties <- get_product_properties(product_ids_list, session_id, rev_user)
#' }




# for the function, user should provide a list of the property_friendly_names (custom or regular)

RIGHT NOW THIS JUST DOES THE FIRST 200 FOR EACH PRODUCT. NEED TO GO BACK TO ONE PRODUCT, THEN WORK ON THE LOOPING

THIS ALSO IS PULLING PREV SNAGIT VERSION FOR EVERYTHING - IT SHOULDNT BE AVAILABLE

product_properties <- get_product_properties(prods, session_id, rev_user)

desired_properties <- c("Job To Be Done", "Previous Snagit Version", "License Key", "Revulytics Machine ID")

get_client_metadata <- function(rev_product_ids, rev_session_id, rev_username, desired_properties) {
  
  product_df_base <- tibble(revulytics_product_id = numeric(), client_id = character(),
                            property_friendly_name = character(), property_value = character())
  
  get_one_product_metadata <- function(a) {
  
    custom_property_names <- product_properties %>%
      filter(revulytics_product_id == a, property_friendly_name %in% desired_properties) %>%
      select(property_name) %>%
      pull()
    
    custom_property_friendly_names <- product_properties %>%
      filter(revulytics_product_id == a, property_friendly_name %in% desired_properties) %>%
      select(property_friendly_name) %>%
      pull()
    
    # print(custom_property_friendly_names)
    i <- 0
    
    keep_going <- TRUE
    
    while (keep_going == TRUE) {
      print(paste0("iteration ", i))
      
      i <- i + 1
      
      body <- paste0("{\"user\":\"trackerbird@techsmith.com\",\"sessionId\":\"",
                     session_id,
                     "\",\"productId\":",
                     a,
                     ",\"startAtClientId\":",
                     jsonlite::toJSON(ifelse(exists("content_json"), content_json$nextClientId, NA_character_), auto_unbox = TRUE),
                     ",\"globalFilters\":{\"dateInstalled\":{\"type\":\"dateRange\",\"min\":\"2020-03-01\", \"max\":\"2020-03-01\"}},",
                     paste0("\"properties\":", jsonlite::toJSON(array(c(custom_property_names)), auto_unbox = TRUE), "}"),
                     # ",\"properties\":[\"licenseKey\",\"C01\",\"C06\",\"machineId\"]}",
      sep = "")
      
      # print(cat(body))
      
      # request_body <- list(
      #   user = rev_user,
      #   sessionId = session_id,
      #   productId = a,
      #   startAtClientId = ifelse(exists("content_json"), content_json$nextClientId, NA_character_),
      #   properties = array(c(custom_property_names)),
      #   globalFilters = array(c("dateInstalled", list(list(type = "dateRange", min = "2020-03-01", max = "2020-03-02"))))
      #   # junk = list(list(a = "b"))
      # )
      
      # print(ifelse(exists("content_json"), content_json$nextClientId, NA_character_))
      
      # body <- jsonlite::toJSON(request_body, auto_unbox = TRUE)
      # print(cat(body))
      
      
      
      request <- httr::POST("https://api.revulytics.com/reporting/clientPropertyList",
                            body = body,
                            encode = "json")
      # print(request$status)
      request_content <- httr::content(request, "text", encoding = "ISO-8859-1")
      # get_text
      content_json <- jsonlite::fromJSON(request_content, flatten = TRUE)
      print(paste0("reachedEnd = ", content_json$reachedEnd))
      
      build_data_frame <- function(c){
        properties <- as.data.frame(content_json$results[c])
      }
      
      # print(length(content_json$results))
      
      product_df <- map_dfc(1:length(content_json$results), build_data_frame)
      # print(names(product_df))
      names(product_df)[2:length(content_json$results)] <- c(custom_property_friendly_names)
      # print(names(product_df))
      # print(custom_property_friendly_names)
      product_df2 <- product_df %>%
        pivot_longer(tidyselect::all_of(custom_property_friendly_names), names_to = "property_friendly_name", values_to = "property_value") %>%
        mutate(#license_key = if_else(licenseKey == "<NULL>", NA_character_, licenseKey),
               property_value = if_else(property_value == "<NULL>" | property_value == "", NA_character_, property_value),
               revulytics_product_id = a) %>%
        rename(client_id = clientId) %>%
        select(revulytics_product_id, client_id, property_friendly_name, property_value) %>%
        filter(!is.na(property_value))
      
      # print(head(product_df2))
      
      product_df_base <- bind_rows(product_df2, product_df_base)
      
      # print(head(product_df_base))
      
      keep_going <- ifelse(content_json$reachedEnd == "FALSE", TRUE, FALSE)
      print(paste0("keep_going = ", keep_going))
      
    }
    
    return(product_df_base)
  
  }
  
  all_products_df <- map_dfr(rev_product_ids, get_one_product_metadata)
  return(all_products_df)
  
}

cmdf <- get_client_metadata(prods, session_id, rev_user, c("Job To Be Done", "Previous Snagit Version", "License Key", "Revulytics Machine ID"))

