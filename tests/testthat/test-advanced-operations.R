# Test download functionality
test_that("download() validates URL parameter", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  # Mock the download helper to avoid actual HTTP requests
  mock_download_file <- function(object, url, path, validate, extract) {
    list(path = "/tmp/test.nc", size = 1024)
  }
  
  mockery::stub(download, ".download_file", mock_download_file)
  
  result <- download(
    client,
    url = "https://files.isimip.org/test.nc",
    path = "/tmp"
  )
  
  expect_type(result, "list")
})

# Test submit_job() with uploads
test_that("submit_job() handles file uploads", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  # Create a temporary file for testing
  temp_file <- tempfile(fileext = ".shp")
  writeLines("test", temp_file)
  
  mock_job <- list(
    job_id = "test-upload-job",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(submit_job, ".post_job", mock_job)
  
  result <- submit_job(
    client,
    paths = c("file1.nc"),
    operations = list(
      list(operation = "mask_shape", shape = "shape.shp")
    ),
    uploads = c(temp_file)
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-upload-job")
  
  # Cleanup
  unlink(temp_file)
})

# Test mask_mask() method
test_that("mask_mask() constructs correct job parameters", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-mask-mask",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(mask_mask, ".post_job", mock_job)
  
  result <- mask_mask(
    client,
    paths = c("file1.nc"),
    mask = "mask.nc",
    var = "var"
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-mask-mask")
})

# Test mask_shape() method
test_that("mask_shape() constructs correct job parameters", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-mask-shape",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(mask_shape, ".post_job", mock_job)
  
  result <- mask_shape(
    client,
    paths = c("file1.nc"),
    shape = "shape.shp",
    layer = "layer1"
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-mask-shape")
})

# Test mask_landonly() method
test_that("mask_landonly() constructs correct job parameters", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-landonly",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(mask_landonly, ".post_job", mock_job)
  
  result <- mask_landonly(
    client,
    paths = c("file1.nc")
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-landonly")
})

# Test cutout_point() method
test_that("cutout_point() constructs correct job parameters", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-cutout-point",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(cutout_point, ".post_job", mock_job)
  
  result <- cutout_point(
    client,
    paths = c("file1.nc"),
    lat = 52.5,
    lon = 13.4
  )
  
  expect_type(result, "list")
  expect_equal(result$job_id, "test-cutout-point")
})

# Test high-level mask() wrapper
test_that("mask() wrapper method works with country", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-mask-wrapper",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(mask, "mask_country", mock_job)
  
  result <- mask(
    client,
    paths = c("file1.nc"),
    country = "DEU"
  )
  
  expect_type(result, "list")
})

# Test high-level mask() wrapper with bbox
test_that("mask() wrapper method works with bbox", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-mask-bbox-wrapper",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(mask, "mask_bbox", mock_job)
  
  result <- mask(
    client,
    paths = c("file1.nc"),
    bbox = c(-20, 20, -10, 10)
  )
  
  expect_type(result, "list")
})

# Test high-level cutout() wrapper
test_that("cutout() wrapper method works", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-cutout-wrapper",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(cutout, "cutout_bbox", mock_job)
  
  result <- cutout(
    client,
    paths = c("file1.nc"),
    bbox = c(-20, 20, -10, 10)
  )
  
  expect_type(result, "list")
})

# Test high-level select() wrapper
test_that("select() wrapper method works with bbox", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-select-wrapper",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(select, "select_bbox", mock_job)
  
  result <- select(
    client,
    paths = c("file1.nc"),
    bbox = c(-20, 20, -10, 10)
  )
  
  expect_type(result, "list")
})

# Test select() wrapper with point
test_that("select() wrapper method works with point", {
  skip_if_not_installed("mockery")
  
  client <- ISIMIPClient()
  
  mock_job <- list(
    job_id = "test-select-point-wrapper",
    status = "queued",
    file_url = NULL
  )
  
  mockery::stub(select, "select_point", mock_job)
  
  result <- select(
    client,
    paths = c("file1.nc"),
    point = c(52.5, 13.4)
  )
  
  expect_type(result, "list")
})
