# Install the BIDSconvertR

```{Note} 
Please install R according to the description. From here on enter the following commands into the 'console' panel in RStudio.
```

You need to install both R packages once. The `devtools` package is required to
install packages from Github.

``` r
install.packages("devtools")
```

Now you are able to install the most recent development version of
`BIDSconvertR` using the command below.

``` r
devtools::install_github(repo = "wulms/bidsconvertr")
```
