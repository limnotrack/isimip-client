# isimip

This repository contains an R package for interacting with the ISIMIP Repository API.

## Developer Notes

### Building the Package

```r
# Install dependencies
install.packages(c("devtools", "roxygen2", "pkgdown", "testthat"))

# Generate documentation
devtools::document()

# Check package
devtools::check()

# Install package
devtools::install()

# Build pkgdown site
pkgdown::build_site()
```

### Running Tests

```r
# Run all tests
devtools::test()

# Run with coverage
covr::package_coverage()
```

### Package Structure

```
isimip-client/
├── R/                      # R source code
│   ├── client.R            # Main ISIMIPClient class
│   └── isimip-package.R    # Package documentation
├── tests/                  # Test files
│   └── testthat/
│       ├── test-client-basic.R
│       └── test-client-operations.R
├── vignettes/              # Package vignettes
│   └── getting-started.Rmd
├── man/                    # Generated documentation (by roxygen2)
├── DESCRIPTION             # Package metadata
├── NAMESPACE               # Package namespace (auto-generated)
├── README.md               # Package README
├── NEWS.md                 # Change log
├── LICENSE.md              # License file
├── _pkgdown.yml            # pkgdown configuration
└── .github/workflows/      # GitHub Actions workflows
    ├── R-CMD-check.yaml
    ├── pkgdown.yaml
    └── test-coverage.yaml
```

### Code Style

This package follows the [tidyverse style guide](https://style.tidyverse.org/):
- Use snake_case for function names and variables
- Use 2 spaces for indentation
- Use roxygen2 for documentation
- Use testthat for testing

### Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run `devtools::check()` to ensure everything passes
5. Submit a pull request

### Comparison with Python Version

This R package closely mirrors the functionality of the Python isimip-client:

| Python | R Equivalent |
|--------|--------------|
| `requests` | `httr2` |
| `click` | Not implemented (CLI) |
| `rich` | `cli` |
| Class methods | R6 methods |
| `json.loads()` | `jsonlite::fromJSON()` |
| `pathlib.Path` | `fs::path()` |
| `hashlib.sha512()` | `digest::digest()` |

### Future Enhancements

Potential additions for future versions:
- Command-line interface using `cli` package
- Integration with `sf` for spatial data
- Integration with `terra`/`ncdf4` for NetCDF handling
- Caching using `memoise` or `cachem`
- Progress bars for large downloads
- Parallel downloads for multiple files
- Tibble/data.frame outputs option
