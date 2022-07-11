
#' Creates template strings for BIDS
#'
#' @return
#' @export
#'
#' @examples
create_metadata <- function(){

  settings_string <<-'# Path that contains one folder per session, containing all DICOMS in subject folders
path_input_dicom <- "C:/Science/bidirect/dicom/"

# output folder
path_output <- "C:/Science/bidirect_bids/"


study_name <- "BiDirect Study"

# regular expressions
regex_subject_id <- "[:digit:]{5}"
regex_group_id <- "[:digit:]{1}(?=[:digit:]{4})"
regex_remove_pattern <- "[:punct:]{1}|[:blank:]{1}|((b|d)i(d|b)i|bid|bd|bdi)(ect|rect)($|(rs|T2TSE|inclDIRSequenz|neu|abbruch))"

# session ids
sessions_id_old <- c("Baseline", "FollowUp", "FollowUp2", "FollowUp3")
sessions_id_new <- c("0", "2", "4", "6")

# mri sequence ids
mri_sequences <- c("T1|T2|DTI|fmr|rest|rs|func|FLAIR|smartbrain|survey|smart|ffe|tse")'

  dataset_description <<- '{
\t"Name": "The BIDS-Direct-ConverteR study",
\t"BIDSVersion": "1.1.0rc4",
\t"License": "This dataset was made available by You. We hope that the users of the data will acknowledge the BIDS-Direct-ConverteR team and the funding by the Federal Ministry of Education and Research, Germany (grants #01ER0816, #01ER1205 and #01ER1506) in any publications.",
\t"Authors":  ["Niklas Wulms", "Sven Eppe", "Benedikt Sundermann", "Klaus Berger", "Heike Minnerup"],
\t"HowToAcknowledge": "Please cite publications in References and Links",
\t"Funding": ["Here comes the fund"],
\t"ReferencesAndLinks": [
\t\t"Teismann, H., Wersching, H., Nagel, M., Arolt, V., Heindel, W., Baune, B. T., … Berger, K. (2014). Establishing the bidirectional relationship between depression and subclinical arteriosclerosis - rationale, design, and characteristics of the BiDirect Study. BMC Psychiatry, 14(1). https://doi.org/10.1186/1471-244X-14-174",
\t\t"Teuber, A., Sundermann, B., Kugel, H., Schwindt, W., Heindel, W., Minnerup, J., … Wersching, H. (2017). MR imaging of the brain in large cohort studies: feasibility report of the population- and patient-based BiDirect study. European Radiology, 27(1), 231–238. https://doi.org/10.1007/s00330-016-4303-9",
\t\t"nwulms, & wulms. (2019, October 2). wulms/BiDirect_BIDS_Converter: Runable script (Version 0.1). Zenodo. http://doi.org/10.5281/zenodo.3469539"
\t],
\t"DatasetDOI": "Add here your DOI"
}'

  participants <<- '{
  "session": {
    "LongName": "session",
    "Description": "Session of study",
    "Units": "Session Name, Ordinal"
  },
  "birthdate": {
    "LongName": "birthdate",
    "Description": "birthdate of the participant - extracted from dicom header",
    "Units": "datetime"
  },
  "acquisitiondate": {
    "LongName": "acquisitiondate",
    "Description": "acquisitiondate of the participant at the mentioned session - extracted from dicom header",
    "Units": "datetime"
  },
    "sex": {
    "LongName": "sex",
    "Description": "sex of the participantas reported by the participant - extracted from dicom header",
    "Levels": {
      "m": "male",
      "f": "female"
    }
  },
    "weight": {
    "LongName": "weight",
    "Description": "weight of the participant as reported by the participant - extracted from dicom header",
    "Levels": {
      "Units": "kg"
    }
  },
  "age": {
    "LongName": "age",
    "Description": "age of the participant - time difference between birthdate and acquisitiondate",
    "Units": "years"
  }
}'

  participants_anon <<- '{
  "session": {
    "LongName": "session",
    "Description": "Session of study",
    "Units": "Session Name, Ordinal"
  }
}'



  README <<-
    "This dataset was acquired at the BiDirect study, Institute for Epidemiology and Social Medicine, University of Muenster, Germany.

Description: BiDirect study neuroimaging data in BIDS format

We hope that all users of the data will acknowledge and refer to the BiDirect project.
Please cite the following references if you use these data:

General Study information:
Teismann, H., Wersching, H., Nagel, M., Arolt, V., Heindel, W., Baune, B. T., … Berger, K. (2014). Establishing the bidirectional relationship between depression and subclinical arteriosclerosis - rationale, design, and characteristics of the BiDirect Study. BMC Psychiatry, 14(1). https://doi.org/10.1186/1471-244X-14-174 \n

Neuroimaging Study information:
Teuber, A., Sundermann, B., Kugel, H., Schwindt, W., Heindel, W., Minnerup, J., … Wersching, H. (2017). MR imaging of the brain in large cohort studies: feasibility report of the population- and patient-based BiDirect study. European Radiology, 27(1), 231–238. https://doi.org/10.1007/s00330-016-4303-9\n

Code used for processing: dicom2nii conversion, file management and BIDS:
nwulms, & wulms. (2019, October 2). wulms/BiDirect_BIDS_Converter: Runable script (Version 0.1). Zenodo. http://doi.org/10.5281/zenodo.3469539

2019-12-04: Initial release, added references.

This dataset can be made available Univ.-Prof. Dr. med. Klaus Berger (mail: bergerk@uni-muenster.de).
The BiDirect Study is funded by the Federal Ministry of Education and Research, Germany (grants #01ER0816, #01ER1205 and #01ER1506)."


  CHANGES <<-
    "1.0.0 2019-12-04
	- initial release
	- BIDS converter working
	- actual version containing all subjects up to 2019-11-18"
}
