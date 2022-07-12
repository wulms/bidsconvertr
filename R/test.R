# library(tidyverse)
# library(DT)
# library(shiny)
# library(shinythemes)
#
# example_df <- data.frame(
#   x = c("$1", "-2%", "$3"),
#   y = c("$10", "10%", "$20"),
#   z = c("$10", "-10%", "$20"),
#   w = c("-$10", "-10%", "$20")
# )
#
# editTable <- function(DF, outdir=getwd(), outfilename="table"){
#
#   # based on these: https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#anatomy-imaging-data
#
#
#
#   # DF <- check_BIDS_plausibility(DF)
#
#   print(DF)
#
#
#   dt_output = function(title, id) {
#     fluidRow(column(
#       12, h4(paste0(title)),
#       hr(), DTOutput(id)
#     ))
#   }
#
#   ui <- shinyUI(fluidPage(theme = shinytheme("readable"),
#
#                           titlePanel("BIDS sequence mapper "),
#                           sidebarLayout(
#                             sidebarPanel(
#
#                               h4("BIDS sequence information from:"),
#                               a("BIDS documentation",
#                                 href = "https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#anatomy-imaging-data"),
#
#                               br(),
#                               h4("Edit your BIDS sequence"),
#                               p("T1 weighted images = T1w"),
#                               p("T2 weighted images = T2w"),
#                               p("Proton density weighted images = PDw"),
#                               p("T2star weighted images = T2starw"),
#                               p("Fluid attenuated inversion recovery images = FLAIR"),
#                               p("BOLD = task-fMRI_bold"),
#                               p("BOLD = task-rsfMRI_bold"),
#                               p("diffusion weighted images = dwi"),
#                               h4("Edit your BIDS sequence type"),
#                               p("Select the type (anat/func/dwi/perf/fmap)"),
#                               h4("Edit the relevance of the sequence"),
#                               p("Only relevant (relevance = 1) sequences are copied to BIDS-specification."),
#
#                               br(),
#                               h4("Shiny app information"),
#                               helpText("Shiny app based on an example given in the rhandsontable package.",
#                                        "Double-click on a cell to edit",
#                                        "Change all cells that contain an 'edit here'"),
#
#                               a("The code for this shiny app is adapted from here",
#                                 href = "http://stla.github.io/stlapblog/posts/shiny_editTable.html"),
#
#                               width = 2
#
#                             ),
#
#                             mainPanel(
#                               actionButton("save", "Save"),
#
#                               # rHandsontableOutput("hot"),
#                               br(),
#                               dt_output('Please edit the red & bold columns (double-click) and "save". Red indicates non-valid BIDS strings. Green indicates a valid "BIDS_sequence", "BIDS_type" and "relevant" column.', 'x1'),
#                               width = 10
#
#
#
#                             )
#                           )
#   ))
#
#   server <- shinyServer(function(input, output) {
#
#     values <- reactiveValues()
#
#     data_reactive <- reactiveVal(DF)
#
#
#
#     # DF formatting
#     output$x1 <- renderDT({
#       DF %>%
#        # check_BIDS_plausibility() %>%
#         datatable(selection = 'none',
#                   # container = sketch,
#                   editable = list(target = 'cell'),
#                   # rownames = FALSE,
#                   options = list(pageLength = 100,
#                                  dom = "t",
#                                  autoWidth = FALSE,
#                                  #headerCallback = JS(headerCallback),
#                                  initComplete = JS("
#                         function(settings, json) {
#                           $(this.api().table().header()).css({
#                           'font-size': '12px',
#                           });
#                         }")
#                   )
#         )%>%
#         formatStyle(columns = c(1:9), fontSize = '75%')
#     },
#     server = TRUE)
#
#
#
#     #  update the table, apply the BIDS plausibility check
#     proxy <- DT::dataTableProxy("x1")
#
#     observeEvent(input$x1_cell_edit, {
#       info <- input$x1_cell_edit
#
#       new_DF <<- DT::editData(data_reactive(), info, proxy, resetPaging = FALSE) %>%
#         check_BIDS_plausibility()
#
#       replaceData(proxy, new_DF, resetPaging = FALSE)
#       data_reactive(new_DF)
#     })
#
#
#     ## Save
#     observeEvent(input$save, {
#
#       fileType <- "TSV"
#       finalDF <- isolate(values[["new_DF"]])
#       finalDF <- new_DF
#
#       finalDF <- finalDF %>%
#         select(-valid, -matched, -unmatched)
#
#       # print(finalDF)
#
#       readr::write_tsv(finalDF, file.path(outdir, sprintf("%s.tsv", outfilename)))
#
#     })
#
#
#     onStop(function() {
#       stopApp("Sequence mapper stopped.")
#
#       cat("Session stopped. \n\nValidate 'sequence_map.tsv' for BIDS plausibility. Only sequences marked as 'relevant' are checked. \n\n ")
#
#       # bids_unmatched <- file.path(outdir, sprintf("%s.tsv", outfilename)) %>%
#       #   readr::read_tsv(file = ., show_col_types = FALSE) %>%
#       #   check_BIDS_plausibility(.) %>%
#       #   filter(relevant == 1 & stringr::str_length(unmatched) > 0)
#       #
#       # if(nrow(bids_unmatched) > 0){
#       #   cat("Possible unplausible BIDS sequence-ID's were found among those that were selected as 'relevant'. Please investigate these:\n\n")
#       #   print(bids_unmatched)
#       # } else {
#       #   cat("Your BIDS-sequences are valid.\n\n")
#
#         #editTable(readr::read_tsv("G:/Science/bidsconvertr_july2022/bidsconvertr/sequence_map.tsv"))
#       # }
#     })
#
#   })
#
#
#
#
#
#   ## run app
#   runApp(list(ui=ui, server=server))
#   return(invisible())
#
#
# }
#
# i = 1
# while (i == 1) {
#   editTable(example_df)
#   Sys.sleep(5)
# }
