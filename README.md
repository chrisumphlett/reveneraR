# revulyticsR
Connect to Your Revulytics Data with R!

## Purpose
revulyticsR facilitates making a connection to the Revulytics API and executing various queries. You can use it to get active users (daily, monthly, etc) or to query on various advanced events and get the results in tidy data frames.

## Installation
The development version can be installed from GitHub: `devtools::install_github("chrisumphlett/revulyticsR")`.

## Usage
A session must first be established before querying the API. This is done using your Revulytics username and password with `revultyics_auth()`.

The current version has several functions for making requests to the API.

* `get_active_users()`. For a given period of time (a day, week, or month) Revulytics' API summarizes and returns the number of active users. With this function you can return daily, weekly, or monthly active users for multiple product ids.
* `get_categories_and_events()`. For a list of product ids get all of the categories and events that have been defined (and identify it each is a basic or advanced). This can then be passed into subsequent queries to pull data on multiple events.
* `get_product_properties()` created. For a list of product ids get all of the product properties, both standard and custom. This can then be passed into `get_client_metadata()`.
* `get_client_metadata()` created. For a list of product ids get selected properties for each client, which is essentially metadata.  This works by pulling all of the clients that are installed within specified date range.

You will need your own credentials to use the package. A workflow could be:

```
  rev_user <- "my_username"
  rev_pwd <- "super_secret"
  product_ids_list <- c("123", "456", "789")
  start_date <- lubridate::floor_date(Sys.Date(), unit = "months") - months(6)
  end_date <- Sys.Date() - 1
  session_id <- revulytics_auth(rev_user, rev_pwd)
  monthly_active_users <- get_active_users(product_ids_list, "month", start_date, end_date, session_id, rev_user)
  category_event <- get_categories_and_events(product_ids_list, session_id, rev_user)
  product_properties <- get_product_properties(product_ids_list, session_id, rev_user)
  client_metadata <- get_client_metadata(product_ids_list, session_id, rev_user, product_properties, c("Property1", "Property2"), start_date, end_date)
```

More info on the API is available at https://docs.flexera.com/ui551/report/Content/helplibrary/APIRoot.htm#product-intro_184013195_1066562.

## Revulytics is now known as Flexera Usage Intelligence

While I was developing the package Revulytics was acquired by Flexera, but retained its name. When I was virtually done with the package Flexera rebranded it as Flexera Usage Intelligence. I expect that Revulytics is what it will still be commonly called for some time by its customers (as it is at my company).