# Adam Griffin, 2019-01-04
# Global script which contains pre-computed values to use in the server and ui
# scripts.
#
## Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.

# global variables for both server and ui, called once when app started on server.
library('shiny')

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

# sd_table <- data.frame(
#   "Prior_standard_deviations" = names,
#   "Value"         = c(sb_prior, sobs_prior, sl_prior, sbobs_prior),
#   row.names       = c("sb_prior", "sobs_prior", "sl_prior", "sbobs_prior"),
#   stringsAsFactors=F)

lc <- c("forest", "crop", "grass", "rough", "urban", "other")

cols <- c('rgba(228,26,28,1)',
          'rgba(55,126,184,1)',
          'rgba(77,175,74,1)',
          'rgba(152,78,163,1)',
          'rgba(255,127,0,1)',
          'rgba(189,189,189,1)')

colsfill <- c('rgba(228,26,28,0.5)',
              'rgba(55,126,184,0.5)',
              'rgba(77,175,74,0.5)',
              'rgba(152,78,163,0.5)',
              'rgba(255,127,0,0.5)',
              'rgba(189,189,189,0.5)')


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

# spatial_melt <- melt.data.frame(spatial_var,
#                                 id.var="Year",
#                                 variable_name="Land_Use")
# colnames(spatial_melt)[3] <- "Spatial_Variability"

load("../../SA/df_SA_notWeighted_2019-02-04.RData")
load("../../SA/df_SA_weighted_2019-02-04.RData")
df_SA <- rbind(df_SA_notWeighted, df_SA_weighted)
