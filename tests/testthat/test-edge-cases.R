# Test edge cases and error handling

# Test ISIMIPClient validation
test_that("ISIMIPClient validates constructor arguments", {
  # data_url must be character
  expect_error(
    methods::new("ISIMIPClient", data_url = 123),
    "character"
  )
  
  # files_api_url must be character
  expect_error(
    methods::new("ISIMIPClient", files_api_url = 123),
    "character"
  )
})

# Test empty query results
test_that("empty API results are handled correctly", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_empty <- list()
  mockery::stub(datasets, ".list_resource", mock_empty)
  
  result <- datasets(client, query = "nonexistent")
  
  expect_type(result, "list")
  expect_length(result, 0)
})

# Test API error handling
test_that("API errors are properly reported", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  # Mock a function that throws an error
  mock_error <- function(...) {
    stop("API request failed: 404 Not Found")
  }
  
  mockery::stub(dataset, ".retrieve_resource", mock_error)
  
  expect_error(
    dataset(client, pk = 99999),
    "API request failed"
  )
})

# Test missing required parameters
test_that("missing required parameters cause errors", {
  client <- ISIMIPClient()
  
  # select_bbox requires all bbox parameters
  expect_error(
    select_bbox(client, paths = c("file.nc"), west = -20),
    "argument.*missing"
  )
})

# Test invalid bbox values
test_that("invalid bbox values are handled", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  # Mock to avoid actual API call
  mockery::stub(select_bbox, ".post_job", list(job_id = "test"))
  
  # Longitude out of range (should still work - API will validate)
  result <- select_bbox(
    client,
    paths = c("file.nc"),
    west = -200, east = 200, south = -10, north = 10
  )
  
  expect_type(result, "list")
})

# Test file upload with non-existent file
test_that("submit_job with non-existent upload file fails appropriately", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  # Don't mock .post_job to test the upload validation
  # but mock the HTTP call itself
  mock_post <- function(...) {
    list(job_id = "test-job", status = "queued")
  }
  
  post_job_func <- getFromNamespace(".post_job", "isimip")
  
  expect_error(
    post_job_func(
      client,
      data = list(paths = c("file.nc"), operations = list()),
      uploads = c("/nonexistent/file.shp"),
      poll = NULL
    ),
    "Upload file not found"
  )
})

# Test parameter coercion
test_that("parameters are properly coerced", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  captured_params <- NULL
  mock_list <- function(object, resource_url, params, paginate) {
    captured_params <<- params
    list()
  }
  
  mockery::stub(datasets, ".list_resource", mock_list)
  
  # Integer page values
  datasets(client, page = 2L, page_size = 50L)
  
  expect_equal(captured_params$page, 2L)
  expect_equal(captured_params$page_size, 50L)
})

# Test NULL parameters are handled correctly
test_that("NULL parameters are handled correctly", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  captured_params <- NULL
  mock_list <- function(object, resource_url, params, paginate) {
    captured_params <<- params
    list()
  }
  
  mockery::stub(datasets, ".list_resource", mock_list)
  
  # NULL page and page_size should not be added to params
  datasets(client, query = "test", page = NULL, page_size = NULL)
  
  expect_false("page" %in% names(captured_params))
  expect_false("page_size" %in% names(captured_params))
  expect_equal(captured_params$query, "test")
})

# Test boolean parameters in operations
test_that("boolean parameters in operations are handled correctly", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  captured_data <- NULL
  mock_post <- function(object, data, uploads, poll) {
    captured_data <<- data
    list(job_id = "test-job", status = "queued")
  }
  
  mockery::stub(select_bbox, ".post_job", mock_post)
  
  select_bbox(
    client,
    paths = c("file.nc"),
    west = -20, east = 20, south = -10, north = 10,
    mean = TRUE,
    csv = FALSE
  )
  
  expect_true(captured_data$operations[[1]]$compute_mean)
  expect_false(captured_data$operations[[1]]$output_csv)
})

# Test show method for ISIMIPClient
test_that("show method for ISIMIPClient works", {
  client <- ISIMIPClient()
  
  # Capture output
  output <- capture.output(show(client))
  
  expect_true(any(grepl("ISIMIPClient", output)))
  expect_true(any(grepl("data_url", output)))
})

# Test slot access edge cases
test_that("slot access handles edge cases", {
  client <- ISIMIPClient()
  
  # Valid slot access
  expect_type(client$data_url, "character")
  
  # Invalid slot/method name
  expect_error(client$nonexistent_method, "Unknown field or method")
})

# Test wrapper functions with missing arguments
test_that("wrapper functions handle missing arguments", {
  client <- ISIMIPClient()
  
  # mask() requires at least one of: country, bbox, landonly
  expect_error(
    mask(client, paths = c("file.nc")),
    "argument.*missing|is missing"
  )
  
  # select() requires one of: country, bbox, point
  expect_error(
    select(client, paths = c("file.nc")),
    "argument.*missing|is missing"
  )
})

# Test very long result lists (pagination)
test_that(".list_resource stops at 1000 results", {
  skip_if_not_installed("mockery")
  
  list_resource <- getFromNamespace(".list_resource", "isimip")
  
  client <- ISIMIPClient()
  
  # Mock .get to return paginated results
  call_count <- 0
  mock_get <- function(object, url, params = NULL) {
    call_count <<- call_count + 1
    
    if (call_count <= 10) {
      list(
        count = 2000,
        next = "https://data.isimip.org/api/v1/datasets/?page=2",
        results = lapply(1:100, function(i) list(id = i))
      )
    } else {
      list(
        count = 2000,
        next = NULL,
        results = lapply(1:100, function(i) list(id = i))
      )
    }
  }
  
  with_mocked_bindings(
    {
      result <- list_resource(client, "/datasets", list(), paginate = FALSE)
      
      # Should stop at 1000 results (10 pages of 100)
      expect_length(result, 1000)
    },
    .get = mock_get,
    .package = "isimip"
  )
})

# Test URL building edge cases
test_that(".build_url handles various URL formats", {
  build_url <- getFromNamespace(".build_url", "isimip")
  
  # Test with various trailing slash combinations
  client1 <- ISIMIPClient(data_url = "https://example.com/api/v1/")
  url1 <- build_url(client1, "/datasets/")
  expect_equal(url1, "https://example.com/api/v1/datasets/")
  
  client2 <- ISIMIPClient(data_url = "https://example.com/api/v1")
  url2 <- build_url(client2, "datasets")
  expect_equal(url2, "https://example.com/api/v1/datasets/")
  
  client3 <- ISIMIPClient(data_url = "https://example.com/api/v1/")
  url3 <- build_url(client3, "datasets")
  expect_equal(url3, "https://example.com/api/v1/datasets/")
})
