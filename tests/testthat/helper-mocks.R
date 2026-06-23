# Test helper functions for common mock setups

# Helper to create a mock HTTP response
mock_http_response <- function(status = 200, body = list()) {
  structure(
    list(
      status_code = status,
      headers = list(),
      body = body
    ),
    class = "httr2_response"
  )
}

# Helper to create a mock dataset response
mock_dataset_response <- function(count = 1, with_next = FALSE) {
  results <- lapply(1:count, function(i) {
    list(
      id = i,
      name = paste0("dataset", i),
      path = paste0("path/to/dataset", i),
      specifiers = list(
        simulation_round = "ISIMIP3b",
        product = "InputData",
        climate_forcing = "gfdl-esm4"
      )
    )
  })
  
  list(
    count = count,
    next = if (with_next) "https://data.isimip.org/api/v1/datasets/?page=2" else NULL,
    previous = NULL,
    results = results
  )
}

# Helper to create a mock file response
mock_file_response <- function(count = 1) {
  results <- lapply(1:count, function(i) {
    list(
      id = i,
      name = paste0("file", i, ".nc"),
      path = paste0("path/to/file", i, ".nc"),
      size = 1024 * i,
      checksum = paste0("checksum", i)
    )
  })
  
  list(
    count = count,
    next = NULL,
    previous = NULL,
    results = results
  )
}

# Helper to create a mock job response
mock_job_response <- function(status = "queued", file_url = NULL) {
  list(
    job_id = paste0("test-job-", sample(1000:9999, 1)),
    status = status,
    file_url = file_url,
    created = "2024-01-01T00:00:00Z",
    ttl = 3600
  )
}

# Helper to create a completed job response
mock_completed_job <- function() {
  mock_job_response(
    status = "finished",
    file_url = "https://files.isimip.org/download/test-result.zip"
  )
}

# Helper to check if running in CI
is_ci <- function() {
  isTRUE(as.logical(Sys.getenv("CI", "false")))
}

# Helper to skip if not in CI (for integration tests)
skip_if_not_ci <- function() {
  if (!is_ci()) {
    testthat::skip("Not running in CI environment")
  }
}

# Helper to skip if offline
skip_if_offline <- function() {
  if (!curl::has_internet()) {
    testthat::skip("No internet connection")
  }
}
