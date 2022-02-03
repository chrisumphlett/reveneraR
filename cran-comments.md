## Changes in this version (compared to reveneraR 0.1.0)

* `styler` used to clean up formatting.
* If a product Id does not have any raw data files, instead of having an error when trying to retrieve the download URLs, that part is skipped in `get_raw_data_files()`.

## Test environments
 
* Developed on and tested with Windows 10 and R 4.1.
* Tested on development version of R with devtools::check_win_devel().
* Tested Fedora and Ubuntu Linux platforms with devtools::check_rhub().
 
## R CMD check results
 
0 errors √ | 0 warnings √ | 0 notes √
  
## No reverse dependencies