## Changes in this version (compared to reveneraR 0.1.1)

* Added the `chatty` parameter to `get_client_metadata()` and `get_daily_client_properties()`. This turns off the console messaging by default but allows the user to optionally turn it back on. This should save execution time on large runs.

## Test environments
 
* Developed on and tested with Windows 11 and R 4.1.
* Tested on development version of R with devtools::check_win_devel().
* Tested Fedora and Ubuntu Linux platforms with devtools::check_rhub().
 
## R CMD check results
 
0 errors √ | 0 warnings √ | 0 notes √
  
## No reverse dependencies