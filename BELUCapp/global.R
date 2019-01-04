# Adam Griffin, 2019-01-04
# Global script which contains pre-computed values to use in the server and ui
# scripts. 
#
## Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.

# global variables for both server and ui, called once when app started on server.
library(shiny)

#### Standard Deviations for prior distributions ####

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

 