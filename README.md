# reveneraR

Connect to Your Revenera (Revulytics) Data with R!

## The package has been re-named!

While I was developing the package Revulytics was acquired by Flexera, but retained its name. When I was virtually done with the package Flexera rebranded it as Flexera Usage Intelligence and then Revenera. This package/repo was formerly called revulyticsR (through version 0.0.3). Starting with dev version 0.0.3.9000 and the release of 0.1.0 to Cran and GitHub it will be known as reveneraR.

## Purpose

reveneraR facilitates making a connection to the Revulytics API and executing various queries. You can use it to get active users (daily, monthly, etc) or to query on various advanced events and get the results in tidy data frames.

## Installation

The development version can be installed from GitHub: `devtools::install_github("chrisumphlett/reveneraR")`.

## Usage

Version 1.0.0 made breaking changes in order to switch to v3 of the Revenera API. The information below is accurate for versions prior to that.

Authorization is done with `revenera_auth()`, using a cookie. This is done using your Revenera username and password. This periodically will need to be updated, I recommend you `logout()` first, then re-authenticate.

* `get_users()`. For a given period of time (a day, week, or month) Revenera's API summarizes and returns the number of new, active or lost users. With this function you can return daily, weekly, or monthly users for multiple product ids. For lost users the number of days of inactivity to be counted lost is set at 30 by default (but you can change), and the last date of activity is the lost date (you can choose it to be the last date plus the number of days of inactivity, the date it is considered lost).
* `get_categories_and_events()`. For a list of product ids get all of the categories and events that have been defined (and identify it each is a basic or advanced). This can then be passed into subsequent queries to pull data on multiple events.
* `get_product_properties()`. For a list of product ids get all of the product properties, both standard and custom. This can then be passed into `get_client_metadata()`.
* `get_client_metadata()`. For a list of product ids get selected properties for each client, which is essentially metadata.  This works by pulling all of the clients that are installed within specified date range.
* `get_daily_client_properties()` to pull daily values of properties for a product within a given date range.
* `get_raw_data_files()` to retrieve the list of raw data file exports if that add-on is enabled and the download URLs.


More info on the API is available at https://rui-api.redoc.ly/.
