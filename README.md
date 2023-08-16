
<!-- README.md is generated from README.Rmd. Please edit that file -->
**This is the legacy repository of BIDSconvertR. Please visit the new repository for LTS: [BIDSconvertR](https://github.com/bidsconvertr/bidsconvertr)**


[![DOI](https://zenodo.org/badge/448850893.svg)](https://zenodo.org/badge/latestdoi/448850893)
[![BIDS](https://img.shields.io/badge/BIDS-v1.8.0-blue)](https://bids-specification.readthedocs.io/en/v1.8.0/)
[![Github](https://img.shields.io/github/v/release/wulms/bidsconvertr.svg)](https://github.com/wulms/bidsconvertr)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

<a href='https://wulms.bidsconvertr.io'><img src="inst/figure/BIDSconvertR.png" align="right" height="150"/></a> The hexagonal sticker was made using the [iconspackage](https://github.com/mitchelloharawild/icons) and based on the MRI svg graphics provided by Flaticon and mavadee [FlaticonLink](https://www.flaticon.com/free-icons/mri). |



# Documentation

The code is documented at **<https://bidsconvertr.github.io/>**. Please visit the documentation for a detailed description of the BIDSconvertR


## Aim

[BIDSconvertR](https://github.com/bidsconvertr/bidsconvertr) aims to provide a workflow that can:

- do the task inside of the R environment
- convert DICOM data to NIfTI (with the awesome [dcm2niix](https://github.com/rordenlab/dcm2niix)
- structure this data according to the [BIDS specification](https://bids-specification.readthedocs.io/en/stable/)
- validate the compatibility with BIDS with the [BIDS validator](https://github.com/bids-standard/bids-validator)
- visualize the images with [papayaViewer](https://rii-mango.github.io/Papaya/) and [papayaWidget](https://github.com/muschellij2/papayaWidget)

----

### Features

- continuous application
  - lazy processing of already existing files 
  - easy application during data collection in ongoing studies
- user-friendliness (minimal terminal interaction required)
  - user dialog with message boxes guiding the users through the workflow
  - Shiny App (GUI) for sequence editing and data inspection
- file cleaning 
  - Renaming of subject-IDs or session-IDs with regular expressions.
  - Renaming of session-IDs
- BIDS validation
  - verification (color-coded) of sequence-IDs (comparing the entered sequence-IDs to regular expressions according to BIDS)
  - implemented validation with [BIDS-Validator](https://bids-standard.github.io/bids-validator/) (Website/Docker)
- quality control 
  - user-friendly ([papayaWidget](https://github.com/muschellij2/papayaWidget) image viewer) for BIDS datasets
- pseudonymized BIDS output (only metadata)
  - all potentially identifiable metadata was removed from images and JSONs

---

# How to cite: 

Wulms, Niklas. 2022. *Wulms/Bidsconvertr*. Zenodo. <https://doi.org/10.5281/ZENODO.5878407>.

----
## Milestones / To-Do's

- publish the BIDSconvertR
- testing the tool on MAC systems 

