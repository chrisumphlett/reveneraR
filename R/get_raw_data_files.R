#' Get Raw Data Files
#'
#' Retrieves a list of raw data file exports that are available for a
#' list of product IDs and the download URL for each file.
#'
#' Raw data files are an add-on service available through Revenera. If
#' these files are available they can be downloaded manually from the
#' user portal, or downloaded via R. This function uses the API to
#' first retrieve the list of files, and then get the download URL for
#' each file.
#'
#' It is not recommended that your username be stored directly in your
#' code. There are various methods and packages available that are more
#' secure; this package does not require you to use any one in particular.
#'
#' @param rev_product_ids A vector of Revenera product id's for which
#' you want active user data.
#' @param days_back How many days back to go to generate download URLs. Limiting
#' this, if not all files are needed, will significantly reduce execution time.
#'
#' @import dplyr
#' @importFrom magrittr "%>%"
#' @importFrom purrr map_df map_dfr
#' @import httr
#' @import jsonlite
#' @importFrom rlang .data
#'
#' @return Data frame with available files and URLs.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' rev_user <- "my_username"
#' rev_pwd <- "super_secret"
#' logout(rev_user, rev_pwd)
#' Sys.sleep(30)
#' revenera_auth(rev_user, rev_pwd)
#' product_ids_list <- c("123", "456", "789")
#' urls_df <- get_raw_data_files(product_ids_list, days_back = 3)
#' urls <- urls_df %>% pull(download_url)
#' file_names <-  urls_df %>%   pull(file_name)
#' file_list <- dplyr::pull(files_df, var = file_name)
#' dl_and_write <- function(u, f) {
#'   download.file(u, mode = "wb", destfile = f)
#'   upload_blob(cont, src = f, dest = paste0("/zip/", f))
#'   file.remove(f)
#' }
#' purrr::map2(urls, file_names, purrr::possibly(dl_and_write, "Download Error"))
#' }

get_raw_data_files <- function(rev_product_ids, days_back) {
  . <- NA # prevent variable binding note for the dot
  
  file_list_endpoint <- "rawEvents/download/listFiles/"

  get_by_product <- function(x) {
    get_files_request <- httr::RETRY("GET",
      url = paste0(base_url, file_list_endpoint, x),
      add_headers(.headers = headers),
      encode = "json",
      times = 4,
      pause_min = 10,
      terminate_on = NULL,
      terminate_on_success = TRUE,
      pause_cap = 5
    )
    check_status(get_files_request)
    files_list <- httr::content(get_files_request)$fileList
      
    files_df <- files_list %>%
      purrr::map_df(~ tibble(fileName = .x$fileName, fileDate = .x$fileDate))
    
    if(nrow(files_df) > 0) {
      files_vector <- files_df %>%
        dplyr::filter(as.Date(.data$fileDate) >= Sys.Date() - days_back) %>%
        dplyr::pull(1)
     
      get_download_urls <- function(filenm) {
        download_body <- list(
          fileName = filenm
        )
        download_endpoint <- "rawEvents/download/getDownloadUrl/"
        download_request <- httr::RETRY("POST",
          url = paste0(base_url, download_endpoint, x),
          add_headers(.headers = headers),
          body = jsonlite::toJSON(download_body, auto_unbox = TRUE),
          encode = "json",
          times = 4,
          pause_min = 10,
          terminate_on = NULL,
          terminate_on_success = TRUE,
          pause_cap = 5
        )
        request_content <- httr::content(download_request, "text",
          encoding = "ISO-8859-1"
        )
        content_json <- jsonlite::fromJSON(request_content, flatten = TRUE)
        file_url_df <- as.data.frame(content_json[[1]]) %>%
          dplyr::mutate(file_name = filenm) %>%
          dplyr::left_join(files_df, by = c("file_name" = "fileName")) %>%
          dplyr::rename(download_url = 1, file_date = 3)
        return(file_url_df)
      }
      
      all_file_url_df <- purrr::map_dfr(files_vector, get_download_urls)
      
      return(all_file_url_df)
    }
    return(all_file_url_df)
  }
  all_pids_df <- purrr::map_dfr(rev_product_ids, get_by_product)
  return(all_pids_df)
}
