<!-- README.md is generated from README.Rmd. Please edit that file -->

# BIDSconvertR 


<!-- <figure>-->
<!-- <img align="right" height="150" src="../../inst/figure/BIDSconvertR.png" alt="BIDSconvertR logo"/>-->
<!-- <figcaption>The BIDSconvertR logo, created with </figcaption>-->
<!-- </figure>-->



<!-- badges: start -->

[![DOI](https://zenodo.org/badge/195199025.svg)](https://zenodo.org/badge/latestdoi/195199025) [![Github](https://img.shields.io/github/v/release/wulms/bidsconvertr.svg)](https://github.com/wulms/bidsconvertr)

```{image} ../../../inst/figure/BIDSconvertR.png
:alt: BIDSconvertR logo
:height: 150px
:align: right
```

The hexagonal sticker is created with the [iconspackage](https://github.com/mitchelloharawild/icons) and based on the MRI svg graphics provided by
Flaticon and was created by mavadee [FlaticonLink](https://www.flaticon.com/free-icons/mri).



<!-- badges: end -->


## Aim

The goal of [BIDSconvertR](https://github.com/wulms/bidsconvertr) is to provide a workflow, which is able to:

-   convert DICOM data to NIfTI data using
    [dcm2niix](https://github.com/rordenlab/dcm2niix)
-   structure this data according to the [BIDS
    specification](https://bids-specification.readthedocs.io/en/stable/)
    -   validate the sequence-ID’s
    -   enable easy access to the
        [BIDS-Validator](https://bids-standard.github.io/bids-validator/)
        (Website/Docker)
-   provide the
    [papayaWidget](https://github.com/muschellij2/papayaWidget) viewer
    for inspecting the images
-   enable continuous application during data acquisition in ongoing
    studies

## Features

Renaming of unclean subject-ID’s or session-ID’s.

Everytime new files or sequences are added, the ‘sequence mapper’ opens
again until everything is declared according to BIDS. Already processed
files are skipped.



## Citation 

Wulms, Niklas. 2022. *Wulms/Bidsconvertr*. Zenodo.
<https://doi.org/10.5281/ZENODO.5878407>.









