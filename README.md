
<!-- README.md is generated from README.Rmd. Please edit that file -->

# isimip

<!-- badges: start -->
[![R-CMD-check](https://github.com/limnotrack/isimip-client/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/limnotrack/isimip-client/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/limnotrack/isimip-client/branch/main/graph/badge.svg)](https://app.codecov.io/gh/limnotrack/isimip-client?branch=main)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/limnotrack/isimip-client/blob/main/LICENSE)
<!-- badges: end -->

A *thin* client library to use the API of the [ISIMIP repository](https://data.isimip.org) using R and httr2.

This is an R port of the [Python isimip-client](https://github.com/ISI-MIP/isimip-client) library.

## Installation

You can install the development version of isimip from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("limnotrack/isimip-client")
```

## Usage

The package provides the `ISIMIPClient` R6 class which can be used in scripts or notebooks:

```r
library(isimip)

# Create a client instance
client <- ISIMIPClient$new()
```

### Querying Datasets and Files

The methods of the `client` object can be used to perform queries to the ISIMIP Repository:

```r
# Search the ISIMIP repository using a search string
response <- client$datasets(query = "gfdl-esm4 ssp370 pr")

# Search the ISIMIP repository for a specific subtree
response <- client$datasets(
  path = "ISIMIP3b/InputData/climate/atmosphere/bias-adjusted/global/daily/ssp370/GFDL-ESM4/"
)

# Search using specifiers
response <- client$datasets(
  simulation_round = "ISIMIP3b",
  product = "InputData",
  climate_forcing = "gfdl-esm4",
  climate_scenario = "ssp370",
  climate_variable = "pr"
)
```

The response object is a list of the form:

```r
list(
  count = 1001,
  next = "https://data.isimip.org/api/v1/datasets/?page=2&...",
  previous = NULL,
  results = list(...)
)
```

### Processing Operations

The ISIMIP Repository provides a "Configure download" feature for operations on files before downloading. Common use cases include cutting out specific regions or masking data:

```r
# Select data for a bounding box
response <- client$select_bbox(
  paths = c("path/to/file1.nc", "path/to/file2.nc"),
  west = -20, east = 20, south = -10, north = 10,
  poll = 4  # Poll every 4 seconds
)

# Select data for a point location
response <- client$select_point(
  paths = c("path/to/file.nc"),
  lat = 6.25, lon = 18.17,
  poll = 4
)

# Mask data for a bounding box
response <- client$mask_bbox(
  paths = c("path/to/file.nc"),
  west = -20, east = 20, south = -10, north = 10,
  poll = 4
)

# Mask data for a country
response <- client$mask_country(
  paths = c("path/to/file.nc"),
  country = "bra",  # Brazil
  poll = 4
)

# Mask land-only areas
response <- client$mask_landonly(
  paths = c("path/to/file.nc"),
  poll = 4
)

# Cut out a rectangular area
response <- client$cutout_bbox(
  paths = c("path/to/file.nc"),
  west = -20, east = 20, south = -10, north = 10,
  poll = 4
)
```

### Custom Operations

You can chain multiple operations using `submit_job()`:

```r
# ISIMIP3a high resolution precipitation input data
paths <- c(
  "ISIMIP3a/InputData/climate/atmosphere/obsclim/global/daily/historical/CHELSA-W5E5/chelsa-w5e5_obsclim_pr_30arcsec_global_daily_201612.nc"
)

# Chain of operations
operations <- list(
  list(
    operation = "cutout_bbox",
    bbox = c(5.800, 10.600, 45.800, 47.900)  # west, east, south, north
  ),
  list(
    operation = "mask_country",
    country = "che"  # Switzerland
  )
)

# Submit job and poll every 4 seconds
response <- client$submit_job(
  paths = paths,
  operations = operations,
  poll = 4
)
```

### Downloading Results

Once a job is finished, you can download the result:

```r
if (!is.null(response$file_url)) {
  client$download(response$file_url, path = "downloads")
}
```

## Files API Versions

The package supports both v1 and v2 of the Files API. By default, v2 is used:

```r
# Use v2 (default)
client <- ISIMIPClient$new()

# Use v1 (legacy)
client <- ISIMIPClient$new(
  files_api_url = "https://files.isimip.org/api/v1",
  files_api_version = "v1"
)
```

## Authentication

If you need authentication:

```r
client <- ISIMIPClient$new(
  auth = list(username = "your_username", password = "your_password")
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Citation

If you use this package in your research, please cite:

```
Klar, J. (2025). isimip-client: A thin client library for the ISIMIP Repository API.
https://github.com/ISI-MIP/isimip-client
```

## Acknowledgments

This R package is a port of the original [Python isimip-client](https://github.com/ISI-MIP/isimip-client) developed by Jochen Klar.
