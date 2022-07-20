# Tutorial

This procedure should demonstrate how to use the BIDSconvertR. 
We appreciate the [BIDScoin](https://github.com/Donders-Institute/bidscoin) team's permission to use their sample data.

## The installation procedure

Installing E and RStudio and downloading sample data:

- To install the [BIDSconvertR](installation_bidsconvertr.md) on Windows or Linux follow the [instructions](installation.md).
- Download the [BIDScoin](https://github.com/Donders-Institute/bidscoin) example data : [Download here](https://surfdrive.surf.nl/files/index.php/s/HTxdUbykBZm2cYM/download). 
  Please be aware that the data has been compressed twice using gunzip (suffix: '.gz') and tar (suffix: '.tar'). You need to unpack both.
- Copy the `raw` subject folders into a new folder (such as `bidscoin\example`). 

## The BIDSconvertR workflow

This workflow covers each stage of the fundamental BIDSconvertR workflow:

- Launch RStudio and use the R console from here on.
- Execute `library("bidsconvertr")`.
- Use the `convert_to_BIDS()`command to launch the tool.
- Create your own 'user\_settings.R' file by following the popup messages.
  - Choose the input folder that contains the DICOM's (e.g. 'bidscoin\_example\raw').
  - Select the `../subject/session/..` order of folders.
  - Choose the output folder.
  - Do not use the "subject-ID" or "pattern to remove" features. You have good subject-IDs!
- Use the sequence mapper to rename your files in accordance with BIDS, or download the `sequence_map.tsv` from [this link](https://github.com/wulms/bidsconvertr/blob/master/extdata/sequence_map.tsv) and replace the file in your output folder.

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



Now the data is automatically saved into BIDS, the BIDS validator is started, and the `Shiny BIDS viewer` starts.
