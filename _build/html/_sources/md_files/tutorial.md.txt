# Tutorial

This procedure should demonstrate the application of the BIDSconvertR. We thank the [BIDScoin](https://github.com/Donders-Institute/bidscoin) team, who allowed us to use their sample data.

## The installation procedure

Downloading example data and installation of R and RStudio:

- Follow the [instructions](installation.md) to install the [BIDSconvertR](installation_bidsconvertr.md) on Windows or Linux and their dependencies.
- Download the [BIDScoin](https://github.com/Donders-Institute/bidscoin) example data : [Download here](https://surfdrive.surf.nl/files/index.php/s/HTxdUbykBZm2cYM/download). Please note, that the data is compressed twice with gunzip (suffix: '.gz') and tar (suffix: '.tar'). You need to unpack both.
- Create a new folder (e.g. `bidscoin\example`) and copy the `raw` subject folders into it. 

## The BIDSconvertR workflow

Covering all steps of the basid BIDSconvertR workflow:

- Start RStudio and use the R console from here on.
- Execute `library("bidsconvertr")`.
- Start the tool with the `convert_to_BIDS()`command.
- Create your own 'user\_settings.R' file by following the popup messages.
  - Select your input folder containing the DICOM's (e.g. 'bidscoin\_example\raw').
  - Select the `../subject/session/..` order of folders.
  - Select your output folder.
  - Skip the "subject-ID" and "pattern to remove" functionality. Your subject-ID's are fine!
- Rename your files with the sequence mapper according to BIDS, or download the `sequence_map.tsv` from here and replace the file in your output folder.

| sequence                            | BIDS_sequence                     | BIDS_type| relevant |
|-------------------------------------|-----------------------------------|-------|---|
| t1_mprage_sag_ipat2_1p0iso	        | T1w	                              | anat | 1 |
| AAHead_Scout_32ch-head	            | smart	                            | anat | 0 |
| cmrr_2p4iso_mb8_TR0700	            | task-reward_acq-mp8_echo-1_bold	  | func | 1 |
| cmrr_2p4iso_mb8_TR0700_SBRef        |	task-reward_acq-mp8_echo-1_sbref  |	func | 1 |
| cmrr_2p5iso_mb3me3_TR1500_e1        |	task-stop_acq-mp3m3_run-1_bold	  | func	| 1 |
| cmrr_2p5iso_mb3me3_TR1500_e2        |	task-stop_acq-mp3m3_run-2_bold	  | func	| 1 |
| cmrr_2p5iso_mb3me3_TR1500_e3        |	task-stop_acq-mp3m3_run-3_bold	  | func	| 1 |
| cmrr_2p5iso_mb3me3_TR1500_SBRef_e1	| task-stop_acq-mp3m3_run-1_sbref	  | func	| 1 |
| cmrr_2p5iso_mb3me3_TR1500_SBRef_e2	| task-stop_acq-mp3m3_run-2_sbref	  | func	| 1 |
| cmrr_2p5iso_mb3me3_TR1500_SBRef_e3	| task-stop_acq-mp3m3_run-3_sbref	  | func	| 1 |
| field_map_2p4iso_e1	                | acq-2p4_magnitude1	              | fmap 	| 1 |
| field_map_2p4iso_e2	                | acq-2p4_magnitude2	              | fmap	| 1 |
| field_map_2p4iso_e2_ph	            | acq-2p4_phasediff	                | fmap	| 1 |
| field_map_2p5iso_e1	                | acq-2p5_magnitude1	              | fmap	| 1 |
| field_map_2p5iso_e2	                | acq-2p5_magnitude2	              | fmap	| 1 |
| field_map_2p5iso_e2_ph	            | acq-2p5_phasediff	                | fmap	| 1 |



Now the data is automatically saved into BIDS, the BIDS validator is started and the 'Shiny BIDS viewer' starts.
