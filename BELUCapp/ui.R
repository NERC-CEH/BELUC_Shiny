# Adam Griffin, 2018-12-14
# UI script for Shiny app for Bayesian Estimation of Land Use Change
#
# Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.
#
# TODO: add to Lancaster Shiny server
# TODO: find CEH style for app (using leaflet?)



library(shiny)
library(shinythemes)
library(htmltools)
library(leaflet)
library(markdown)
library(knitr)

shinyUI(
  #####
  fluidPage(
    fluidRow(
      column(width = 3,
      img(src = "CEH_RGB_PMS.png",width = "290",height = "70")),
      
      column(width=6, h2("Bayesian Estimation of Land Use Change")),
      
      column(width = 3,
      img(src = "UK_SCAPE_Logo_Positive.png",width = "367",height = "70"))
      ),
    
    #titlePanel("Bayesian Estimation of Land Use Change"),
    
    fluidRow(column(
      width = 12,
      navbarPage("BELUC",
                 
        #### PARAMETERS AND SUMMARY TAB         
        tabPanel("Plot",
          fluidPage(
            fluidRow(
              column(width = 3,
                     
                 # Column containing user choices and initial parameters.
                 h2("Parameter choices"),
                 helpText("Information of parameters given in model specification."),
                 selectInput("parameter_group",
                     "Choice of parameter to scale",
                     choices = list(
                       "Year-to-year land use change SD" = 1,
                       "Observational error in AC SD" = 2,
                       "Gross Losses/Gains observational error SD" = 3,
                       "Transition matrix observation error SD" = 4),
                     selected = 1),
                   
                   h4("Prior variance choices"),
                   radioButtons(
                     "scaling_factor",
                     "Scaling factor",
                     choices = list("0.1" = 1,
                                    "1" = 2,
                                    "10" = 3),
                     selected = 2),
                 
                   tableOutput("factorOAAT"),
                 
                   textOutput("scaling_factor")
                     
                   ),
                     
              column(width = 4,
                     
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
                plotOutput("spatial_plot")


              )
              )
            )
          ),
        
        #### MAP/REALISATION TAB ####
        tabPanel("Map Simulation",
                 fluidPage(
                   fluidRow(
                     column(width = 6,
                            
                            helpText("Map showing possible realisation?")
                            
                     )
                   )
                 )
        ),
          
        #### MODEL TAB ####
        tabPanel("Model",
           fluidPage(
             fluidRow(
               column(width = 6,
                      
               helpText(paste("Words about the model. Replace with",
                        "withMathJax(includeHTML('BELUC-evaluation.html'))"))
               
               )
               )
             )
           ), 
        
        #### ABOUT TAB ####
        tabPanel("About",
           fluidPage(
             fluidRow(
               column(width = 12,
                      
                      withMathJax(includeHTML('BELUC-evaluation.html'))

                    ) 
               ) 
             ) 
        #####
        ) 
      ) 
    ) 
    ) 
    ) 
)