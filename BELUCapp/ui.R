# Adam Griffin, 2018-12-14
# UI script for Shiny app for Bayesian Estimation of Land Use Change
#
# Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.
#
# TODO: act on feedback

# options(show.error.messages = F)
# options(warn=-1)

shinyUI(##### TITLE SECTION #####
        fluidPage(
          fluidRow(
            column(
              width = 3,
              img(
                src = "CEH_RGB_PMS.png",
                width = "290",
                height = "70",
                style = "margin:10px 0px"
              )
            ),
            
            column(width = 5, h2("Bayesian Estimation of Land Use Change")),
            
            column(
              width = 4,
              img(
                src = "UK_SCAPE_Logo_Positive.png",
                width = "368",
                height = "70",
                style = "margin:10px 0px"
              )
            )
          ),
          
          ##### DATA SELECTION #####
          
          fluidRow(
            column(width = 4,
              wellPanel(
                h3("Dataset choices"),
                helpText(
                  "Select the datasets you wish to include in this",
                  "evaluation of the model. Currently not functional;",
                  "parameters associated to unselected datasets are", 
                  "fixed to their default value."
                ),
                checkboxGroupInput(
                  "dataset_checkbox",
                  "Datasets included:",
                  choiceNames = datasets_full,
                  choiceValues = datasets_initials,
                  selected = datasets_initials,
                  width = "90%"
                ),
                
                h3("Parameter scaling choices"),
                
                # These appear if applicable to dataset choices
                uiOutput("LUC_s"),
                uiOutput("NET_s"),
                uiOutput("GROSS_s"),
                uiOutput("PRED_s"),
                
                h3("Weighting Selection"),
                checkboxInput("weighted_check",
                              "Inverse Weighted Likelihood",
                              T),
                
                h3("Model diagnostics:"),
                htmlOutput("scaling_factor")  # general diagnostics
              )
          ),
          column(
            width = 8,
            navbarPage(
              "BELUC",
              
              #### PARAMETERS AND SUMMARY TAB ####
              tabPanel("Plot",
               fluidPage(
                 fluidRow(
                   column(width = 12,
                   
                   h3("Spatial variability over time"),
                   h4("Growth (shown as positive) and Losses (shown as negative)"),
                   checkboxInput("show_bounds_check",
                                 "Show 95% quantile bounds?",
                                 T),
                   
                   radioButtons("relative_areas",
                                "Figure scaling:",
                                choiceNames = c("Absolute Area", "Percentage Change"),
                                choiceValues = c("AbsA","PerC"),
                                selected = "PerC",
                                inline = TRUE),
                   
                   helpText(
                     "Drag box and double-click to zoom. Double-click without",
                     "selection to reset to automatic zoom. Use tickboxes below",
                     " to show and hide landcover types. Shaded regions are 95%",
                     "credible intervals."
                   ),
                   
                   ## Key plot of gains and losses
                   plotOutput(
                     "spatial_plot",
                     height = 500,
                     dblclick = "plot1_dblclick",
                     brush = brushOpts(id = "plot1_brush",
                                       resetOnNew = TRUE)
                   ),
                   
                   checkboxGroupInput(
                     "linechoices",
                     "Select Land Cover types to show:",
                     choiceNames = list(
                       tags$span(lc[2], style = "background-color: #b3e2cd;"),
                       tags$span(lc[1], style = "background-color: #fdcdac;"),
                       tags$span(lc[3], style = "background-color: #cbd5e8;"),
                       tags$span(lc[6], style = "background-color: #f4cae4;"),
                       tags$span(lc[4], style = "background-color: #e6f5c9;"),
                       tags$span(lc[5], style = "background-color: #fff2ae;")
                     ),
                     # ordered colours (alphabetical)
                     choiceValues = lc[c(2, 1, 3, 6, 4, 5)],
                     inline = T,
                     selected = lc[c(2, 1, 3, 6, 4, 5)]
                   ),
                   
                   h3("Most frequent land use changes"),
                   tableOutput("luc_freqA"),
                   
                   h3("Average proportion of land use types"),
                   tableOutput("av_persistA")

                 )
                 )
                 )
               ),
              
              #### EXTRA MATRICES TAB (BETA, A(t)) ####
              tabPanel("Matrices",
                       fluidPage(
                         fluidRow(
                           column(width = 12,
                                  plotOutput("beta_visual")
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