## Release summary
 
* Improved handling of API request errors.
* `get_new_users()` created. For a given period of time (a day, week, or month) Revulytics' API summarizes and returns the number of new users. With this function you can return daily, weekly, or monthly new users for multiple product ids.
* Removed unnecessary messages being printed to console by `get_daily_client_properties`.
* `get_raw_data_files` created to retrieve the list of available raw data files and download URL for each file.

## Test environments
 
* Developed on and tested with Windows 10 and R 4.0.
* Tested on development version of R with devtools::check_win_devel().
* Testing Fedora and Ubuntu platforms with devtools::check_rhub().
 
## R CMD check results
 
0 errors √ | 0 warnings √ | 0 notes √
  
## No reverse dependencies