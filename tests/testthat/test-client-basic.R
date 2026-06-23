test_that("ISIMIPClient constructor works with defaults", {
  client <- ISIMIPClient()
  
  expect_s4_class(client, "ISIMIPClient")
  expect_equal(client@data_url, "https://data.isimip.org/api/v1")
  expect_equal(client@files_api_url, "https://files.isimip.org/api/v2")
  expect_equal(client@files_api_version, "v2")
  expect_equal(client@auth, list())
  expect_equal(client@headers, list())
})

test_that("ISIMIPClient constructor works with custom URLs", {
  client <- ISIMIPClient(
    data_url = "https://custom.data.url/api",
    files_api_url = "https://custom.files.url/api"
  )
  
  expect_equal(client@data_url, "https://custom.data.url/api")
  expect_equal(client@files_api_url, "https://custom.files.url/api")
})

test_that("ISIMIPClient constructor works with authentication", {
  client <- ISIMIPClient(
    auth = list(username = "user", password = "pass")
  )
  
  expect_equal(client@auth$username, "user")
  expect_equal(client@auth$password, "pass")
})

test_that("ISIMIPClient constructor works with custom headers", {
  client <- ISIMIPClient(
    headers = list("X-Custom-Header" = "value")
  )
  
  expect_equal(client@headers$`X-Custom-Header`, "value")
})

test_that("ISIMIPClient slot access via $ works", {
  client <- ISIMIPClient()
  
  expect_equal(client$data_url, "https://data.isimip.org/api/v1")
  expect_equal(client$files_api_url, "https://files.isimip.org/api/v2")
})

test_that("ISIMIPClient method access via $ works", {
  client <- ISIMIPClient()
  
  expect_type(client$datasets, "closure")
  expect_type(client$files, "closure")
  expect_type(client$download, "closure")
})

test_that("ISIMIPClient $ operator fails for unknown fields", {
  client <- ISIMIPClient()
  
  expect_error(client$unknown_field, "Unknown field or method")
})
