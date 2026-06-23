#' ISIMIP API Client
#'
#' @description
#' An S4 class that provides methods to interact with the ISIMIP Repository API.
#' This client allows you to query datasets and files, submit processing jobs,
#' and download results from the ISIMIP climate impact data repository.
#'
#' @slot data_url Character scalar. Base URL for the ISIMIP data API.
#' @slot files_api_url Character scalar. Base URL for the ISIMIP files API.
#' @slot files_api_version Character scalar. Version of the files API to use.
#' @slot auth List. Authentication credentials.
#' @slot headers List. Additional HTTP headers.
#'
#' @exportClass ISIMIPClient
#' @import methods
#' @importFrom httr2 request req_perform req_headers req_auth_basic resp_body_json
#' @importFrom httr2 req_body_json req_body_multipart req_retry resp_check_status
#' @importFrom cli cli_alert_info cli_alert_success cli_abort cli_progress_bar cli_progress_update
#' @importFrom fs path path_expand dir_create file_size
#' @importFrom digest digest
#' @importFrom jsonlite fromJSON
#' @importFrom curl form_file
#'
#' @examples
#' \dontrun{
#' # Create a client instance
#' client <- ISIMIPClient()
#'
#' # Search for datasets
#' datasets <- datasets(client, query = "gfdl-esm4 ssp370 pr")
#'
#' # Search for files
#' files <- files(
#'   client,
#'   simulation_round = "ISIMIP3b",
#'   climate_forcing = "gfdl-esm4",
#'   climate_scenario = "ssp370"
#' )
#'
#' # Select data for a bounding box
#' result <- select_bbox(
#'   client,
#'   paths = c("path/to/file1.nc", "path/to/file2.nc"),
#'   west = -20, east = 20, south = -10, north = 10,
#'   poll = 4
#' )
#'
#' # Download the result
#' if (!is.null(result$file_url)) {
#'   download(client, result$file_url, path = "downloads")
#' }
#' }
methods::setClass(
  "ISIMIPClient",
  slots = c(
    data_url = "character",
    files_api_url = "character",
    files_api_version = "character",
    auth = "list",
    headers = "list"
  ),
  prototype = list(
    data_url = "https://data.isimip.org/api/v1",
    files_api_url = "https://files.isimip.org/api/v2",
    files_api_version = "v2",
    auth = list(),
    headers = list()
  ),
  validity = function(object) {
    if (length(object@data_url) != 1L) {
      return("'data_url' must be a character scalar")
    }
    if (length(object@files_api_url) != 1L) {
      return("'files_api_url' must be a character scalar")
    }
    if (length(object@files_api_version) != 1L) {
      return("'files_api_version' must be a character scalar")
    }
    TRUE
  }
)

#' Create a new ISIMIP client
#'
#' @param data_url Base URL for the ISIMIP data API
#' @param files_api_url Base URL for the ISIMIP files API
#' @param files_api_version Version of the files API ("v1" or "v2")
#' @param auth Optional authentication (list with username and password)
#' @param headers Optional additional HTTP headers
#'
#' @return A new `ISIMIPClient` object
#' @export
ISIMIPClient <- function(
  data_url = "https://data.isimip.org/api/v1",
  files_api_url = "https://files.isimip.org/api/v2",
  files_api_version = "v2",
  auth = NULL,
  headers = NULL
) {
  methods::new(
    "ISIMIPClient",
    data_url = data_url,
    files_api_url = files_api_url,
    files_api_version = files_api_version,
    auth = auth %||% list(),
    headers = headers %||% list()
  )
}

#' @export
methods::setGeneric(
  "datasets",
  function(object, ..., paginate = FALSE, page = NULL, page_size = NULL) {
    standardGeneric("datasets")
  }
)

#' @export
methods::setGeneric("dataset", function(object, pk) {
  standardGeneric("dataset")
})

#' @export
methods::setGeneric(
  "files",
  function(object, ..., paginate = FALSE, page = NULL, page_size = NULL) {
    standardGeneric("files")
  }
)

#' @export
methods::setGeneric("file", function(object, pk) {
  standardGeneric("file")
})

