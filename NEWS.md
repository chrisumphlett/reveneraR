# reveneraR 1.0.1

* Fixed bug in `get_users()` where it would not parse the api result correctly (and result in an error).

# reveneraR 1.0.0

* Package completely rewritten to use v3 of the Revenera API. 
* Authorization method changed to a cookie-based authentication and now the credentials are only needed for the initial authorization function. Credential parameters and session IDs are removed from all of the data-retrieving functions.
* R version 4.3.0+ required. Package dependencies also updated.
* `get_raw_data_files()` has a new parameter, `days_back`, which allows users to specify how many days back they want to generate download URL's for raw data files. Retrieving the URL's significantly slowed down this function and can now be avoided if far less than 90 days is desired.
* Added `group_by` parameter to `get_users()`.
* Removed `get_active_users()`, and `get_new_users()`, as they are redundant with `get_users()`.
* Fixed issue where `get_daily_client_properties()` was returning the country property without it being requested.
* `chatty` will provide better information to the user when a product requested returns no results, and, the error is handled so that the function does not return an error and stop.

# reveneraR 0.1.2.9999

* Current development version.

# reveneraR 0.1.2

* Added the `chatty` parameter to `get_client_metadata()` and `get_daily_client_properties()`. This turns off the console messaging by default but allows the user to optionally turn it back on. This should save execution time on large runs.
* Suppressed the message in every iteration produced by `get_client_metadata()` about columns without names.

# reveneraR 0.1.1

* `styler` used to clean up formatting.
* If a product Id does not have any raw data files, instead of having an error when trying to retrieve the download URLs, that part is skipped in `get_raw_data_files()`.

# reveneraR 0.1.0

* Package name changed to reflect change in ownership of the software.
* `get_users()` created to replace `get_new_users()` and `get_active_users()`. These use the same API endpoint with one parameter changed. `get_users()` also returns lost users.
* `get_new_users()` and `get_active_users()` are deprecated but will not be removed so that this is not a breaking change.
* `optional_json` parameter added to `get_users()` to allow users to incorporate optional parameters per the API documentation.


# revulyticsR 0.0.3

* `get_new_users()` created. For a given period of time (a day, week, or month) Revulytics' API summarizes and returns the number of new users. With this function you can return daily, weekly, or monthly new users for multiple product ids.
* Removed unnecessary messages being printed to console by `get_daily_client_properties`.
* `get_raw_data_files()` to retrieve the list of available raw data files and download URL for each file.

# revulyticsR 0.0.2

* Added a `RETRY()` to safely retry an API request certain number of times before returning a error code.
* Added `get_daily_client_properties()` to pull daily values of properties for a product within a given date range.

# revulyticsR 0.0.1

* `get_active_users()` created. For a given period of time (a day, week, or month) Revulytics' API summarizes and returns the number of active users. With this function you can return daily, weekly, or monthly active users for multiple product ids.
* `get_categories_and_events()` created. For a list of product ids get all of the categories and events that have been defined (and identify it each is a basic or advanced). This can then be passed into subsequent queries to pull data on multiple events.
* `get_product_properties()` created. For a list of product ids get all of the product properties, both standard and custom. This can then be passed into `get_client_metadata()`.
* `get_client_metadata()` created. For a list of product ids get selected properties for each client, which is essentially metadata.  This works by pulling all of the clients that are installed within specified date range.

# revulyticsR 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
* Created initial package structure.
* Authentication/login method created.