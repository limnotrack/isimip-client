#' ISIMIP API Client
#'
#' @description
#' An R6 class that provides methods to interact with the ISIMIP Repository API.
#' This client allows you to query datasets and files, submit processing jobs,
#' and download results from the ISIMIP climate impact data repository.
#'
#' @export
#' @importFrom R6 R6Class
#' @importFrom httr2 request req_perform req_headers req_auth_basic resp_body_json
#' @importFrom httr2 req_body_json req_body_multipart req_retry resp_check_status
#' @importFrom cli cli_alert_info cli_alert_success cli_abort cli_progress_bar cli_progress_update
#' @importFrom fs path path_expand dir_create file_size
#' @importFrom digest digest
#' @importFrom jsonlite fromJSON
#'
#' @examples
#' \dontrun{
#' # Create a client instance
#' client <- ISIMIPClient$new()
#'
#' # Search for datasets
#' datasets <- client$datasets(query = "gfdl-esm4 ssp370 pr")
#'
#' # Search for files
#' files <- client$files(
#'   simulation_round = "ISIMIP3b",
#'   climate_forcing = "gfdl-esm4",
#'   climate_scenario = "ssp370"
#' )
#'
#' # Select data for a bounding box
#' result <- client$select_bbox(
#'   paths = c("path/to/file1.nc", "path/to/file2.nc"),
#'   west = -20, east = 20, south = -10, north = 10,
#'   poll = 4
#' )
#'
#' # Download the result
#' if (!is.null(result$file_url)) {
#'   client$download(result$file_url, path = "downloads")
#' }
#' }
ISIMIPClient <- R6::R6Class(
  "ISIMIPClient",
  public = list(
    #' @field data_url Base URL for the ISIMIP data API
    data_url = NULL,
    
    #' @field files_api_url Base URL for the ISIMIP files API
    files_api_url = NULL,
    
    #' @field files_api_version Version of the files API to use
    files_api_version = NULL,
    
    #' @field auth Authentication credentials (list with username and password)
    auth = NULL,
    
    #' @field headers Additional HTTP headers
    headers = NULL,
    
    #' @description
    #' Create a new ISIMIP client
    #'
    #' @param data_url Base URL for the ISIMIP data API
    #' @param files_api_url Base URL for the ISIMIP files API
    #' @param files_api_version Version of the files API ("v1" or "v2")
    #' @param auth Optional authentication (list with username and password)
    #' @param headers Optional additional HTTP headers
    #'
    #' @return A new `ISIMIPClient` object
    initialize = function(
      data_url = "https://data.isimip.org/api/v1",
      files_api_url = "https://files.isimip.org/api/v2",
      files_api_version = "v2",
      auth = NULL,
      headers = NULL
    ) {
      self$data_url <- data_url
      self$files_api_url <- files_api_url
      self$files_api_version <- files_api_version
      self$auth <- auth
      self$headers <- headers %||% list()
    },
    
    #' @description
    #' Search for datasets in the ISIMIP repository
    #'
    #' @param ... Additional query parameters (e.g., query, path, simulation_round, etc.)
    #' @param paginate If TRUE, return paginated response; if FALSE, fetch all results
    #' @param page Page number for pagination
    #' @param page_size Number of results per page
    #'
    #' @return A list containing dataset information
    datasets = function(..., paginate = FALSE, page = NULL, page_size = NULL) {
      params <- list(...)
      if (!is.null(page)) params$page <- page
      if (!is.null(page_size)) params$page_size <- page_size
      
      private$list_resource("/datasets", params, paginate)
    },
    
    #' @description
    #' Get details for a specific dataset
    #'
    #' @param pk Dataset ID (UUID)
    #'
    #' @return A list containing dataset details
    dataset = function(pk) {
      private$retrieve_resource("/datasets", pk)
    },
    
    #' @description
    #' Search for files in the ISIMIP repository
    #'
    #' @param ... Additional query parameters
    #' @param paginate If TRUE, return paginated response; if FALSE, fetch all results
    #' @param page Page number for pagination
    #' @param page_size Number of results per page
    #'
    #' @return A list containing file information
    files = function(..., paginate = FALSE, page = NULL, page_size = NULL) {
      params <- list(...)
      if (!is.null(page)) params$page <- page
      if (!is.null(page_size)) params$page_size <- page_size
      
      private$list_resource("/files", params, paginate)
    },
    
    #' @description
    #' Get details for a specific file
    #'
    #' @param pk File ID (UUID)
    #'
    #' @return A list containing file details
    file = function(pk) {
      private$retrieve_resource("/files", pk)
    },
    
    #' @description
    #' Submit a processing job to the Files API (v2)
    #'
    #' @param paths Character vector of file paths to process
    #' @param operations List of operations to perform
    #' @param uploads Optional list of file paths to upload
    #' @param poll Polling interval in seconds (NULL for no polling)
    #'
    #' @return A list containing job information
    submit_job = function(paths, operations, uploads = NULL, poll = NULL) {
      private$check_version("v2")
      private$post_job(
        list(paths = paths, operations = operations),
        uploads = uploads,
        poll = poll
      )
    },
    
    #' @description
    #' Select data for a bounding box (v2)
    #'
    #' @param paths Character vector of file paths
    #' @param west Western longitude
    #' @param east Eastern longitude
    #' @param south Southern latitude
    #' @param north Northern latitude
    #' @param mean Compute spatial mean (default: FALSE)
    #' @param csv Output as CSV (default: FALSE)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    select_bbox = function(paths, west, east, south, north, 
                          mean = FALSE, csv = FALSE, poll = NULL) {
      private$check_version("v2")
      private$post_job(
        list(
          paths = paths,
          operations = list(
            list(
              operation = "select_bbox",
              bbox = c(west, east, south, north),
              compute_mean = mean,
              output_csv = csv
            )
          )
        ),
        poll = poll
      )
    },
    
    #' @description
    #' Select data for a point location (v2)
    #'
    #' @param paths Character vector of file paths
    #' @param lat Latitude
    #' @param lon Longitude
    #' @param csv Output as CSV (default: FALSE)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    select_point = function(paths, lat, lon, csv = FALSE, poll = NULL) {
      private$check_version("v2")
      private$post_job(
        list(
          paths = paths,
          operations = list(
            list(
              operation = "select_point",
              point = c(lat, lon),
              output_csv = csv
            )
          )
        ),
        poll = poll
      )
    },
    
    #' @description
    #' Mask data for a bounding box (v2)
    #'
    #' @param paths Character vector of file paths
    #' @param west Western longitude
    #' @param east Eastern longitude
    #' @param south Southern latitude
    #' @param north Northern latitude
    #' @param mean Compute spatial mean (default: FALSE)
    #' @param csv Output as CSV (default: FALSE)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    mask_bbox = function(paths, west, east, south, north,
                        mean = FALSE, csv = FALSE, poll = NULL) {
      private$check_version("v2")
      private$post_job(
        list(
          paths = paths,
          operations = list(
            list(
              operation = "mask_bbox",
              bbox = c(west, east, south, north),
              compute_mean = mean,
              output_csv = csv
            )
          )
        ),
        poll = poll
      )
    },
    
    #' @description
    #' Mask data for a country (v2)
    #'
    #' @param paths Character vector of file paths
    #' @param country Country code
    #' @param mean Compute spatial mean (default: FALSE)
    #' @param csv Output as CSV (default: FALSE)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    mask_country = function(paths, country, mean = FALSE, csv = FALSE, poll = NULL) {
      private$check_version("v2")
      private$post_job(
        list(
          paths = paths,
          operations = list(
            list(
              operation = "mask_country",
              country = country,
              compute_mean = mean,
              output_csv = csv
            )
          )
        ),
        poll = poll
      )
    },
    
    #' @description
    #' Mask land-only areas (v2)
    #'
    #' @param paths Character vector of file paths
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    mask_landonly = function(paths, poll = NULL) {
      private$check_version("v2")
      private$post_job(
        list(
          paths = paths,
          operations = list(
            list(operation = "mask_landonly")
          )
        ),
        poll = poll
      )
    },
    
    #' @description
    #' Mask data using a custom mask file (v2)
    #'
    #' @param paths Character vector of file paths
    #' @param mask Path to mask file
    #' @param var Variable name in mask file
    #' @param mean Compute spatial mean (default: FALSE)
    #' @param csv Output as CSV (default: FALSE)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    mask_mask = function(paths, mask, var, mean = FALSE, csv = FALSE, poll = NULL) {
      private$check_version("v2")
      mask_path <- fs::path(mask)
      private$post_job(
        list(
          paths = paths,
          operations = list(
            list(
              operation = "mask_mask",
              mask = basename(mask_path),
              compute_mean = mean,
              output_csv = csv,
              var = var
            )
          )
        ),
        uploads = list(mask_path),
        poll = poll
      )
    },
    
    #' @description
    #' Mask data using a shapefile (v2)
    #'
    #' @param paths Character vector of file paths
    #' @param shape Path to shapefile
    #' @param layer Layer number or name
    #' @param mean Compute spatial mean (default: FALSE)
    #' @param csv Output as CSV (default: FALSE)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    mask_shape = function(paths, shape, layer, mean = FALSE, csv = FALSE, poll = NULL) {
      private$check_version("v2")
      shape_path <- fs::path(shape)
      mask_name <- paste0(tools::file_path_sans_ext(basename(shape_path)), ".nc")
      var_name <- paste0("m_", layer)
      
      private$post_job(
        list(
          paths = paths,
          operations = list(
            list(
              operation = "create_mask",
              shape = basename(shape_path),
              mask = mask_name
            ),
            list(
              operation = "mask_mask",
              mask = mask_name,
              compute_mean = mean,
              output_csv = csv,
              var = var_name
            )
          )
        ),
        uploads = list(shape_path),
        poll = poll
      )
    },
    
    #' @description
    #' Cut out data for a bounding box (v2)
    #'
    #' @param paths Character vector of file paths
    #' @param west Western longitude
    #' @param east Eastern longitude
    #' @param south Southern latitude
    #' @param north Northern latitude
    #' @param mean Compute spatial mean (default: FALSE)
    #' @param csv Output as CSV (default: FALSE)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    cutout_bbox = function(paths, west, east, south, north,
                          mean = FALSE, csv = FALSE, poll = NULL) {
      private$check_version("v2")
      private$post_job(
        list(
          paths = paths,
          operations = list(
            list(
              operation = "cutout_bbox",
              bbox = c(west, east, south, north),
              compute_mean = mean,
              output_csv = csv
            )
          )
        ),
        poll = poll
      )
    },
    
    #' @description
    #' Cut out data for a point location (v2)
    #'
    #' @param paths Character vector of file paths
    #' @param lat Latitude
    #' @param lon Longitude
    #' @param csv Output as CSV (default: FALSE)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    cutout_point = function(paths, lat, lon, csv = FALSE, poll = NULL) {
      private$check_version("v2")
      private$post_job(
        list(
          paths = paths,
          operations = list(
            list(
              operation = "cutout_point",
              point = c(lat, lon),
              output_csv = csv
            )
          )
        ),
        poll = poll
      )
    },
    
    #' @description
    #' Download a file from the ISIMIP repository
    #'
    #' @param url URL of the file to download
    #' @param path Directory to save the file (default: current directory)
    #' @param validate Validate file checksum (default: FALSE)
    #' @param extract Extract zip files (default: FALSE)
    #'
    #' @return Path to the downloaded file (invisibly)
    download = function(url, path = NULL, validate = FALSE, extract = FALSE) {
      private$download_file(url, path, validate, extract)
    },
    
    # Legacy v1 API methods
    
    #' @description
    #' Mask operation (Files API v1)
    #'
    #' @param paths Character vector of file paths
    #' @param country Country code (optional)
    #' @param bbox Bounding box as c(south, north, west, east) (optional)
    #' @param landonly Mask land only (optional)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    mask = function(paths, country = NULL, bbox = NULL, landonly = NULL, poll = NULL) {
      private$check_version("v1")
      
      payload <- list(paths = if (is.list(paths)) paths else list(paths))
      
      if (!is.null(country)) {
        payload$task <- "mask_country"
        payload$country <- country
      } else if (!is.null(bbox)) {
        payload$task <- "mask_bbox"
        payload$bbox <- bbox
      } else if (!is.null(landonly)) {
        payload$task <- "mask_landonly"
      }
      
      private$post_job(payload, poll = poll)
    },
    
    #' @description
    #' Cutout operation (Files API v1)
    #'
    #' @param paths Character vector of file paths
    #' @param bbox Bounding box as c(south, north, west, east)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    cutout = function(paths, bbox, poll = NULL) {
      private$check_version("v1")
      
      payload <- list(
        task = "cutout_bbox",
        bbox = bbox,
        paths = if (is.list(paths)) paths else list(paths)
      )
      
      private$post_job(payload, poll = poll)
    },
    
    #' @description
    #' Select operation (Files API v1)
    #'
    #' @param paths Character vector of file paths
    #' @param country Country code (optional)
    #' @param bbox Bounding box as c(south, north, west, east) (optional)
    #' @param point Point as c(lat, lon) (optional)
    #' @param poll Polling interval in seconds
    #'
    #' @return A list containing job information
    select = function(paths, country = NULL, bbox = NULL, point = NULL, poll = NULL) {
      private$check_version("v1")
      
      payload <- list(paths = if (is.list(paths)) paths else list(paths))
      
      if (!is.null(country)) {
        payload$task <- "select_country"
        payload$country <- country
      } else if (!is.null(bbox)) {
        payload$task <- "select_bbox"
        payload$bbox <- bbox
      } else if (!is.null(point)) {
        payload$task <- "select_point"
        payload$point <- point
      }
      
      private$post_job(payload, poll = poll)
    }
  ),
  
  private = list(
    max_results = 1000,
    page_size = 100,
    
    # Build a request object with authentication and headers
    build_request = function(url) {
      req <- httr2::request(url)
      
      # Add headers
      if (length(self$headers) > 0) {
        req <- httr2::req_headers(req, !!!self$headers)
      }
      
      # Add authentication
      if (!is.null(self$auth)) {
        req <- httr2::req_auth_basic(
          req,
          self$auth$username,
          self$auth$password
        )
      }
      
      req
    },
    
    # Parse response and handle errors
    parse_response = function(resp) {
      tryCatch({
        httr2::resp_check_status(resp)
        httr2::resp_body_json(resp)
      }, error = function(e) {
        cli::cli_abort("API request failed: {e$message}")
      })
    },
    
    # GET request
    get = function(url, params = NULL) {
      cli::cli_alert_info("GET {url}")
      
      req <- private$build_request(url)
      
      if (!is.null(params) && length(params) > 0) {
        req <- httr2::req_url_query(req, !!!params, .multi = "comma")
      }
      
      req <- httr2::req_retry(req, max_tries = 3)
      resp <- httr2::req_perform(req)
      
      private$parse_response(resp)
    },
    
    # POST request
    post = function(url, data) {
      cli::cli_alert_info("POST {url}")
      
      req <- private$build_request(url)
      req <- httr2::req_body_json(req, data, auto_unbox = TRUE)
      req <- httr2::req_retry(req, max_tries = 3)
      
      resp <- httr2::req_perform(req)
      private$parse_response(resp)
    },
    
    # Build resource URL
    build_url = function(resource_url, pk = NULL) {
      url <- paste0(trimws(self$data_url, whitespace = "/"), 
                   trimws(resource_url, whitespace = "/"), "/")
      
      if (!is.null(pk)) {
        url <- paste0(url, pk, "/")
      }
      
      url
    },
    
    # List resources
    list_resource = function(resource_url, params = list(), paginate = FALSE) {
      url <- private$build_url(resource_url)
      response <- private$get(url, params)
      
      if (paginate) {
        return(response)
      } else {
        results <- response$results
        
        while (length(results) < private$max_results && !is.null(response$`next`)) {
          response <- private$get(response$`next`)
          results <- c(results, response$results)
        }
        
        return(results)
      }
    },
    
    # Retrieve a single resource
    retrieve_resource = function(resource_url, pk) {
      url <- private$build_url(resource_url, pk)
      private$get(url)
    },
    
    # Check API version
    check_version = function(version) {
      if (self$files_api_version != version) {
        cli::cli_abort(
          "This method is only available in {version} of the Files API. 
          Please set files_api_version='{version}'."
        )
      }
    },
    
    # Post a job to the Files API
    post_job = function(data, uploads = NULL, poll = NULL) {
      cli::cli_alert_info("Submitting job...")
      
      if (is.null(uploads)) {
        req <- private$build_request(self$files_api_url)
        req <- httr2::req_body_json(req, data, auto_unbox = TRUE)
      } else {
        # Handle file uploads
        req <- private$build_request(self$files_api_url)
        
        # Create multipart form data
        parts <- list(data = jsonlite::toJSON(data, auto_unbox = TRUE))
        
        for (upload_path in uploads) {
          expanded_path <- as.character(fs::path_expand(upload_path))
          
          if (!file.exists(expanded_path)) {
            cli::cli_abort("Upload file not found: {upload_path}")
          }
          
          parts[[basename(expanded_path)]] <- httr2::curl_file(expanded_path)
        }
        
        req <- httr2::req_body_multipart(req, !!!parts)
      }
      
      resp <- httr2::req_perform(req)
      job <- private$parse_response(resp)
      
      if (!is.null(job)) {
        private$log_job(job)
        
        if (!is.null(poll) && job$status %in% c("queued", "started")) {
          Sys.sleep(poll)
          return(private$get_job(job$job_url, poll))
        }
      }
      
      job
    },
    
    # Get job status
    get_job = function(job_url, poll = NULL) {
      req <- private$build_request(job_url)
      req <- httr2::req_retry(req, max_tries = 3)
      resp <- httr2::req_perform(req)
      job <- private$parse_response(resp)
      
      if (!is.null(job)) {
        private$log_job(job)
        
        if (!is.null(poll) && job$status %in% c("queued", "started")) {
          Sys.sleep(poll)
          return(private$get_job(job$job_url, poll))
        }
      }
      
      job
    },
    
    # Log job information
    log_job = function(job) {
      if (job$status == "finished") {
        cli::cli_alert_success(
          "Job {job$id} {job$status} - file_url: {job$file_url}"
        )
      } else {
        cli::cli_alert_info("Job {job$id} {job$status}")
      }
    },
    
    # Download file
    download_file = function(url, path = NULL, validate = FALSE, extract = FALSE) {
      # Parse filename from URL
      file_name <- basename(httr2::url_parse(url)$path)
      
      # Determine save path
      save_dir <- if (is.null(path)) getwd() else fs::path_expand(path)
      fs::dir_create(save_dir, recurse = TRUE)
      file_path <- fs::path(save_dir, file_name)
      
      cli::cli_alert_info("Downloading {url} to {file_path}")
      
      # Check if file exists for resume
      headers <- self$headers
      if (file.exists(file_path)) {
        file_size <- fs::file_size(file_path)
        headers$Range <- paste0("bytes=", file_size, "-")
      }
      
      # Download
      req <- httr2::request(url)
      if (length(headers) > 0) {
        req <- httr2::req_headers(req, !!!headers)
      }
      
      tryCatch({
        req <- httr2::req_retry(req, max_tries = 3)
        resp <- httr2::req_perform(req, path = file_path)
        
        if (validate) {
          private$validate_download(url, file_path, file_name)
        }
        
        if (extract && tools::file_ext(file_path) == "zip") {
          cli::cli_alert_info("Extracting {file_path}")
          utils::unzip(file_path, exdir = save_dir)
        }
        
        cli::cli_alert_success("Download complete: {file_path}")
        invisible(file_path)
      }, error = function(e) {
        if (grepl("416", e$message)) {
          cli::cli_alert_success("File already complete: {file_path}")
          invisible(file_path)
        } else {
          cli::cli_abort("Download failed: {e$message}")
        }
      })
    },
    
    # Validate downloaded file
    validate_download = function(url, file_path, file_name) {
      # Get JSON metadata
      json_url <- paste0(
        sub("[^/]+$", "", url),
        tools::file_path_sans_ext(file_name), ".json"
      )
      
      resp <- httr2::req_perform(private$build_request(json_url))
      json_data <- httr2::resp_body_json(resp)
      
      # Compute checksum
      checksum <- digest::digest(file_path, algo = "sha512", file = TRUE)
      
      # Validate
      if (!grepl(file_name, json_data$path, fixed = TRUE)) {
        cli::cli_abort("Path validation failed")
      }
      
      if (checksum != json_data$checksum) {
        cli::cli_abort(
          "Checksum mismatch: {checksum} != {json_data$checksum}"
        )
      }
      
      cli::cli_alert_success("File validation successful")
    }
  )
)

# Null-default operator
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