#' @export
methods::setGeneric(
  "submit_job",
  function(object, paths, operations, uploads = NULL, poll = NULL) {
    standardGeneric("submit_job")
  }
)

#' @export
methods::setGeneric(
  "select_bbox",
  function(object, paths, west, east, south, north, mean = FALSE, csv = FALSE, poll = NULL) {
    standardGeneric("select_bbox")
  }
)

#' @export
methods::setGeneric(
  "select_point",
  function(object, paths, lat, lon, csv = FALSE, poll = NULL) {
    standardGeneric("select_point")
  }
)

#' @export
methods::setGeneric(
  "mask_bbox",
  function(object, paths, west, east, south, north, mean = FALSE, csv = FALSE, poll = NULL) {
    standardGeneric("mask_bbox")
  }
)

#' @export
methods::setGeneric(
  "mask_country",
  function(object, paths, country, mean = FALSE, csv = FALSE, poll = NULL) {
    standardGeneric("mask_country")
  }
)

#' @export
methods::setGeneric(
  "mask_landonly",
  function(object, paths, poll = NULL) {
    standardGeneric("mask_landonly")
  }
)

#' @export
methods::setGeneric(
  "mask_mask",
  function(object, paths, mask, var, mean = FALSE, csv = FALSE, poll = NULL) {
    standardGeneric("mask_mask")
  }
)

#' @export
methods::setGeneric(
  "mask_shape",
  function(object, paths, shape, layer, mean = FALSE, csv = FALSE, poll = NULL) {
    standardGeneric("mask_shape")
  }
)

#' @export
methods::setGeneric(
  "cutout_bbox",
  function(object, paths, west, east, south, north, mean = FALSE, csv = FALSE, poll = NULL) {
    standardGeneric("cutout_bbox")
  }
)

#' @export
methods::setGeneric(
  "cutout_point",
  function(object, paths, lat, lon, csv = FALSE, poll = NULL) {
    standardGeneric("cutout_point")
  }
)

#' @export
methods::setGeneric(
  "download",
  function(object, url, path = NULL, validate = FALSE, extract = FALSE) {
    standardGeneric("download")
  }
)

#' @export
methods::setGeneric(
  "mask",
  function(object, paths, country = NULL, bbox = NULL, landonly = NULL, poll = NULL) {
    standardGeneric("mask")
  }
)

#' @export
methods::setGeneric("cutout", function(object, paths, bbox, poll = NULL) {
  standardGeneric("cutout")
})

#' @export
methods::setGeneric(
  "select",
  function(object, paths, country = NULL, bbox = NULL, point = NULL, poll = NULL) {
    standardGeneric("select")
  }
)

#' @describeIn ISIMIPClient Search for datasets in the ISIMIP repository.
methods::setMethod(
  "datasets",
  signature(object = "ISIMIPClient"),
  function(object, ..., paginate = FALSE, page = NULL, page_size = NULL) {
    params <- list(...)
    if (!is.null(page)) params$page <- page
    if (!is.null(page_size)) params$page_size <- page_size

    .list_resource(object, "/datasets", params, paginate)
  }
)

#' @describeIn ISIMIPClient Get details for a specific dataset.
methods::setMethod(
  "dataset",
  signature(object = "ISIMIPClient"),
  function(object, pk) {
    .retrieve_resource(object, "/datasets", pk)
  }
)

#' @describeIn ISIMIPClient Search for files in the ISIMIP repository.
methods::setMethod(
  "files",
  signature(object = "ISIMIPClient"),
  function(object, ..., paginate = FALSE, page = NULL, page_size = NULL) {
    params <- list(...)
    if (!is.null(page)) params$page <- page
    if (!is.null(page_size)) params$page_size <- page_size

    .list_resource(object, "/files", params, paginate)
  }
)

#' @describeIn ISIMIPClient Get details for a specific file.
methods::setMethod(
  "file",
  signature(object = "ISIMIPClient"),
  function(object, pk) {
    .retrieve_resource(object, "/files", pk)
  }
)

