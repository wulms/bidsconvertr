datatable_setting <- function(df) {
  DT::datatable(
    df,
    extensions = c('Scroller'),
    options = list(
      search = list(regex = TRUE),
      searchHighlight = TRUE,
      pageLength = 25,
      dom = 'Bfrtip',
      deferRender = TRUE,
      scrollY = 200,
      scroller = TRUE
    ),
    filter = 'top'
  )
}


df_select_n <- function(df) {
  df <- df %>%
    select(session, BIDS_type, BIDS_sequence, relevant) %>%
    group_by(across(everything())) %>%
    count() %>%
    ungroup()
   # spread(. ,session, value = n)
  return(df)
}

df_select_n_group <- function(df) {
  df <- df %>%
    select(session, BIDS_type, BIDS_sequence, group, PatientSex, relevant) %>%
    filter(relevant == 1) %>%
    group_by(across(everything())) %>%
    count() %>%
    ungroup()
  return(df)
}

df_select_patient_info <- function(df){
  df2 <- df %>% mutate(group = "all")
  df <- df %>%
    rbind(df2) %>%
    select(subject, session, group, PatientSex, PatientWeight, PatientBirthDate, AcquisitionDateTime) %>%
    mutate(AcquisitionDateTime = as.Date(AcquisitionDateTime),
           Age = time_length(difftime(AcquisitionDateTime, PatientBirthDate), "years") %>% round(digits = 2)) %>%
    unique()
  return(df)
}


plot_bar <- function(df){
  p_relevant <- df %>%
    filter(relevant == 1) %>%
    filter(BIDS_type == "anat") %>%
    ggplot(aes(x = BIDS_sequence, y = freq, fill = session)) +
    geom_bar(position="dodge", stat = "identity") +
    facet_grid(. ~ BIDS_type, scales = "free_x", space = "free_x") +
    theme(legend.position="top",
          axis.text.x = element_text(angle = 45, hjust=1)) +
    xlab("")+
    ggtitle("Relevant Sequences") +
    ylab("Number of scans")

  p_irrelevant <- df %>%
    filter(relevant == 0) %>%
    ggplot(aes(x = BIDS_sequence, y =freq, fill = session)) +
    geom_bar(position="dodge", stat = "identity") +
    facet_grid(. ~ BIDS_type, scales = "free_x", space = "free_x") +
    theme(legend.position="none") +
    xlab("")+
    ylab("Number of scans") +
    ggtitle("Irrelevant Sequences")

  p_relevant / p_irrelevant +
    plot_annotation(
      title = 'Sequence overview'
    ) &
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust=1),
          legend.position="none")
  #ggplotly(p) %>% layout(margin = list(l = 100, r = 20, b = 50, t = 100))
}

calculate_comp_subjects <- function(df, sessions) {
  df <- df %>%
    select(subject, session, group, BIDS_sequence, relevant) %>%
    filter(relevant == 1) %>%
    select(-relevant) %>%
    group_by(across(everything())) %>%
    count() %>%
    ungroup %>%
    spread(session, n) %>%
    mutate("RatioCompleteSurveys" = rowSums(select(., contains("ses-")), na.rm = TRUE)/sessions) %>%
    group_by(subject) %>%
    mutate("RatioCompleteSubjects" = mean(RatioCompleteSurveys)) %>%
    ungroup()
  return(df)
}


show_settings <- function(df) {
  df <- df %>%
    select(-filename,
           -subject,
           -session,
           -level,
           -input_json,
           -BIDS_json,
           -sequence,
           -BIDS_sequence_ID,
           -SeriesDescription,
           -ProtocolName,
           -InstitutionalDepartmentName,
           -InstitutionName,
           -Manufacturer,
           -ManufacturersModelName,
           -MagneticFieldStrength,
           -Modality,
           -DeviceSerialNumber,
           -SoftwareVersions,
           -StationName) %>%
    select(-AcquisitionNumber,
      -ImageOrientationPatientDICOM,
      -ImageBIDS_type,
      -ProcedureStepDescription,
   #   -AccessionNumber,
      -StudyID,
      -StudyInstanceUID,
      -SeriesNumber,
      -SeriesInstanceUID
    ) %>%
    select(
      -AcquisitionDateTime,
      -AcquisitionTime,
      -PatientBirthDate,
      -PatientID,
      -PatientSex,
      -PatientName,
      -PatientWeight,
#      -PhilipsRescaleSlope
    ) %>%
    mutate(across(where(is.numeric), round, digits = 2)) %>%
    group_by(across(everything())) %>%
    count() %>%
    ungroup() %>%
    select(BIDS_sequence, BIDS_type, n, group_BIDS, relevant, everything())
  return(df)
}
