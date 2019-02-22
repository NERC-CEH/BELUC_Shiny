# Adam Griffin, 2019-01-04
# Global script which contains pre-computed values to use in the server and ui
# scripts.
#
## Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.

# global variables for both server and ui, called once when app started on server.
# needed_packages <- c('shiny', 'ggplot2', 'shinyWidgets', 'plotly',
#                      'htmltools', 'markdown', 'knitr', 'reshape', 
#                      'leaflet', 'shinythemes')
# for(p in needed_packages){
#   if(p %in% rownames(installed.packages()) == F) install.packages(p)
#   library(p, character.only=T)
# }

library('shiny')
library('ggplot2')
library('shinyWidgets')
library('plotly')
library('htmltools')
library('markdown')
library('knitr')
library('reshape')
library('leaflet')
library('shinythemes')
library('RColorBrewer')
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

lc <- c("forest", "crop", "grass", "rough", "urban", "other")
#lc <- sort(lc)

# cols <- c('rgba(228,26,28,1)',
#           'rgba(55,126,184,1)',
#           'rgba(77,175,74,1)',
#           'rgba(152,78,163,1)',
#           'rgba(255,127,0,1)',
#           'rgba(189,189,189,1)')
# 
# colsfill <- c('rgba(228,26,28,0.5)',
#               'rgba(55,126,184,0.5)',
#               'rgba(77,175,74,0.5)',
#               'rgba(152,78,163,0.5)',
#               'rgba(255,127,0,0.5)',
#               'rgba(189,189,189,0.5)')

dark2set <- setNames(brewer.pal(6,"Dark2"), sort(lc))
pastel2set <- setNames(brewer.pal(6,"Pastel2"), sort(lc))

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


#### dummy tables for layout ####
luc_freq <- data.frame(
  "LUC_from" =c("forest", "forest", "crop", "grassland", "other"),
  "LUC_to"   =c("urban", "crop", "grassland", "crop", "urban"),
  "frequency"=c(0.25, 0.1, 0.04, 0.03, 0.025))

av_persist <- data.frame("Land_Use" = c("forest", "grassland", "crop",
                                        "urban", "grazing", "other"),
                         "Av_Persistance" = c(0.3, 0.25, 0.37, 0.05, 0.1, 0.03))


spatial_var <- data.frame("Year"=1969:2015,
                          "Forest"=round(runif(47,0,8),2),
                          "Improved_Grassland"=round(runif(47,0,8),2),
                          "Crop"=round(runif(47,0,8),2),
                          "Urban"=round(runif(47,0,8),2),
                          "Rough_Grazing"=round(runif(47,0,8),2),
                          "Other"=round(runif(47,0,8),2))

beta_fake <- matrix(0, 6, 6)
beta_fake[1:36] <- sample.int(100, 36, replace=T)
for(i in 1:6) beta_fake[i,i] <- 0
colnames(beta_fake) <- lc
rownames(beta_fake) <- lc

load("./Data/df_SA_notWeighted_2019-02-04.RData")
load("./Data/df_SA_weighted_2019-02-04.RData")
df_SA <- rbind(df_SA_notWeighted, df_SA_weighted)
