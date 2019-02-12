# Adam Griffin, 2018-12-14
# UI script for Shiny app for Bayesian Estimation of Land Use Change
#
# Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.
#
# TODO: add to Lancaster Shiny server
# TODO: find CEH style for app (using leaflet?)
# TODO: split model and project information into two markdown files. Needs
# placeholder for figures?

library(shiny)
library(ggplot2)
library(shinyWidgets)
library(plotly)
library(htmltools)

library(markdown)
library(knitr)

### BEFORE COMPILING, KNIT aboutpage.Rmd AND modelpage.Rmd USING RSTUDIO ###

# markdownToHTML("aboutpage.md", "./aboutpage.html",
#                stylesheet = "markdown.css",
#                extensions="tables",
#                options = "mathjax")
# markdownToHTML("modelpage.md", "./modelpage.html",
#                stylesheet = "markdown.css",
#                extensions = c("tables", "latex_math"),
#                options = "mathjax")

datasets_full <- c(
  "Agricultural Census",
  "Agricultural Land Capability Map",
  "Corine Land Cover Map",
  "Countryside Survey",
  "EDINA Agricultural Census",
  "Forestry Commission New Planting",
  "Integrated Administration and Control System",
  "CEH Land Cover Map",
  "Forestry Commission National Forest Estates and Woodlands")

datasets_initials <- c("AC", "ALCM", "Corine", "CS", "EAC", "FC", "IACS",
                       "LCM", "NFEW")

shinyUI(
  #####
  fluidPage(
    fluidRow(
      column(width = 3,
             img(src = "CEH_RGB_PMS.png",width = "290",height = "70",
                 style="margin:10px 0px")),
      
      column(width=5, h2("Bayesian Estimation of Land Use Change")),
      
      column(width = 4,
             img(src = "UK_SCAPE_Logo_Positive.png",width = "368",height = "70",
                 style="margin:10px 0px"))
    ),
    
    #titlePanel("Bayesian Estimation of Land Use Change"),
    
    fluidRow(column(
      width = 12,
      navbarPage("BELUC",
                 
         #### PARAMETERS AND SUMMARY TAB ####
         tabPanel("Plot",
            fluidPage(
              fluidRow(
                column(width = 4, # User choices and initial parameters 
                   wellPanel(
                     
                     h2("Dataset choices"),
                     helpText("Select the datasets you wish to include in this",
                              "evaluation of the model."),
                     checkboxGroupInput("dataset_checkbox",
                                        "Datasets included:",
                                        choiceNames = datasets_full,
                                        choiceValues = datasets_initials,
                                        selected = datasets_initials, 
                                        width="90%"),
                     
                     h2("Parameter scaling choices"),

                     uiOutput("LUC_s"), # This appear if applicable due to 
                     uiOutput("NET_s"), # dataset choices
                     uiOutput("GROSS_s"),
                     uiOutput("PRED_s"),
                     
                     tableOutput("factorOAAT")
                     
                   )),
                
                
                column(width = 3,
                       
                       # Column containing resultant tables/graphs
                       h3(paste("Summary of Land Use Change")),
                       
                       h4("Most frequent land use changes"),
                       tableOutput("luc_freqA"),
                       
                       h4("Average proportion of land use types"),
                       tableOutput("av_persistA")
                       
                ),
                column(width = 5,
                       
                       # Column containing resultant tables/graphs
                       h3("Spatial variability over time"),
                       
                       #tableOutput("spatial_varA")
                       plotlyOutput("spatial_plot")
                       
                )
              )
            )
         ),
                 
         #### MAP/REALISATION TAB ####
         tabPanel("Map Simulation",
                  fluidPage(
                    fluidRow(
                      column(width = 12,
                             
                        helpText("Map showing possible realisation?")
                             
                      )
                    )
                  )
         ),
         
         #### MODEL TAB ####
         tabPanel("Model",
                  fluidPage(
                    fluidRow(
                      column(width = 12,
                             
                         withMathJax(includeHTML('modelpage.html'))
                             
                      )
                    )
                  )
         ), 
         
         #### ABOUT TAB ####
         tabPanel("About",
                  fluidPage(
                    fluidRow(
                      column(width = 12,
                             ## The mathjax doesn't show up in the Rstudio preview window.
                             withMathJax(includeHTML('aboutpage.html'))
                             
                      ) 
                    ) 
                  ) 
         ) 
      ) 
    ) 
    ) 
  ) 
)