#' Creates the BIDS regular expression
#'
#' @return one regular expression containing the BIDS nomenclature
#' @export
#'
#' @examples
create_BIDS_regex <- function(){
  valid_BIDS_prefixes <- c("^(task-[:alnum:]+_)?",
                           "(acq-[:alnum:]+_)?",
                           "(ce-[:alnum:]+_)?",
                           "(rec-[:alnum:]+_)?",
                           "(dir-[:alnum:]+_)?",
                           "(run-[:digit:]+_)?",
                           "(mod-[:alnum:]+_)?",
                           "(echo-[:digit:]+_)?",
                           "(flip-[:digit:]+_)?",
                           "(inv-[:digit:]+_)?",
                           "(mt-(on|off)_)?",
                           "(part-(mag|phase|real|imag)_)?",
                           "(recording-[:alnum:]+_)?") %>% paste(collapse = "")



  valid_BIDS_sequences <- c(
    ### anatomy https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#anatomy-imaging-data
    "(T1w",
    "T2w",
    "PDw",
    "T2starw",
    "FLAIR",
    "inplaneT1",
    "inplaneT2",
    "PDT2",
    "UNIT1",
    "angio",
    ### anatomy - phase images
    "T1map",
    "R1map",
    "T2map",
    "R2map",
    "T2starmap",
    "R2starmap",
    "PDmap",
    "MTRmap",
    "MTsat",
    "T1rho",
    "MWFmap",
    "MTVmap",
    "PDT2map",
    "Chimap",
    "TB1map",
    "RB1map",
    "S0map",
    "M0map",
    ### anatomy - file collections https://bids-specification.readthedocs.io/en/stable/99-appendices/10-file-collections.html
    "VFA",
    "IRT1",
    "MP2RAGE",
    "MESE",
    "MEGRE",
    "MTR",
    "MTS",
    "MPM",
    ### diffusion
    "dwi",
    "sbref",
    ### task
    "bold",
    "cbv",
    "phase",
    ### asl
    "asl",
    "m0scan",
    "aslcontext",
    "asllabeling",
    "physio",
    "stim",
    ### fieldmap
    "magnitud(e|e1|e2)",
    "phase(1|2|diff)",
    "fieldmap",
    "epi",
    ### fieldmap - file collection
    "TB1DAM",
    "TB1EPI",
    "TB1AFI",
    "TB1TFL",
    "TB1RFM",
    "TB1SRGE",
    "RB1COR){1}$") %>% paste(collapse = "|")

  valid_BIDS_regex <- paste0(valid_BIDS_prefixes, valid_BIDS_sequences)

  return(valid_BIDS_regex)
}

#' Checks the plausibility of entered BIDS sequences based on regular expressions.
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
check_BIDS_plausibility <- function(df){

  valid_BIDS_regex <- create_BIDS_regex()

  df <- df %>%
    mutate(valid = str_detect(BIDS_sequence, valid_BIDS_regex) %>%
             as.numeric(),
           valid = ifelse(str_detect(BIDS_type, "^(anat|dwi|func|fmap|perf)$",
                                     negate = TRUE), yes = 0, no = valid),
           valid = ifelse(str_detect(relevant, "^(0|1)$",
                                     negate = TRUE), yes = 0, no = valid),
           matched = str_extract(BIDS_sequence, valid_BIDS_regex),
           unmatched = str_remove_all(BIDS_sequence, valid_BIDS_regex))
  return(df)
}


