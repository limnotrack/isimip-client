# Test datasets() method
test_that("datasets() with mocked API returns results", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_response <- list(
    count = 2,
    next = NULL,
    previous = NULL,
    results = list(
      list(id = 1, name = "dataset1", path = "path/to/dataset1"),
      list(id = 2, name = "dataset2", path = "path/to/dataset2")
    )
  )
  
  mockery::stub(datasets, ".list_resource", mock_response$results)
  
  result <- datasets(client, query = "test")
  
  expect_type(result, "list")
  expect_length(result, 2)
  expect_equal(result[[1]]$name, "dataset1")
})

test_that("datasets() with pagination returns raw response", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_response <- list(
    count = 100,
    next = "https://data.isimip.org/api/v1/datasets/?page=2",
    previous = NULL,
    results = list(list(id = 1, name = "dataset1"))
  )
  
  mockery::stub(datasets, ".list_resource", mock_response)
  
  result <- datasets(client, query = "test", paginate = TRUE)
  
  expect_type(result, "list")
  expect_true("count" %in% names(result))
  expect_true("next" %in% names(result))
})

# Test dataset() method
test_that("dataset() retrieves single dataset", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_dataset <- list(id = 1, name = "dataset1", path = "path/to/dataset1")
  
  mockery::stub(dataset, ".retrieve_resource", mock_dataset)
  
  result <- dataset(client, pk = 1)
  
  expect_type(result, "list")
  expect_equal(result$id, 1)
  expect_equal(result$name, "dataset1")
})

# Test files() method
test_that("files() with mocked API returns results", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_response <- list(
    list(id = 1, name = "file1.nc", path = "path/to/file1.nc"),
    list(id = 2, name = "file2.nc", path = "path/to/file2.nc")
  )
  
  mockery::stub(files, ".list_resource", mock_response)
  
  result <- files(client, simulation_round = "ISIMIP3b")
  
  expect_type(result, "list")
  expect_length(result, 2)
  expect_equal(result[[1]]$name, "file1.nc")
})

# Test file() method
test_that("file() retrieves single file", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_file <- list(id = 1, name = "file1.nc", path = "path/to/file1.nc")
  
  mockery::stub(file, ".retrieve_resource", mock_file)
  
  result <- file(client, pk = 1)
  
  expect_type(result, "list")
  expect_equal(result$id, 1)
  expect_equal(result$name, "file1.nc")
})

# Test select_bbox() method
test_that("select_bbox() constructs correct job parameters", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-job-123",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(select_bbox, ".post_job", mock_job)
  
  result <- select_bbox(
    client,
    paths = c("file1.nc", "file2.nc"),
    west = -20, east = 20, south = -10, north = 10
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-job-123")
})

# Test select_point() method
test_that("select_point() constructs correct job parameters", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-job-456",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(select_point, ".post_job", mock_job)
  
  result <- select_point(
    client,
    paths = c("file1.nc"),
    lat = 52.5, lon = 13.4
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-job-456")
})

# Test mask_bbox() method
test_that("mask_bbox() constructs correct job parameters", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-job-789",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(mask_bbox, ".post_job", mock_job)
  
  result <- mask_bbox(
    client,
    paths = c("file1.nc"),
    west = -20, east = 20, south = -10, north = 10,
    mean = TRUE
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-job-789")
})

# Test mask_country() method
test_that("mask_country() constructs correct job parameters", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-job-country",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(mask_country, ".post_job", mock_job)
  
  result <- mask_country(
    client,
    paths = c("file1.nc"),
    country = "DEU"
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-job-country")
})

# Test cutout_bbox() method
test_that("cutout_bbox() constructs correct job parameters", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-job-cutout",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(cutout_bbox, ".post_job", mock_job)
  
  result <- cutout_bbox(
    client,
    paths = c("file1.nc"),
    west = -20, east = 20, south = -10, north = 10
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-job-cutout")
})

# Test version checking
test_that("v2-only methods fail with wrong version", {
  client <- ISIMIPClient(files_api_version = "v1")
  
  expect_error(
    select_bbox(
      client,
      paths = c("file1.nc"),
      west = -20, east = 20, south = -10, north = 10
    ),
    "only available in v2"
  )
})
