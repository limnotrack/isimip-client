# Test helper functions

# Test %||% operator
test_that("%||% operator works correctly", {
  # Access the operator from the isimip namespace
  null_coalesce <- getFromNamespace("%||%", "isimip")
  
  expect_equal(null_coalesce(NULL, "default"), "default")
  expect_equal(null_coalesce("value", "default"), "value")
  expect_equal(null_coalesce(0, "default"), 0)
  expect_equal(null_coalesce("", "default"), "")
  expect_equal(null_coalesce(FALSE, "default"), FALSE)
})

# Test .build_url helper
test_that(".build_url constructs correct URLs", {
  build_url <- getFromNamespace(".build_url", "isimip")
  
  client <- ISIMIPClient(data_url = "https://data.isimip.org/api/v1")
  
  # Basic URL without pk
  url <- build_url(client, "/datasets")
  expect_equal(url, "https://data.isimip.org/api/v1/datasets/")
  
  # URL with pk
  url <- build_url(client, "/datasets", pk = 123)
  expect_equal(url, "https://data.isimip.org/api/v1/datasets/123/")
  
  # URL with trailing slashes
  url <- build_url(client, "/datasets/")
  expect_equal(url, "https://data.isimip.org/api/v1/datasets/")
  
  # Client URL with trailing slash
  client2 <- ISIMIPClient(data_url = "https://data.isimip.org/api/v1/")
  url <- build_url(client2, "/datasets")
  expect_equal(url, "https://data.isimip.org/api/v1/datasets/")
})

# Test .check_version helper
test_that(".check_version validates API version correctly", {
  check_version <- getFromNamespace(".check_version", "isimip")
  
  client_v2 <- ISIMIPClient(files_api_version = "v2")
  expect_silent(check_version(client_v2, "v2"))
  
  client_v1 <- ISIMIPClient(files_api_version = "v1")
  expect_error(check_version(client_v1, "v2"), "only available in v2")
})

# Test .build_request helper
test_that(".build_request creates correct httr2 request", {
  skip_if_not_installed("httr2")
  
  build_request <- getFromNamespace(".build_request", "isimip")
  
  client <- ISIMIPClient()
  req <- build_request(client, "https://data.isimip.org/api/v1/datasets/")
  
  expect_s3_class(req, "httr2_request")
})

test_that(".build_request includes authentication", {
  skip_if_not_installed("httr2")
  
  build_request <- getFromNamespace(".build_request", "isimip")
  
  client <- ISIMIPClient(
    auth = list(username = "testuser", password = "testpass")
  )
  req <- build_request(client, "https://data.isimip.org/api/v1/datasets/")
  
  expect_s3_class(req, "httr2_request")
  # The auth should be added to the request
  expect_true(!is.null(req$options$httpauth))
})

test_that(".build_request includes custom headers", {
  skip_if_not_installed("httr2")
  
  build_request <- getFromNamespace(".build_request", "isimip")
  
  client <- ISIMIPClient(
    headers = list("X-Custom-Header" = "custom-value")
  )
  req <- build_request(client, "https://data.isimip.org/api/v1/datasets/")
  
  expect_s3_class(req, "httr2_request")
  expect_true("X-Custom-Header" %in% names(req$headers))
  expect_equal(req$headers$`X-Custom-Header`, "custom-value")
})

# Test parameter handling
test_that("datasets() handles query parameters correctly", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  # Mock the .list_resource function to capture parameters
  captured_params <- NULL
  mock_list <- function(object, resource_url, params, paginate) {
    captured_params <<- params
    list()
  }
  
  mockery::stub(datasets, ".list_resource", mock_list)
  
  datasets(
    client,
    query = "test query",
    simulation_round = "ISIMIP3b",
    page = 2,
    page_size = 50
  )
  
  expect_equal(captured_params$query, "test query")
  expect_equal(captured_params$simulation_round, "ISIMIP3b")
  expect_equal(captured_params$page, 2)
  expect_equal(captured_params$page_size, 50)
})

test_that("files() handles query parameters correctly", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  # Mock the .list_resource function to capture parameters
  captured_params <- NULL
  mock_list <- function(object, resource_url, params, paginate) {
    captured_params <<- params
    list()
  }
  
  mockery::stub(files, ".list_resource", mock_list)
  
  files(
    client,
    simulation_round = "ISIMIP3b",
    climate_forcing = "gfdl-esm4",
    climate_scenario = "ssp370",
    page = 1,
    page_size = 100
  )
  
  expect_equal(captured_params$simulation_round, "ISIMIP3b")
  expect_equal(captured_params$climate_forcing, "gfdl-esm4")
  expect_equal(captured_params$climate_scenario, "ssp370")
  expect_equal(captured_params$page, 1)
  expect_equal(captured_params$page_size, 100)
})
