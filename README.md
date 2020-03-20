# revulyticsR
Connect To Your Revulytics Data With R!

## Purpose
revulyticsR facilitates making a connection to the Revulytics API and executing various queries. You can use it to get active users (daily, monthly, etc) or to query on various advanced events and get the results in tidy data frames.

## Installation
The development version can be installed from GitHub: `devtools::install_github("chrisumphlett/revulyticsR")`.

## Usage
A session must first be established before querying the API. This is done using your Revulytics username and password with `revultyics_auth()`.
The current version has one function for making requests to the API, `get_active_users()`. For a given period of time (a day, week, or month) Revulytics' API summarizes and returns the number of active users. With this function you can return daily, weekly, or monthly active users for multiple product ids.

You will need your own credentials to use the package. A workflow could be:

```
  rev_user <- "my_username"
  rev_pwd <- "super_secret"
  product_ids_list <- c("123", "456", "789")
  start_date <- lubridate::floor_date(Sys.Date(), unit = "months") - months(6)
  end_date <- Sys.Date() - 1
  session_id <- revulytics_auth(rev_user, rev_pwd)
  monthly_active_users <- get_active_users(product_ids_list, "month", start_date, end_date, session_id, rev_user)
```

More info on the API is available at https://devzone.revulytics.com/docs/API/.