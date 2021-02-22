#
# Title: EAF to TXT Shiny App
# Author: Naiti Bhatt
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/

# load packages
library(shiny)
library(tidyverse)
library(here)
library(magick)
library(readr)
library(phonfieldwork)

# load helper function
source(here("processEAF.R"))

# Define UI for application
ui <- fluidPage(

    # Application title
    titlePanel("EAF to TXT"),

    # Sidebar with file input and download ability
    sidebarLayout(
        sidebarPanel(
            # Input: Select a file ---------
            fileInput("file", "Choose EAF File",
                      multiple = FALSE,
                      accept =NULL),
            
            
            # Horizontal line --------
            tags$hr(),
            
            # Output: download data ---------
            downloadButton("downloadData", "Download")
        ),
        
        # Show the loaded dataframe in main panel
        mainPanel(
           tableOutput("contents")
        )
    )
)


# Define server logic to read selected file ----
server <- function(input, output) {
    
    output$contents <- renderTable({
        
        # input$file will be NULL initially. After the user selects
        # and uploads a file, all rows  of that data file will be shown.
        req(input$file)
        
        # try to read in eaf file
        tryCatch(
            {
                # use helper function to read and process input file for output
                d_output <- processEAF(input$file$datapath)
            },
            error = function(e) {
                # return a safeError if a parsing error occurs
                stop(safeError(e))
            }
        )
        # if we read in file, return it!
        return(d_output)
    })

    
    # Downloadable txt of uploaded file ----
    output$downloadData <- downloadHandler(
        
        #input: none
        # output: filename for download
        filename = function() {
            # TODO: remove .eaf from filename to save name of output (not working)
            file <- input$file
            str_remove(toString(file), ".eaf")
            paste(file, ".txt", sep = "")
        },
        
        # input: filename of txt
        # output: none, writes tab delimited txt file 
        content = function(file) {
            # use helper function to read and process input file for output
            d_output <- processEAF(input$file$datapath)
            # write out txt file, use tabs to separate and don't include row or column names or quotes
            write.table(d_output, file, sep="\t", row.names=FALSE, col.names = FALSE, quote=FALSE)
        }
    )
    
}

# Run the application 
shinyApp(ui = ui, server = server)
