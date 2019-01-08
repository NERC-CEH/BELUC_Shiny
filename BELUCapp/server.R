# Adam Griffin, 2018-12-14
# server script for Shiny app for Bayesian Estimation of Land Use Change
#
# Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.

library(shiny)
library(reshape)
library(ggplot2)
library(shinyWidgets)
library(shinythemes)
library(htmltools)
library(leaflet)
library(markdown)
library(knitr)

#### COMPUTED ONCE ####
sb_prior <- 4
sobs_prior <- 6
sl_prior <- 0.3
sbobs_prior <- 2.2

names <- c(
  "Year-to-year land use change",
  "Observational error in AC",
  "Gross Losses/Gains observational error",
  "Transition matrix observation error")

sd_table <- data.frame("Prior_standard_deviations" = names,
                       "Value" = c(sb_prior, sobs_prior, sl_prior, sbobs_prior),
                       row.names = c("sb_prior", "sobs_prior", "sl_prior", "sbobs_prior"),
                       stringsAsFactors=F)

#### dummy tables for layout ####
luc_freq <- data.frame("LUC_from"=c("forest", "forest", "crop", "grassland", "other"),
                       "LUC_to"=c("urban", "crop", "grassland", "crop", "urban"),
                       "frequency"=c(0.25, 0.1, 0.04, 0.03, 0.025))

av_persist <- data.frame("Land_Use" = c("forest", "grassland", "crop", 
                                        "urban", "grazing", "other"),
                         "Av_Persistance" = c(0.3, 0.25, 0.37, 0.05, 0.1, 0.03))


spatial_var <- data.frame("Year"=1969:2015,
                          "Forest"=round(runif(47,0,8),2),
                          "Grassland"=round(runif(47,0,8),2),
                          "Crop"=round(runif(47,0,8),2),
                          "Urban"=round(runif(47,0,8),2),
                          "Grazing"=round(runif(47,0,8),2),
                          "Other"=round(runif(47,0,8),2))

spatial_melt <- melt.data.frame(spatial_var, id.var="Year", variable_name="Land_Use")
colnames(spatial_melt)[3] <- "Spatial_Variability"

shinyServer(function(input, output) {
  
  #### UI COMPONENTS ####
  
  output$LUC_s <- renderUI({
    if(slider_allow1()){
      selectInput("LUC_slider",
                  "Scaling for SD_LUC", choices=list(0.1, 1, 10), selected=1)
    }
  })
  
  output$NET_s <- renderUI({
    if(slider_allow2()){
      selectInput("NET_slider", 
                  "Scaling for SD_NET", choices=list(0.1, 1, 10), selected=1)
    } 
  })
  
  output$GROSS_s <- renderUI({
    if(slider_allow3()){
      selectInput("GROSS_slider",
                  "Scaling for SD_GROSS", choices=list(0.1, 1, 10), selected=1)
    }
  })
  output$PRED_s <- renderUI({
    if(slider_allow4()){
      selectInput("PRED_slider",
                  "Scaling for SD_PRED", choices=list(0.1, 1, 10), selected=1)
    }
  })

  
  #### OUTPUTS #### 
  
  output$factorOAAT <- renderTable({
    # OAAT: one at a time, not currently true.
    # Shows chosen parameter values for prior SD.
    # takes input in (1,2,3), converts to (0.1, 1, 10)
    
    ins <- c(input$LUC_slider,
             input$NET_slider,
             input$GROSS_slider,
             input$PRED_slider)
    slots <- which(c(slider_allow1(), slider_allow2(), 
                     slider_allow3(), slider_allow4()))
    ins <- ins[slots]
    std <- sd_table[slots,]
    for(y in 1:length(slots)){
      scale <- as.numeric(ins[y])
      std[y, 2] <- as.numeric(sd_table[y, 2])*scale  # scales
    }
    std
    
  }, width='100%', striped=T, bordered=T, align='c', rownames=F)
  
  
  #### RESULTS ####
  output$luc_freqA <- renderTable(
    head(luc_freq[order(luc_freq$frequency, decreasing=T),],10), 
    width='100%', digits=3,
    striped=T, bordered=T, align='c', rownames=F)
  
  output$av_persistA <- renderTable(av_persist, 
    width='100%', digits=3,
    striped=T, bordered=T, align='c', rownames=F)
  
  # output$spatial_varA <- renderTable(spatial_var, 
  #   width='90%',
  #   striped=T, bordered=T, align='c', rownames=F)
  
  output$spatial_plot <- renderPlot({
    ggplot(spatial_melt, aes(Year, Spatial_Variability)) + 
      geom_path(aes(col=Land_Use)) + 
      scale_colour_brewer(palette="Dark2") +
      theme(legend.position="bottom") + 
      ylab("Average number of Same-type neighbours")
  })
  
  output$scaling_factor <- renderPrint(slider_allow4())
  
  #### REACTIVE OBJECTS ####
  
  slider_allow1 <- reactive({ "CS" %in% input$dataset_checkbox })
  slider_allow2 <- reactive({ "AC" %in% input$dataset_checkbox })
  slider_allow3 <- reactive({  "EAC" %in% input$dataset_checkbox })
  slider_allow4 <- 
    reactive({ all(c("Corine","IACS","NFEW") %in% input$dataset_checkbox) })
  
})
