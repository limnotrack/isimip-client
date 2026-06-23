# Integration tests for the ISIMIP API
# These tests require internet connection and access to the ISIMIP API
# They are skipped by default and only run in CI or when explicitly enabled

test_that("Real API: can create client and query datasets", {
  skip_if_offline()
  skip_on_cran()
  
  client <- ISIMIPClient()
  
  # Simple query that should return results
  result <- tryCatch({
    datasets(client, query = "ISIMIP3b", page_size = 5)
  }, error = function(e) {
    skip(paste("API request failed:", e$message))
  })
  
  expect_type(result, "list")
  expect_true(length(result) > 0)
})

test_that("Real API: can query files with filters", {
  skip_if_offline()
  skip_on_cran()
  
  client <- ISIMIPClient()
  
  result <- tryCatch({
    files(
      client,
      simulation_round = "ISIMIP3b",
      page_size = 3
    )
  }, error = function(e) {
    skip(paste("API request failed:", e$message))
  })
  
  expect_type(result, "list")
})

test_that("Real API: pagination works correctly", {
  skip_if_offline()
  skip_on_cran()
  
  client <- ISIMIPClient()
  
  result <- tryCatch({
    datasets(client, query = "ISIMIP3b", page = 1, page_size = 5, paginate = TRUE)
  }, error = function(e) {
    skip(paste("API request failed:", e$message))
  })
  
  expect_type(result, "list")
  expect_true("count" %in% names(result))
  expect_true("results" %in% names(result))
})

test_that("Real API: can retrieve single dataset by ID", {
  skip_if_offline()
  skip_on_cran()
  
  client <- ISIMIPClient()
  
  # First get a dataset ID
  datasets_result <- tryCatch({
    datasets(client, query = "ISIMIP3b", page_size = 1)
  }, error = function(e) {
    skip(paste("API request failed:", e$message))
  })
  
  if (length(datasets_result) == 0) {
    skip("No datasets found for test")
  }
  
  dataset_id <- datasets_result[[1]]$id
  
  # Now retrieve that specific dataset
  result <- tryCatch({
    dataset(client, pk = dataset_id)
  }, error = function(e) {
    skip(paste("API request failed:", e$message))
  })
  
  expect_type(result, "list")
  expect_equal(result$id, dataset_id)
})

test_that("Real API: can retrieve single file by ID", {
  skip_if_offline()
  skip_on_cran()
  
  client <- ISIMIPClient()
  
  # First get a file ID
  files_result <- tryCatch({
    files(client, simulation_round = "ISIMIP3b", page_size = 1)
  }, error = function(e) {
    skip(paste("API request failed:", e$message))
  })
  
  if (length(files_result) == 0) {
    skip("No files found for test")
  }
  
  file_id <- files_result[[1]]$id
  
  # Now retrieve that specific file
  result <- tryCatch({
    file(client, pk = file_id)
  }, error = function(e) {
    skip(paste("API request failed:", e$message))
  })
  
  expect_type(result, "list")
  expect_equal(result$id, file_id)
})

test_that("Real API: authentication headers are included when provided", {
  skip_if_offline()
  skip_on_cran()
  
  # Create client with auth (credentials may be invalid, but we're testing structure)
  client <- ISIMIPClient(
    auth = list(username = "testuser", password = "testpass")
  )
  
  expect_equal(client@auth$username, "testuser")
  expect_equal(client@auth$password, "testpass")
})

test_that("Real API: custom headers are included when provided", {
  skip_if_offline()
  skip_on_cran()
  
  client <- ISIMIPClient(
    headers = list("User-Agent" = "isimip-r-client-test")
  )
  
  expect_equal(client@headers$`User-Agent`, "isimip-r-client-test")
})

# Note: The following tests for job submission are commented out because they
# would require actual file paths and might create jobs on the server.
# Uncomment and modify if you want to test job submission in a controlled environment.

# test_that("Real API: can submit a job (integration test)", {
#   skip_if_offline()
#   skip_on_cran()
#   skip("Skipping job submission test - requires actual files")
#   
#   client <- ISIMIPClient()
#   
#   result <- select_bbox(
#     client,
#     paths = c("ISIMIP3b/InputData/climate/atmosphere/bias-adjusted/global/daily/ssp370/GFDL-ESM4/gfdl-esm4_r1i1p1f1_w5e5_ssp370_tas_global_daily_2015_2020.nc"),
#     west = -20, east = 20, south = -10, north = 10
#   )
#   
#   expect_type(result, "list")
#   expect_true("job_id" %in% names(result))
# })
