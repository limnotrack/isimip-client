# isimip 0.1.0

## New Features

* Initial release of the R port of the Python isimip-client library
* Implemented `ISIMIPClient` S4 class for interacting with ISIMIP Repository API
* Support for querying datasets and files from the ISIMIP repository
* Support for Files API v2 operations:
  * `select_bbox()` - Select data for a bounding box
  * `select_point()` - Select data for a point location
  * `mask_bbox()` - Mask data for a bounding box
  * `mask_country()` - Mask data for a country
  * `mask_landonly()` - Mask land-only areas
  * `mask_mask()` - Mask using custom mask file
  * `mask_shape()` - Mask using shapefile
  * `cutout_bbox()` - Cut out data for a bounding box
  * `cutout_point()` - Cut out data for a point location
  * `submit_job()` - Submit custom operation chains
* Support for Files API v1 operations (legacy):
  * `mask()` - Mask operation
  * `select()` - Select operation
  * `cutout()` - Cutout operation
* File download functionality with resume capability and checksum validation
* Comprehensive vignettes and documentation
* pkgdown website configuration
* GitHub Actions workflows for R-CMD-check, pkgdown, and test coverage

## Implementation Details

* Uses `httr2` for modern HTTP operations
* Uses `methods`/S4 for object-oriented design
* Uses `cli` for user-friendly console output
* Uses `fs` for cross-platform file operations
* Includes retry logic and error handling
* Supports authentication via username/password

## Acknowledgments

This package is a port of the original [Python isimip-client](https://github.com/ISI-MIP/isimip-client) developed by Jochen Klar.
