# Adam Griffin, 2018-12-14
# server script for Shiny app for Bayesian Estimation of Land Use Change
#
# Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.

library(shiny)
library(reshape)
library(ggplot2)

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
  
  # #### COMPUTED ONCE ####
  # sb_prior <- 4
  # sobs_prior <- 6
  # sl_prior <- 0.3
  # sbobs_prior <- 2.2
  # 
  # names <- c(
  #   "Year-to-year land use change",
  #   "Observational error in AC",
  #   "Gross Losses/Gains observational error",
  #   "Transition matrix observation error")
  # 
  # sd_table <- data.frame("Prior_standard_deviations" = names,
  #   "Value" = c(sb_prior, sobs_prior, sl_prior, sbobs_prior),
  #   row.names = c("sb_prior", "sobs_prior", "sl_prior", "sbobs_prior"),
  #   stringsAsFactors=F)
  # 
  # #### dummy tables for layout ####
  # luc_freq <- data.frame("LUC_from"=c("forest", "forest", "crop", "grassland", "other"),
  #                        "LUC_to"=c("urban", "crop", "grassland", "crop", "urban"),
  #                        "frequency"=c(0.25, 0.1, 0.04, 0.03, 0.025))
  # 
  # av_persist <- data.frame("Land_Use" = c("forest", "grassland", "crop", 
  #                                         "urban", "grazing", "other"),
  #                          "Av_Persistance" = c(0.3, 0.25, 0.37, 0.05, 0.1, 0.03))
  # 
  # 
  # spatial_var <- data.frame("Year"=1969:2015,
  #                           "Forest"=round(runif(47,0,8),2),
  #                           "Grassland"=round(runif(47,0,8),2),
  #                           "Crop"=round(runif(47,0,8),2),
  #                           "Urban"=round(runif(47,0,8),2),
  #                           "Grazing"=round(runif(47,0,8),2),
  #                           "Other"=round(runif(47,0,8),2))
  
  
  
  #### OUTPUTS #### 
  
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2] 
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
  })
  
  output$factorOAAT <- renderTable({
    
    # takes input in (1,2,3), converts to (0.1, 1, 10)
    scale <- 10^(as.numeric(input$scaling_factor) - 2)
    std <- sd_table
    y <- as.numeric(input$parameter_group)
    std[y, 2] <- as.numeric(sd_table[y, 2])*scale  # scales
    std
    
  },
  width='90%',
  striped=T, bordered=T, align='c', rownames=F)
  
  output$luc_freqA <- renderTable(luc_freq, 
    width='90%',
    striped=T, bordered=T, align='c', rownames=F)
  
  output$av_persistA <- renderTable(av_persist, 
    width='90%',
    striped=T, bordered=T, align='c', rownames=F)
  
  output$spatial_varA <- renderTable(spatial_var, 
    #width='90%',
    striped=T, bordered=T, align='c', rownames=F)
  
  output$spatial_plot <- renderPlot({
    ggplot(spatial_melt, aes(Year, Spatial_Variability)) + 
      geom_path(aes(col=Land_Use)) + 
      scale_colour_brewer(palette="Dark2") +
      theme(legend.position="bottom") + 
      ylab("Average number of Same-type neighbours")
  })
  
})
