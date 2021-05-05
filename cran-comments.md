## New package (sort of)

* This is an update to revulyticsR 0.0.3. The name of the company has changed multiple times and I have gone through and changed all references to the old name and changed the package name too. So this is the first submission of this package but most of it was in CRAN previously.
 
## Changes in this version (compared to revulyticsR 0.0.3)
* `get_users()` created as a more generalized function, and deprecated `get_active_users()` and `get_new_users()`. New function also facilitates getting lost users.
* All references to revulytics changed to revenera (except the api endpoint url which has not yet changed).

## Test environments
 
* Developed on and tested with Windows 10 and R 4.0.
* Tested on development version of R with devtools::check_win_devel().
* Testing Fedora and Ubuntu platforms with devtools::check_rhub().
 
## R CMD check results
 
0 errors √ | 0 warnings √ | 0 notes √
  
## No reverse dependencies