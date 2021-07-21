library(shiny)
library(openxlsx)
library(tidyverse)
library(rhandsontable)
library(data.table)
library(tibble)
library(shinyjs)


shinyUI(
    fluidPage(
        useShinyjs(),
        
        title = 'Shares Apportioning Tool',
        
        h1('Shares Apportioning Tool'),
        wellPanel(   
            fluidRow(
                column(4,
                       actionButton("crop", "Crop"),
                       shinyjs::hidden(actionButton("apportion", "Apportion")),
                       shinyjs::hidden(actionButton("sel_all", "Select All")),
                       shinyjs::hidden(actionButton("desel_all", "Deselect All"))
                )
            )
        ),
        
        wellPanel(id = "well1",
                  fluidRow(
                      rHandsontableOutput('table')
                  )
        ),
        
        shinyjs::hidden(wellPanel(id = "well2",
                                  fluidRow(
                                      rHandsontableOutput('table2')
                                  )
        )
        )
        
    )
)