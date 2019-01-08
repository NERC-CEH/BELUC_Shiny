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
                 
        #### PARAMETERS AND SUMMARY TAB         
        tabPanel("Plot",
          fluidPage(
            fluidRow(
              column(width = 4,
                wellPanel(     
                 # Column containing user choices and initial parameters.
                 h2("Parameter choices"),
                 helpText("Select the parameter you wish to scale, followed by",
"the scaling factor you wish to use. The table below will reflect the selected",
"values for the model parameters. Check the boxes for the datasets you wish to",
"be included, and the values will automatically update with each change.", 
"For explanations of abbreviations, see the Model tab."),
                 # selectInput("parameter_group",
                 #     "Choice of parameter to scale",
                 #     choices = list(
                 #       "SD_LUC" = 1,
                 #       "SD_NET" = 2,
                 #       "SD_GROSS" = 3,
                 #       "SD_PRED" = 4),
                 #     selected = 1),
                 #   
                 #   h4("Prior variance choices"),
                 #   radioButtons(
                 #     "scaling_factor",
                 #     "Scaling factor",
                 #     choices = list("0.1" = 1,
                 #                    "1" = 2,
                 #                    "10" = 3),
                 #     selected = 2),

sliderTextInput(
  inputId = "mySliderText",
  label = "Month range slider:",
  choices = month.name,
  selected = month.name[5]
),


                 # conditionalPanel(condition="output.slider_allow[0]",
                 #                  shinyWidgets::sliderTextInput(
                 #                  "LUC_slider", "Scaling for SD_LUC",
                 #                  choices=c("0.1", "1", "10"),
                 #                  selected=1, width="60%", grid=T,
                 #                  force_edges=T
                 #                  )),

                 conditionalPanel(condition="output.slider_allow[1]",
                                 sliderTextInput(
                                   "NET_slider", "Scaling for SD_NET",
                                   choices=c(0.1, 1, 10),
                                   selected=1, width="60%", grid=T
                                 )),
                conditionalPanel(condition="output.slider_allow[2]",
                                 sliderTextInput(
                                   "GROSS_slider", "Scaling for SD_GROSS",
                                   choices=c(0.1, 1, 10),
                                   selected=1, width="60%", grid=T
                                 )),
                conditionalPanel(condition="output.slider_allow[3]",
                                 sliderTextInput(
                                   "PRED_slider", "Scaling for SD_PRED",
                                   choices=c(0.1, 1, 10),
                                   selected=1, width="60%", grid=T
                                 )),
                 
                   tableOutput("factorOAAT"),
                 
                   textOutput("scaling_factor"),
                 
                 h2("Dataset choices"),
                 helpText("Select the datasets you wish to include in this",
                          "evaluation of the model."),
                 checkboxGroupInput("dataset_checkbox",
                                    "Datasets included:",
                                    choiceNames = datasets_full,
                                    choiceValues = datasets_initials,
                                    selected = datasets_initials, 
                                    width="90%")
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
               column(width = 12,
                      
               #helpText(paste("Words about the model. Replace with",
              #          "withMathJax(includeHTML('BELUC-evaluation.html'))"))
               
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
                      ## This doesn't show up in the Rstudio preview window.
                      withMathJax(includeHTML('aboutpage.html'))

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