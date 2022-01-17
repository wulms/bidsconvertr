
editTable <- function(DF, outdir=getwd(), outfilename="table"){
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
                              br(),
                              h4("Edit your BIDS sequence type"),
                              p("Select the type (anat/func/dwi)"),
                              br(),
                              h4("Edit the relevance of the sequence"),
                              p("Only relevant (relevance = 1) sequences are copied to BIDS-specification."),
                              br(),
                              br(),
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
                              actionButton("cancel", "Cancel last action"),
                              br(), br(),

                              rHandsontableOutput("hot"),
                              br()



                            )
                          )
  ))

  server <- shinyServer(function(input, output) {

    values <- reactiveValues()

    ## Handsontable
    observe({
      if (!is.null(input$hot)) {
        values[["previous"]] <- isolate(values[["DF"]])
        DF = hot_to_r(input$hot)
      } else {
        if (is.null(values[["DF"]]))
          DF <- DF
        else
          DF <- values[["DF"]]
      }
      values[["DF"]] <- DF
    })

    output$hot <- renderRHandsontable({
      DF <- values[["DF"]]
      if (!is.null(DF))
        rhandsontable(DF, useTypes = as.logical(FALSE), stretchH = "all")
    })

    ## Save
    observeEvent(input$save, {
      fileType <- "TSV"
      finalDF <- isolate(values[["DF"]])

      readr::write_tsv(finalDF, file.path(outdir, sprintf("%s.tsv", outfilename)))

    }
    )

    ## Cancel last action
    observeEvent(input$cancel, {
      if(!is.null(isolate(values[["previous"]]))) values[["DF"]] <- isolate(values[["previous"]])
    })

  })

  ## run app
  runApp(list(ui=ui, server=server))
  return(invisible())
}