#' @describeIn ISIMIPClient Submit a processing job to the Files API (v2).
methods::setMethod(
  "submit_job",
  signature(object = "ISIMIPClient"),
  function(object, paths, operations, uploads = NULL, poll = NULL) {
    .check_version(object, "v2")
    .post_job(
      object,
      list(paths = paths, operations = operations),
      uploads = uploads,
      poll = poll
    )
  }
)

#' @describeIn ISIMIPClient Select data for a bounding box (v2).
methods::setMethod(
  "select_bbox",
  signature(object = "ISIMIPClient"),
  function(object, paths, west, east, south, north, mean = FALSE, csv = FALSE, poll = NULL) {
    .check_version(object, "v2")
    .post_job(
      object,
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
  }
)

#' @describeIn ISIMIPClient Select data for a point location (v2).
methods::setMethod(
  "select_point",
  signature(object = "ISIMIPClient"),
  function(object, paths, lat, lon, csv = FALSE, poll = NULL) {
    .check_version(object, "v2")
    .post_job(
      object,
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
  }
)

#' @describeIn ISIMIPClient Mask data for a bounding box (v2).
methods::setMethod(
  "mask_bbox",
  signature(object = "ISIMIPClient"),
  function(object, paths, west, east, south, north, mean = FALSE, csv = FALSE, poll = NULL) {
    .check_version(object, "v2")
    .post_job(
      object,
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
  }
)

#' @describeIn ISIMIPClient Mask data for a country (v2).
methods::setMethod(
  "mask_country",
  signature(object = "ISIMIPClient"),
  function(object, paths, country, mean = FALSE, csv = FALSE, poll = NULL) {
    .check_version(object, "v2")
    .post_job(
      object,
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
  }
)

#' @describeIn ISIMIPClient Mask land-only areas (v2).
methods::setMethod(
  "mask_landonly",
  signature(object = "ISIMIPClient"),
  function(object, paths, poll = NULL) {
    .check_version(object, "v2")
    .post_job(
      object,
      list(
        paths = paths,
        operations = list(list(operation = "mask_landonly"))
      ),
      poll = poll
    )
  }
)

#' @describeIn ISIMIPClient Mask data using a custom mask file (v2).
methods::setMethod(
  "mask_mask",
  signature(object = "ISIMIPClient"),
  function(object, paths, mask, var, mean = FALSE, csv = FALSE, poll = NULL) {
    .check_version(object, "v2")
    mask_path <- fs::path(mask)
    .post_job(
      object,
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
  }
)

#' @describeIn ISIMIPClient Mask data using a shapefile (v2).
methods::setMethod(
  "mask_shape",
  signature(object = "ISIMIPClient"),
  function(object, paths, shape, layer, mean = FALSE, csv = FALSE, poll = NULL) {
    .check_version(object, "v2")
    shape_path <- fs::path(shape)
    mask_name <- paste0(tools::file_path_sans_ext(basename(shape_path)), ".nc")
    var_name <- paste0("m_", layer)

    .post_job(
      object,
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
  }
)

#' @describeIn ISIMIPClient Cut out data for a bounding box (v2).
methods::setMethod(
  "cutout_bbox",
  signature(object = "ISIMIPClient"),
  function(object, paths, west, east, south, north, mean = FALSE, csv = FALSE, poll = NULL) {
    .check_version(object, "v2")
    .post_job(
      object,
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
  }
)

#' @describeIn ISIMIPClient Cut out data for a point location (v2).
methods::setMethod(
  "cutout_point",
  signature(object = "ISIMIPClient"),
  function(object, paths, lat, lon, csv = FALSE, poll = NULL) {
    .check_version(object, "v2")
    .post_job(
      object,
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
  }
)

#' @describeIn ISIMIPClient Download a file from the ISIMIP repository.
methods::setMethod(
  "download",
  signature(object = "ISIMIPClient"),
  function(object, url, path = NULL, validate = FALSE, extract = FALSE) {
    .download_file(object, url, path, validate, extract)
  }
)

#' @describeIn ISIMIPClient Mask operation (Files API v1).
methods::setMethod(
  "mask",
  signature(object = "ISIMIPClient"),
  function(object, paths, country = NULL, bbox = NULL, landonly = NULL, poll = NULL) {
    .check_version(object, "v1")

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

    .post_job(object, payload, poll = poll)
  }
)

#' @describeIn ISIMIPClient Cutout operation (Files API v1).
methods::setMethod(
  "cutout",
  signature(object = "ISIMIPClient"),
  function(object, paths, bbox, poll = NULL) {
    .check_version(object, "v1")

    payload <- list(
      task = "cutout_bbox",
      bbox = bbox,
      paths = if (is.list(paths)) paths else list(paths)
    )

    .post_job(object, payload, poll = poll)
  }
)

#' @describeIn ISIMIPClient Select operation (Files API v1).
methods::setMethod(
  "select",
  signature(object = "ISIMIPClient"),
  function(object, paths, country = NULL, bbox = NULL, point = NULL, poll = NULL) {
    .check_version(object, "v1")

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

    .post_job(object, payload, poll = poll)
  }
)

methods::setMethod(
  "$",
  signature(x = "ISIMIPClient"),
  function(x, name) {
    if (name %in% methods::slotNames(x)) {
      return(methods::slot(x, name))
    }

    method_names <- c(
      "datasets", "dataset", "files", "file", "submit_job",
      "select_bbox", "select_point", "mask_bbox", "mask_country",
      "mask_landonly", "mask_mask", "mask_shape", "cutout_bbox",
      "cutout_point", "download", "mask", "cutout", "select"
    )

    if (name %in% method_names) {
      return(function(...) get(name, mode = "function", inherits = TRUE)(x, ...))
    }

    cli::cli_abort("Unknown field or method: {name}")
  }
)

.build_request <- function(object, url) {
  req <- httr2::request(url)

  if (length(object@headers) > 0) {
    req <- httr2::req_headers(req, !!!object@headers)
  }

  if (length(object@auth) > 0) {
    req <- httr2::req_auth_basic(
      req,
      object@auth$username,
      object@auth$password
    )
  }

  req
}

.parse_response <- function(object, resp) {
  tryCatch(
    {
      httr2::resp_check_status(resp)
      httr2::resp_body_json(resp)
    },
    error = function(e) {
      cli::cli_abort("API request failed: {e$message}")
    }
  )
}

.get <- function(object, url, params = NULL) {
  cli::cli_alert_info("GET {url}")

  req <- .build_request(object, url)

  if (!is.null(params) && length(params) > 0) {
    req <- httr2::req_url_query(req, !!!params, .multi = "comma")
  }

  req <- httr2::req_retry(req, max_tries = 3)
  resp <- httr2::req_perform(req)

  .parse_response(object, resp)
}

.post <- function(object, url, data) {
  cli::cli_alert_info("POST {url}")

  req <- .build_request(object, url)
  req <- httr2::req_body_json(req, data, auto_unbox = TRUE)
  req <- httr2::req_retry(req, max_tries = 3)

  resp <- httr2::req_perform(req)
  .parse_response(object, resp)
}

.build_url <- function(object, resource_url, pk = NULL) {
  url <- paste0(
    trimws(object@data_url, whitespace = "/"),
    "/",
    trimws(resource_url, whitespace = "/"),
    "/"
  )

  if (!is.null(pk)) {
    url <- paste0(url, pk, "/")
  }

  url
}

.list_resource <- function(object, resource_url, params = list(), paginate = FALSE) {
  url <- .build_url(object, resource_url)
  response <- .get(object, url, params)

  if (paginate) {
    return(response)
  }

  results <- response$results
  while (length(results) < 1000L && !is.null(response$`next`)) {
    response <- .get(object, response$`next`)
    results <- c(results, response$results)
  }

  results
}

.retrieve_resource <- function(object, resource_url, pk) {
  url <- .build_url(object, resource_url, pk)
  .get(object, url)
}

.check_version <- function(object, version) {
  if (!identical(object@files_api_version, version)) {
    cli::cli_abort(
      "This method is only available in {version} of the Files API. Please set files_api_version='{version}'."
    )
  }
}

.post_job <- function(object, data, uploads = NULL, poll = NULL) {
  cli::cli_alert_info("Submitting job...")

  req <- .build_request(object, object@files_api_url)

  if (is.null(uploads)) {
    req <- httr2::req_body_json(req, data, auto_unbox = TRUE)
  } else {
    parts <- list(data = jsonlite::toJSON(data, auto_unbox = TRUE))

    for (upload_path in uploads) {
      expanded_path <- as.character(fs::path_expand(upload_path))
      if (!file.exists(expanded_path)) {
        cli::cli_abort("Upload file not found: {upload_path}")
      }

      parts[[basename(expanded_path)]] <- curl::form_file(expanded_path)
    }

    req <- httr2::req_body_multipart(req, !!!parts)
  }

  resp <- httr2::req_perform(req)
  job <- .parse_response(object, resp)

  if (!is.null(job)) {
    .log_job(object, job)

    if (!is.null(poll) && job$status %in% c("queued", "started")) {
      Sys.sleep(poll)
      return(.get_job(object, job$job_url, poll))
    }
  }

  job
}

.get_job <- function(object, job_url, poll = NULL) {
  req <- .build_request(object, job_url)
  req <- httr2::req_retry(req, max_tries = 3)
  resp <- httr2::req_perform(req)
  job <- .parse_response(object, resp)

  if (!is.null(job)) {
    .log_job(object, job)

    if (!is.null(poll) && job$status %in% c("queued", "started")) {
      Sys.sleep(poll)
      return(.get_job(object, job$job_url, poll))
    }
  }

  job
}

.log_job <- function(object, job) {
  if (identical(job$status, "finished")) {
    cli::cli_alert_success(
      "Job {job$id} {job$status} - file_url: {job$file_url}"
    )
  } else {
    cli::cli_alert_info("Job {job$id} {job$status}")
  }

  invisible(job)
}

.download_file <- function(object, url, path = NULL, validate = FALSE, extract = FALSE) {
  file_name <- basename(httr2::url_parse(url)$path)

  save_dir <- if (is.null(path)) getwd() else fs::path_expand(path)
  fs::dir_create(save_dir, recurse = TRUE)
  file_path <- fs::path(save_dir, file_name)

  cli::cli_alert_info("Downloading {url} to {file_path}")

  headers <- object@headers
  if (file.exists(file_path)) {
    existing_size <- fs::file_size(file_path)
    headers$Range <- paste0("bytes=", existing_size, "-")
  }

  req <- httr2::request(url)
  if (length(headers) > 0) {
    req <- httr2::req_headers(req, !!!headers)
  }

  tryCatch(
    {
      req <- httr2::req_retry(req, max_tries = 3)
      httr2::req_perform(req, path = file_path)

      if (validate) {
        .validate_download(object, url, file_path, file_name)
      }

      if (extract && tools::file_ext(file_path) == "zip") {
        cli::cli_alert_info("Extracting {file_path}")
        utils::unzip(file_path, exdir = save_dir)
      }

      cli::cli_alert_success("Download complete: {file_path}")
      invisible(file_path)
    },
    error = function(e) {
      if (grepl("416", e$message)) {
        cli::cli_alert_success("File already complete: {file_path}")
        invisible(file_path)
      } else {
        cli::cli_abort("Download failed: {e$message}")
      }
    }
  )
}

.validate_download <- function(object, url, file_path, file_name) {
  json_url <- paste0(
    sub("[^/]+$", "", url),
    tools::file_path_sans_ext(file_name),
    ".json"
  )

  resp <- httr2::req_perform(.build_request(object, json_url))
  json_data <- httr2::resp_body_json(resp)
  checksum <- digest::digest(file_path, algo = "sha512", file = TRUE)

  if (!grepl(file_name, json_data$path, fixed = TRUE)) {
    cli::cli_abort("Path validation failed")
  }

  if (!identical(checksum, json_data$checksum)) {
    cli::cli_abort(
      "Checksum mismatch: {checksum} != {json_data$checksum}"
    )
  }

  cli::cli_alert_success("File validation successful")
  invisible(file_path)
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
