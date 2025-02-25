## Updating to 1.0.1 to fix a bug in the 1.0.0 release

* `get_users()` would return an error in certain circumstances. This has been fixed.

## Test environments
 
* Developed on and tested with Windows 11 and R 4.4.
* Tested on development version of R with devtools::check_win_devel().
* Tested Linux, Mac, and Windows platforms with rhub::rhub_check().
 
## R CMD check results
 
0 errors √ | 0 warnings √ | 0 notes √
  
## No reverse dependencies