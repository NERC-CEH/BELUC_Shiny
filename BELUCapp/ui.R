# Adam Griffin, 2018-12-14
# UI script for Shiny app for Bayesian Estimation of Land Use Change
#
# Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.
#
# TODO: add to Lancaster Shiny server
# TODO: act on feedback

library(shiny)
library(ggplot2)
library(shinyWidgets)
library(plotly)
library(htmltools)

library(markdown)
library(knitr)

# options(show.error.messages = F)
# options(warn=-1)



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
                     
                     h3("Dataset choices"),
                     helpText("Select the datasets you wish to include in this",
                              "evaluation of the model."),
                     checkboxGroupInput("dataset_checkbox",
                                        "Datasets included:",
                                        choiceNames = datasets_full,
                                        choiceValues = datasets_initials,
                                        selected = datasets_initials,
                                        width="90%"),
                     
                     h3("Parameter scaling choices"),
                     
                     uiOutput("LUC_s"), # This appear if applicable due to 
                     uiOutput("NET_s"), # dataset choices
                     uiOutput("GROSS_s"),
                     uiOutput("PRED_s"),

                     # sliderTextInput("LUC_slider",
                     #                 "Scaling for CV_net:",
                     #                 choices = c("0.1", "1.0", "10"),
                     #                 selected = "1.0",
                     #                 grid=T),
                     # sliderTextInput("NET_slider",
                     #                 "Scaling for CV_net:",
                     #                 choices = c("0.01", "0.1", "1.0"),
                     #                 selected = "0.1",
                     #                 grid=T),
                     # sliderTextInput("GROSS_slider",
                     #                 "Scaling for CV_net:",
                     #                 choices = c("0.02", "0.2", "2.0"),
                     #                 selected = "0.2",
                     #                 grid=T),
                     # sliderTextInput("PRED_slider",
                     #                 "Scaling for CV_net:",
                     #                 choices = c("0.02", "0.2", "2.0"),
                     #                 selected = "0.2",
                     #                 grid=T),
                     h3("Weighting Selection"),
                     checkboxInput("weighted_check",
                                   "Inverse Weighted Likelihood",
                                   T),
                     
                     h3("Model diagnostics:"),
                     htmlOutput("scaling_factor")
                   )),
                
                column(width = 8,
                       
                       # Column containing resultant tables/graphs
                       h3("Spatial variability over time"),
                       
                       checkboxInput("show_bounds_check",
                                     "Show 95% quantile bounds?",
                                     T),
                       
                       #tableOutput("spatial_varA")
                       helpText("Single-click on lines in the legend to remove/restore that land cover. Double-click to remove/restore all OTHER land cover. Drag on axes to pan/zoom. Hover over plot to show plotly tools (topleft)."),
                       plotlyOutput("spatial_plot", height='100%'),
                       
                       
                       # # Column containing resultant tables/graphs
                       # h3(paste("Summary of Land Use Change")),
                       
                       h3("Most frequent land use changes"),
                       tableOutput("luc_freqA"),
                       
                       h3("Average proportion of land use types"),
                       tableOutput("av_persistA")
                       
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
                             includeHTML('modelpage3.html')
                      )
                    )
                  )
         ),
         
         #### ABOUT TAB ####
         tabPanel("About",
                  fluidPage(
                    fluidRow(
                      column(width = 12,
                             includeHTML('aboutpage2.html')
                      )
                    )
                  )
         )
      ) 
    ) 
    ) 
  ) 
)