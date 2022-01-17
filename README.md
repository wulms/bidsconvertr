
<!-- README.md is generated from README.Rmd. Please edit that file -->

# BIDSconvertR <a href='https://pkg.mitchelloharawild.com/icon'><img src='inst/figure/BIDSconvertR.png' align="right" height="150" /></a>

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/195199025.svg)](https://zenodo.org/badge/latestdoi/195199025)

The hexagonal sticker is based on the MRI svg graphics provided by
Flaticon and was created by mavadee [Flaticon
Link](https://www.flaticon.com/free-icons/mri).

<!-- badges: end -->

The goal of BIDSconvertR is to …

## Installation

You need the R package ‘devtools’ to install packages from Github

``` r
install.packages("devtools")
```

Now you are able to install the development version of BIDSconvertR.

``` r
devtools::install_github(repo = "wulms/bidsconvertr")
```

Please install also the following package.

``` r
devtools::install_github("muschellij2/papayaWidget")
```

## Usage

### First steps

Choose a folder, where you want to store your “user settings” file. The
function `create_user_settings("path")` creates a template file at the
desired folder.

``` r
create_user_settings("/media/niklas/BIDS_data/BIDSconvertR/output/") # Linux
create_user_settings("C:/Science/bidirect_bids/") # Windows
```

Edit the file “user\_settings.R” to your needs.

| Variable               | Example                                                                                                                   | Description                                                                                                                                       |
|------------------------|---------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| path\_input\_dicom     | “/media/niklas/BIDS\_data/dicom/”                                                                                         | Input path, where your DICOM folders are inside of session folders                                                                                |
| path\_output           | “/media/niklas/BIDS\_data/BIDSconvertR”                                                                                   | A path, where all the output of the converter should be written to.                                                                               |
| study\_name            | “BiDirect Study”                                                                                                          | Your study name, only needed for the dashboard rendering.                                                                                         |
| regex\_subject\_id     | “\[:digit:\]{5}”                                                                                                          | Regex defining your unique subject ID’s.                                                                                                          |
| regex\_group\_id       | “\[:digit:\]{1}(?=\[:digit:\]{4})”                                                                                        | Regex defining the group ID (if present).                                                                                                         |
| regex\_remove\_pattern | “\[:punct:\]{1}\|\[:blank:\]{1}\|((b\|d)i(d\|b)i\|bid\|bd\|bdi)(ect\|rect)($\|(rs\|T2TSE\|inclDIRSequenz\|neu\|abbruch))” | These regex will be removed from the file names.                                                                                                  |
| sessions\_id\_old      | c(“Baseline”, “FollowUp”, “FollowUp2”, “FollowUp3”)                                                                       | The folder (and session) names before conversion                                                                                                  |
| sessions\_id\_new      | c(“0”, “2”, “4”, “6”)                                                                                                     | The folder (and session) names after conversion. These can be identical to “sessions\_id\_old”. But note, that in BIDS a number is the way to go. |
| mri\_sequences         | “T1\|T2\|DTI\|fmr\|rest\|rs\|func\|FLAIR\|smartbrain\|survey\|smart\|ffe\|tse”                                            | These are regular expressions, which should be matched to your MRI sequence ID’s.                                                                 |

Information in the user settings file

Now you have edited your “user\_settings.R” file.

The next step is to prepare your environment with the function
“prepare\_environment(‘/path/to/user\_settings.R’)”

``` r
settings_file <- "/media/niklas/BIDS_data/BIDSconvertR/output/user_settings.R" # Linux path
settings_file <- "C:/Science/bidirect_bids/user_settings.R" # Windows path

prepare_environment(settings_file)
```

Then you need to install dcm2niix. The function automatically uses the
tested “v1.0.20211006” of dcm2niix, other versions can be installed by
changing the version number.

<https://github.com/rordenlab/dcm2niix/releases>

``` r
install_dcm2niix()

install_dcm2niix("v1.0.20181125") # if you want to install the specific version v1.0.20181125
```

### How to run the main script

The convert\_to\_BIDS function takes two arguments: the
user\_settings\_file and a switch to select, if you want to see the
sequence\_table everytime (“on”) or only, if something is not plausible
(“off”).

“On” is useful to inspect the sequence mapping again. “Off” shows the
sequence mapper only, if some unplausible data is identified, e.g. new
sequences, which are not mapped.

``` r
convert_to_BIDS(user_settings_file = settings_file,
                sequence_table = "off")
```

### Alternatively to main script: You can also run each step manually

``` r
# preparation
create_user_settings("C:/Science/bidirect_bids/") # Windows

settings_file <- "C:/Science/bidirect_bids/user_settings.R" # Windows path

prepare_environment(settings_file)
```

``` r
user_settings_file = settings_file

# dcm2niix - niftis
dcm2nii_converter_anon()

# dcm2niix - jsons
dcm2nii_converter_json()

# read all metadata from JSON files
read_json_headers(json_path = path_output_converter_temp_json, suffix = "")

read_json_headers(json_path = path_output_converter_temp_nii, suffix = "_anon")


sequence_mapper(edit_table = sequence_table)

check_sequence_map()

copy2BIDS()

create_dashboard_internal()

run_shiny_BIDS()
```

## Citation
