#!/usr/bin/env Rscript

# Validation script for the isimip R package
# This script checks the basic structure and validity of the package

cat("Validating isimip R package structure...\n\n")

# Check required files exist
required_files <- c(
  "DESCRIPTION",
  "NAMESPACE", 
  "README.md",
  "LICENSE.md",
  "NEWS.md",
  "R/client.R",
  "R/isimip-package.R",
  "tests/testthat.R",
  "_pkgdown.yml"
)

cat("Checking required files:\n")
for (file in required_files) {
  if (file.exists(file)) {
    cat("  ✓", file, "\n")
  } else {
    cat("  ✗", file, "MISSING\n")
  }
}

cat("\n")

# Check DESCRIPTION file
if (file.exists("DESCRIPTION")) {
  cat("Reading DESCRIPTION file:\n")
  desc <- readLines("DESCRIPTION")
  cat("  Package:", sub("Package: ", "", grep("^Package:", desc, value = TRUE)), "\n")
  cat("  Version:", sub("Version: ", "", grep("^Version:", desc, value = TRUE)), "\n")
  cat("  Title:", sub("Title: ", "", grep("^Title:", desc, value = TRUE)), "\n")
  cat("\n")
}

# Check R source files
r_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
cat("R source files found:", length(r_files), "\n")
for (file in r_files) {
  lines <- length(readLines(file, warn = FALSE))
  cat("  ", basename(file), "-", lines, "lines\n")
}
cat("\n")

# Check test files
test_files <- list.files("tests/testthat", pattern = "^test-.*\\.R$", full.names = TRUE)
cat("Test files found:", length(test_files), "\n")
for (file in test_files) {
  lines <- length(readLines(file, warn = FALSE))
  cat("  ", basename(file), "-", lines, "lines\n")
}
cat("\n")

# Check vignettes
vignettes <- list.files("vignettes", pattern = "\\.Rmd$", full.names = TRUE)
cat("Vignettes found:", length(vignettes), "\n")
for (file in vignettes) {
  cat("  ", basename(file), "\n")
}
cat("\n")

cat("Package structure validation complete!\n")
cat("\nNext steps:\n")
cat("  1. Install dependencies: install.packages(c('devtools', 'roxygen2', 'pkgdown'))\n")
cat("  2. Generate documentation: devtools::document()\n")
cat("  3. Check package: devtools::check()\n")
cat("  4. Build site: pkgdown::build_site()\n")
