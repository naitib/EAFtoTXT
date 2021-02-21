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
#
library(shiny)
library(tidyverse)
library(here)
library(magick)
library(readr)
library(phonfieldwork)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("EAF to TXT"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            # Input: Select a file ----
            fileInput("file", "Choose EAF File",
                      multiple = FALSE,
                      accept =NULL),
            
            
            # Horizontal line ----
            tags$hr(),
            
            downloadButton("downloadData", "Download")
        ),
        # Button
        
        # Show a plot of the generated distribution
        mainPanel(
           tableOutput("contents")
        )
    )
)


# Define server logic to read selected file ----
server <- function(input, output) {
    
    output$contents <- renderTable({
        
        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, head of that data file by default,
        # or all rows if selected, will be shown.
        
        req(input$file)
        
        # when reading semicolon separated files,
        # having a comma separator causes `read.csv` to error
        tryCatch(
            {
                df <- as_tibble(eaf_to_df(input$file$datapath))
            },
            error = function(e) {
                # return a safeError if a parsing error occurs
                stop(safeError(e))
            }
        )
        
        # add higher level tier and fix time information
        d_processed <- df %>% 
            mutate(super_tier = case_when(
                str_detect(tier_name, "CHI") ~ "CHI",
                str_detect(tier_name, "MA1") ~ "MA1",
                str_detect(tier_name, "FA1") ~ "FA1"
            )) %>% 
            mutate(time_start = time_start*1000,
                   time_end = time_end*1000,
                   time_elapsed = time_end-time_start)
        
        # make output df look like txt file, select relevant rows and arrange
        d_output <- d_processed %>% 
            select(tier_name, super_tier, time_start, time_end, time_elapsed, content) %>% 
            arrange(tier_name)

        return(d_output)

        
    })

    
    # Downloadable txt of selected dataset ----
    output$downloadData <- downloadHandler(
        filename = function() {
            paste(input$file, ".txt", sep = "")
        },
        content = function(file) {
            df <- as_tibble(eaf_to_df(input$file$datapath))
            # add higher level tier and fix time information
            d_processed <- df %>% 
                mutate(super_tier = case_when(
                    str_detect(tier_name, "CHI") ~ "CHI",
                    str_detect(tier_name, "MA1") ~ "MA1",
                    str_detect(tier_name, "FA1") ~ "FA1"
                )) %>% 
                mutate(time_start = time_start*1000,
                       time_end = time_end*1000,
                       time_elapsed = time_end-time_start)
            # make output df look like txt file, select relevant rows and arrange
            d_output <- d_processed %>% 
                select(tier_name, super_tier, time_start, time_end, time_elapsed, content) %>% 
                arrange(tier_name)
            write.table(d_output, file, sep="\t", row.names=FALSE, col.names = FALSE, quote=FALSE)
        }
    )
    
}

# Run the application 
shinyApp(ui = ui, server = server)