#' Sequence mapper shiny app.
#'
#' @param DF
#' @param outdir
#' @param outfilename
#'
#' @return
#' @export
#'
#' @examples
editTable <- function(DF, outdir=getwd(), outfilename="table"){

# based on these: https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#anatomy-imaging-data

  cat("\n\n\nSequence mapper started:...\n\n\n")

  DF <- check_BIDS_plausibility(DF)

  # print(DF)


  dt_output = function(title, id) {
    fluidRow(column(
      12, h4(paste0(title)),
      hr(), DTOutput(id)
    ))
  }

  ui <- shinyUI(fluidPage(theme = shinytheme("readable"),

                          titlePanel("BIDS sequence mapper "),
                          sidebarLayout(
                            sidebarPanel(

                              h4("BIDS sequence information from:"),
                              a("BIDS documentation",
                                href = "https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#anatomy-imaging-data"),

                              br(),
                              h4("Edit your BIDS sequence"),
                              p("T1 weighted images = T1w"),
                              p("T2 weighted images = T2w"),
                              p("Proton density weighted images = PDw"),
                              p("T2star weighted images = T2starw"),
                              p("Fluid attenuated inversion recovery images = FLAIR"),
                              p("BOLD = task-fMRI_bold"),
                              p("BOLD = task-rsfMRI_bold"),
                              p("diffusion weighted images = dwi"),
                              h4("Edit your BIDS sequence type"),
                              p("Select the type (anat/func/dwi/perf/fmap)"),
                              h4("Edit the relevance of the sequence"),
                              p("Only relevant (relevance = 1) sequences are copied to BIDS-specification."),

                              br(),
                              h4("Shiny app information"),
                              helpText("Shiny app based on an example given in the rhandsontable package.",
                                       "Double-click on a cell to edit",
                                       "Change all cells that contain an 'edit here'"),

                              a("The code for this shiny app is adapted from here",
                                href = "http://stla.github.io/stlapblog/posts/shiny_editTable.html"),

                              width = 2

                            ),

                            mainPanel(
                              actionButton("save", "Save"),

                              # rHandsontableOutput("hot"),
                              br(),
                              dt_output('Please edit the red & bold columns (double-click) and "save". Red indicates non-valid BIDS strings. Green indicates a valid "BIDS_sequence", "BIDS_type" and "relevant" column.', 'x1'),
                              width = 10



                            )
                          )
  ))

  server <- shinyServer(function(input, output) {

    values <- reactiveValues()

    data_reactive <- reactiveVal(DF)



    # DF formatting
    output$x1 <- renderDT({
      DF %>%
        check_BIDS_plausibility() %>%
      datatable(selection = 'none',
               # container = sketch,
             editable = list(target = 'cell',
                             disable = list(columns = c(0, 1, 2, 3, 7, 8, 9))),
             # rownames = FALSE,
             options = list(pageLength = 100,
                            dom = "t",
                            autoWidth = FALSE,
                            #headerCallback = JS(headerCallback),
                            initComplete = JS("
                        function(settings, json) {
                          $(this.api().table().header()).css({
                          'font-size': '12px',
                          });
                        }")
                        )
             )%>%
      formatStyle('valid',
                  target = "row",
                  color = 'black',
                  backgroundColor = styleEqual(c(0,1), c('tomato', 'lightgreen')))  %>%
        # formatStyle(c("BIDS_sequence", "BIDS_type"),
        #             backgroundColor = 'white') %>%
        formatStyle(c("BIDS_type", "BIDS_sequence", "relevant"),
                    # target = "row",
                    backgroundColor = JS("(/please edit/).test(value) ? 'red' : (/^(anat|dwi|func|fmap|perf)$/).test(value) ? 'lightgreen' : ''"),
                    fontWeight = "bold") %>%
        formatStyle('relevant',
                     #target = "row",
                     backgroundColor = styleEqual(c(0, 1), c('grey', 'lightgreen')),
                    fontWeight =  styleEqual(c(0, 1), c('italics', 'bold')))  %>%
      formatStyle(columns = c(1:9), fontSize = '75%')
      },
      server = TRUE)



    #  update the table, apply the BIDS plausibility check
      proxy <- DT::dataTableProxy("x1")

      observeEvent(input$x1_cell_edit, {
        info <- input$x1_cell_edit

        new_DF <<- DT::editData(data_reactive(), info, proxy, resetPaging = FALSE) %>%
          check_BIDS_plausibility()

       replaceData(proxy, new_DF, resetPaging = FALSE)
       data_reactive(new_DF)
     })


    ## Save
    observeEvent(input$save, {

      fileType <- "TSV"
      finalDF <- isolate(values[["new_DF"]])
      finalDF <- new_DF

      finalDF <- finalDF %>%
        select(-valid, -matched, -unmatched)

      # print(finalDF)

      readr::write_tsv(finalDF, file.path(outdir, sprintf("%s.tsv", outfilename)))

    })


    onStop(function() {
     stopApp("Sequence mapper stopped.")

            cat("Sequence mapper stopped. \n\nValidate 'sequence_map.tsv' for BIDS plausibility. Only sequences marked as 'relevant' are checked. \n\n ")

      bids_unmatched <- file.path(outdir, sprintf("%s.tsv", outfilename)) %>%
        readr::read_tsv(file = ., show_col_types = FALSE) %>%
        check_BIDS_plausibility(.) %>%
        filter(relevant == 1 & stringr::str_length(unmatched) > 0)

      if(nrow(bids_unmatched) > 0){
        cat("Possible unplausible BIDS sequence-ID's were found among those that were selected as 'relevant'. Please investigate these:\n\n")
        print(bids_unmatched)
      } else {
        cat("Your BIDS-sequences are valid.\n\n")

      }

     # Sys.sleep(5)

    })

  })





  ## run app
  runApp(list(ui=ui, server=server))
  return(invisible())


}
