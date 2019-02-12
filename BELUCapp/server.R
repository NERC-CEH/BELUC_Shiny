# Adam Griffin, 2018-12-14
# server script for Shiny app for Bayesian Estimation of Land Use Change
#
# Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.

library('shiny')
library('reshape')
library('ggplot2')
library('shinyWidgets')
library('shinythemes')
library('htmltools')
library('leaflet')
library('markdown')
library('knitr')
library('plotly')
# options(show.error.messages = F)
# options(warn=-1)

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




shinyServer(function(input, output, session) {
  
  #### UI COMPONENTS ####
  
  output$LUC_s <- renderUI({
    if(slider_allow1()){
      # selectInput("LUC_slider",
      #             "Scaling for SD_LUC", choices=list(0.1, 1, 10), selected=1)
      sliderTextInput("LUC_slider",
                      "Scaling for CV_prior:",
                      choices = c("0.1", "1", "10"),
                      selected = "1",
                      grid=T)
    }
  })
  
  output$NET_s <- renderUI({
    if(slider_allow2()){
      # selectInput("NET_slider", 
      #             "Scaling for SD_NET", choices=list(0.1, 1, 10), selected=1)
      sliderTextInput("NET_slider",
                      "Scaling for CV_net:",
                      choices = c("0.01", "0.1", "1.0"),
                      selected = "0.1",
                      grid=T)
    } 
  })
  
  output$GROSS_s <- renderUI({
    if(slider_allow3()){
      # selectInput("GROSS_slider",
      #             "Scaling for SD_GROSS", choices=list(0.1, 1, 10), selected=1)
      sliderTextInput("GROSS_slider",
                      "Scaling for CV_gross:",
                      choices = c("0.02", "0.2", "2.0"),
                      selected = "0.2",
                      grid=T)
    }
  })
  output$PRED_s <- renderUI({
    if(slider_allow4()){
      # selectInput("PRED_slider",
      #             "Scaling for SD_PRED", choices=list(0.1, 1, 10), selected=1)
      sliderTextInput("PRED_slider",
                      "Scaling for CV_B_cin:",
                      choices = c("0.02", "0.2", "2.0"),
                      selected = "0.2",
                      grid=T)
    }
  })
  
  #### OUTPUTS #### 
  
  #### RESULTS ####
  output$luc_freqA <- renderTable(
    head(luc_freq[order(luc_freq$frequency, decreasing=T),],10), 
    width='100%', digits=3,
    striped=T, bordered=T, align='c', rownames=F)
  
  output$av_persistA <- renderTable(av_persist, 
    width='100%', digits=3,
    striped=T, bordered=T, align='c', rownames=F)
  
  output$spatial_varA <- renderTable(spatial_var,
    width='90%',
    striped=T, bordered=T, align='c', rownames=F)

  output$spatial_plot <- renderPlotly({

    # p <- ggplot(df_ts(), aes(year)) +
    #   scale_colour_brewer(palette="Dark2") +
    #   theme(legend.position="bottom") +
    #   ylab("Year-on-year % growth") +
    #   scale_x_continuous(breaks = seq(1968,2020,by=4)) +
    #   geom_ribbon(aes(ymin=m_G.rel_q025_BC, ymax=m_G.rel_q975_BC,
    #                   fill=land_cover), alpha=0.5) +
    #   scale_fill_brewer(palette="Pastel2") +
    #   theme(legend.position="bottom") +
    #   geom_path(aes(y=m_G.rel_map_BC, col=land_cover), size=1)
    # p
    # 
    
    p1 <- plot_ly(df_ts(), x = df_ts()$year[df_ts()$land_cover==lc[1]])
    
    p2 <- plot_ly(df_ts(), x = df_ts()$year[df_ts()$land_cover==lc[1]])

    
    #layout(yaxis=list(range=c(0,40)))
    show_bounds <- input$show_bounds_check
    for(j in 1:6){
      p1 <- add_trace(p1, x = df_ts()$year[df_ts()$land_cover==lc[j]],
                     y = df_ts()$m_G.rel_map_BC[df_ts()$land_cover==lc[j]],
                     type='scatter',
                     mode='lines',
                     line=list(color=cols[j], width=2),
                     name=lc[j],
                     legendgroup=lc[j],
                     showlegend=T
                     )
      p2 <- add_trace(p2, x = df_ts()$year[df_ts()$land_cover==lc[j]],
                      y = df_ts()$m_L.rel_map_BC[df_ts()$land_cover==lc[j]],
                      type='scatter',
                      mode='lines',
                      line=list(color=cols[j], width=2),
                      name=lc[j],
                      legendgroup=lc[j],
                      yaxis='y2',
                      showlegend=F)
      
      if(show_bounds){
        p1 <- add_trace(p, x = df_ts()$year[df_ts()$land_cover==lc[j]],
                       y = df_ts()$m_G.rel_q975_BC[df_ts()$land_cover==lc[j]],
                       type='scatter', mode='lines',
                       line=list(color=cols[j], width=0),
                       name=paste("97.5%", lc[j]),
                       legendgroup=lc[j],
                       showlegend=F)
        p1 <- add_trace(p, x = df_ts()$year[df_ts()$land_cover==lc[j]],
                       y= df_ts()$m_G.rel_q025_BC[df_ts()$land_cover==lc[j]],
                       type='scatter', 
                       mode='lines',
                       line=list(color=cols[j], width=0),
                       fillcolor=colsfill[j],
                       fill = 'tonexty',
                       name=paste("2.5%", lc[j]),
                       legendgroup=lc[j],
                       showlegend=F)
        
        p2 <- add_trace(p2, x = df_ts()$year[df_ts()$land_cover==lc[j]],
                        y = df_ts()$m_L.rel_q975_BC[df_ts()$land_cover==lc[j]],
                        type='scatter',
                        mode='lines',
                        line=list(color=cols[j], width=0),
                        name=paste("97.5%", lc[j]),
                        legendgroup=lc[j],
                        yaxis='y2',
                        showlegend=F)
        p2 <- add_trace(p2, x = df_ts()$year[df_ts()$land_cover==lc[j]],
                        y= df_ts()$m_L.rel_q025_BC[df_ts()$land_cover==lc[j]],
                        type='scatter', mode='lines',
                        line=list(color=cols[j], width=0),
                        fillcolor=colsfill[j],
                        fill = 'tonexty',
                        name=paste("2.5%", lc[j]),
                        legendgroup=lc[j],
                        yaxis='y2',
                        showlegend=F)
      }
    }

    p1 <- layout(p1, yaxis=list(title="% growth",
                                scaleanchor='y2', contraintoward='bottom'),
                 xaxis=list(domain=c(0, 1)))
    p2 <- layout(p2, yaxis=list(title="% loss", autorange='reversed',
                                scaleanchor='y', constraintoward='top'),
                 xaxis=list(domain=c(0, 1)))
    p <- subplot(p1, p2, nrows=2,
                 shareX=TRUE, titleX=TRUE,
                 shareY=FALSE, titleY=TRUE,
                 margin=0.02)
    p <- layout(p, xaxis = list(domain=c(0,1)))
                
  })
  
  output$scaling_factor <- renderUI({
    
    s1 <- paste("Number of MCMC iterations = ", mcmc_it())
    s2 <- paste("Model run started in year ", y_start() + 1967)
    
    HTML(paste(s1, s2, sep='<br/>'))
    #print(getwd())
    #names(df_table())
    })
  
  #### REACTIVE OBJECTS ####
  
  df_table <- reactive({
    if(!is.null(input$LUC_slider)){
    df_SA %>% filter(
      CV_prior == as.numeric(input$LUC_slider),
      CV_net == as.numeric(input$NET_slider),
      CV_gross == as.numeric(input$GROSS_slider),
      CV_B_cin == as.numeric(input$PRED_slider),
      llik_weighted == input$weighted_check)
    }else{
      df_SA
    }
  })

  mcmc_it <- reactive(df_table()$n_iter[1])
  
  y_start <- reactive(df_table()$backAsFarAs[1])

  df_ts <- reactive({
    d <- lapply(8:13, function(i){
      z <- melt(df_table()[1,i][[1]],
                varnames=c("year", "land_cover"))
      if (z$land_cover[1] %in% 1:6) z$land_cover <- lc[z$land_cover]
      #z$land_cover[z$land_cover=="bare"] <- "other"
      z$quant <- colnames(df_table()[i])
      z
    })
    dx <- d %>%
      do.call(rbind, .) %>%
      cast(., year + land_cover ~ quant)
  })
  
  slider_allow1 <- reactive({ "CS" %in% input$dataset_checkbox })
  slider_allow2 <- reactive({ "AC" %in% input$dataset_checkbox })
  slider_allow3 <- reactive({  "EAC" %in% input$dataset_checkbox })
  slider_allow4 <- 
    reactive({ all(c("Corine","IACS","NFEW") %in% input$dataset_checkbox) })
  
})