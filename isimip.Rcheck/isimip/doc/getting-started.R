## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----setup, eval = FALSE------------------------------------------------------
#  # Install from GitHub
#  devtools::install_github("limnotrack/isimip-client")
#  
#  # Load the package
#  library(isimip)

## -----------------------------------------------------------------------------
#  library(isimip)
#  
#  # Create a client with default settings
#  client <- ISIMIPClient()

## -----------------------------------------------------------------------------
#  # Use custom URLs
#  client <- ISIMIPClient(
#    data_url = "https://data.isimip.org/api/v1",
#    files_api_url = "https://files.isimip.org/api/v2",
#    files_api_version = "v2"
#  )
#  
#  # Add authentication if needed
#  client <- ISIMIPClient(
#    auth = list(username = "your_username", password = "your_password")
#  )

## -----------------------------------------------------------------------------
#  # Search for datasets
#  datasets <- datasets(client, query = "gfdl-esm4 ssp370 pr")
#  
#  # Check the number of results
#  cat("Found", datasets$count, "datasets\n")
#  
#  # View first result
#  str(datasets$results[[1]])

## -----------------------------------------------------------------------------
#  datasets <- datasets(client,
#    simulation_round = "ISIMIP3b",
#    product = "InputData",
#    climate_forcing = "gfdl-esm4",
#    climate_scenario = "ssp370",
#    climate_variable = "pr"
#  )

## -----------------------------------------------------------------------------
#  datasets <- datasets(client,
#    path = "ISIMIP3b/InputData/climate/atmosphere/bias-adjusted/global/daily/ssp370/GFDL-ESM4/"
#  )

## -----------------------------------------------------------------------------
#  # Get first page
#  page1 <- datasets(client,
#    query = "gfdl-esm4 ssp370 pr",
#    paginate = TRUE,
#    page = 1,
#    page_size = 10
#  )
#  
#  # Get second page
#  page2 <- datasets(client,
#    query = "gfdl-esm4 ssp370 pr",
#    paginate = TRUE,
#    page = 2,
#    page_size = 10
#  )

## -----------------------------------------------------------------------------
#  # Search for files
#  files <- files(client,
#    simulation_round = "ISIMIP3b",
#    climate_forcing = "gfdl-esm4",
#    climate_scenario = "ssp370",
#    climate_variable = "pr"
#  )
#  
#  # Get a specific file by ID
#  file_detail <- file(client, pk = "some-uuid-here")

## -----------------------------------------------------------------------------
#  # Select data for a bounding box
#  result <- select_bbox(client,
#    paths = c(
#      "ISIMIP3b/InputData/climate/atmosphere/bias-adjusted/global/daily/ssp370/GFDL-ESM4/gfdl-esm4_r1i1p1f1_w5e5_ssp370_pr_global_daily_2015_2020.nc"
#    ),
#    west = -20, east = 20,
#    south = -10, north = 10,
#    poll = 4  # Poll every 4 seconds for job completion
#  )
#  
#  # Select data for a point
#  result <- select_point(client,
#    paths = c("path/to/file.nc"),
#    lat = 6.25, lon = 18.17,
#    poll = 4
#  )

## -----------------------------------------------------------------------------
#  # Mask to a bounding box
#  result <- mask_bbox(client,
#    paths = c("path/to/file.nc"),
#    west = -20, east = 20,
#    south = -10, north = 10,
#    poll = 4
#  )
#  
#  # Mask to a country (using ISO 3166-1 alpha-3 code)
#  result <- mask_country(client,
#    paths = c("path/to/file.nc"),
#    country = "bra",  # Brazil
#    poll = 4
#  )
#  
#  # Mask to land areas only
#  result <- mask_landonly(client,
#    paths = c("path/to/file.nc"),
#    poll = 4
#  )

## -----------------------------------------------------------------------------
#  # Cut out a rectangular region
#  result <- cutout_bbox(client,
#    paths = c("path/to/file.nc"),
#    west = 5.8, east = 10.6,
#    south = 45.8, north = 47.9,
#    poll = 4
#  )
#  
#  # Cut out data at a point
#  result <- cutout_point(client,
#    paths = c("path/to/file.nc"),
#    lat = 46.5, lon = 8.0,
#    poll = 4
#  )

## -----------------------------------------------------------------------------
#  result <- mask_shape(client,
#    paths = c("path/to/file.nc"),
#    shape = "~/data/shapes/countries.zip",
#    layer = 5,  # Layer index or name
#    poll = 4
#  )

## -----------------------------------------------------------------------------
#  operations <- list(
#    list(
#      operation = "cutout_bbox",
#      bbox = c(5.8, 10.6, 45.8, 47.9)
#    ),
#    list(
#      operation = "mask_country",
#      country = "che"  # Switzerland
#    )
#  )
#  
#  result <- submit_job(client,
#    paths = c("path/to/file.nc"),
#    operations = operations,
#    poll = 4
#  )

## -----------------------------------------------------------------------------
#  if (!is.null(result$file_url)) {
#    # Download to current directory
#    download(client, result$file_url)
#  
#    # Download to specific directory
#    download(client, result$file_url, path = "downloads")
#  
#    # Download with validation and extraction
#    download(client,
#      result$file_url,
#      path = "downloads",
#      validate = TRUE,  # Validate checksum
#      extract = TRUE    # Extract zip files
#    )
#  }

## -----------------------------------------------------------------------------
#  # Check job status
#  cat("Job ID:", result$id, "\n")
#  cat("Status:", result$status, "\n")
#  
#  if (result$status == "finished") {
#    cat("Download URL:", result$file_url, "\n")
#    cat("Metadata:", result$meta, "\n")
#  }

## -----------------------------------------------------------------------------
#  # Create v1 client
#  client_v1 <- ISIMIPClient(
#    files_api_url = "https://files.isimip.org/api/v1",
#    files_api_version = "v1"
#  )
#  
#  # Use v1 methods
#  result <- client_v1$select(
#    paths = c("path/to/file.nc"),
#    bbox = c(-10, 10, -20, 20)  # south, north, west, east
#  )
#  
#  result <- client_v1$mask(
#    paths = c("path/to/file.nc"),
#    country = "bra"
#  )
#  
#  result <- client_v1$cutout(
#    paths = c("path/to/file.nc"),
#    bbox = c(-10, 10, -20, 20)
#  )

## ----error = TRUE-------------------------------------------------------------
#  # Trying to use v2 method with v1 client
#  client_v1 <- ISIMIPClient(files_api_version = "v1")
#  client_v1$select_bbox(
#    paths = c("path/to/file.nc"),
#    west = -20, east = 20, south = -10, north = 10
#  )
#  # Error: This method is only available in v2 of the Files API

