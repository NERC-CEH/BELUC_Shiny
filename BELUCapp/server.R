# Adam Griffin, 2018-12-14
# server script for Shiny app for Bayesian Estimation of Land Use Change
#
# Part of UKSCaPE Task 1.1 (Data Science Framework)
# app presents results of BELUC under different parameter choices and shows key
# summary statistics from the model outputs.

options(show.error.messages = F)
options(warn=-1)

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

  output$spatial_plot <- renderPlot({
    if(input$relative_areas == "AbsA") {
      yprint <- "Absolute growth and loss in hectares"
    }else{
      yprint <- "Year-on-year % growth and loss"
    }
    
    p <- ggplot(df_ts(), aes(year)) +
      ylab(yprint) +
      scale_x_continuous(breaks = seq(1968,2020,by=4))
    if(input$show_bounds_check){
      p <- p + geom_ribbon(aes(ymin=m_G.rel_q025_BC,
                               ymax=m_G.rel_q975_BC,
                               fill=land_cover),
                           alpha=0.5) +
        geom_ribbon(aes(ymin=-1*m_L.rel_q975_BC,
                        ymax=-1*m_L.rel_q025_BC,
                        fill=land_cover),
                    alpha=0.5) + 
        scale_fill_manual(values=pastel2set)
    }
    p <- p +
      geom_path(aes(y=m_G.rel_map_BC, col=land_cover), size=1) + 
      geom_path(aes(y=-1*m_L.rel_map_BC, col=land_cover), size=1) +
      scale_colour_manual(values=dark2set) +
      coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE) + 
      theme(legend.position="none")
    p
    
  })
  
  output$scaling_factor <- renderUI({
    
    s1 <- paste("Number of MCMC iterations = ", mcmc_it())
    s2 <- paste("Max", maxdf())
    s3 <- paste("Started in ", y_start()+1967)
    
    HTML(paste(s1, s2, s3, sep='<br/>'))
    #print(getwd())
    #names(df_table())
  })
  
  output$beta_visual <- renderPlot({
    corrplot(beta_fake, method='circle', type='full', 
             col=colorRampPalette(c("red", "white", "blue"))(200),
             is.corr=FALSE)
  })
  
  #### REACTIVE OBJECTS ####
  
  ranges <- reactiveValues(x = c(2004, 2015),
                           y = c(-45,45))  # default values for initial view.
  
  observeEvent(input$plot1_dblclick, {
    ##Drag and double-click to zoom. Double-click to reset.
    brush <- input$plot1_brush
    if (!is.null(brush)) {
      ranges$x <- c(brush$xmin, brush$xmax)
      ranges$y <- c(brush$ymin, brush$ymax)
      
    } else {
      ranges$y <- c(-maxdf(), maxdf())
      ranges$x <- c(y_start()+1967, 2015)
    }
  })
  
  observeEvent(input$relative_areas,
               {
                 ranges$y <- c(-maxdf(), maxdf())
                 ranges$x <- c(y_start()+1967, 2015)
               })
  
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
      if (input$relative_areas == "AbsA"){
        colsel <- 8:13 #absolute area columns
      }else{
        colsel <- 14:19  # relative percentage change columns
      }
      colnam <- sapply(14:19, function(j){colnames(df_table()[j])})
      print(colnam)
      d <- lapply(1:6, function(i){
        z <- melt(df_table()[1,colsel[i]][[1]],
                  varnames=c("year", "land_cover"))
        # swap factors for true values for lc and year. Original dat
        if (z$land_cover[1] %in% 1:6) z$land_cover <- lc[z$land_cover]
        if (1 %in% z$year) z$year <- z$year + y_start() + 1967
        z$quant <- colnam[i]
        z
      })
      #browser()
      dx <- d %>%
        do.call(rbind, .) %>%
        cast(., year + land_cover ~ quant) %>%
        filter(., land_cover %in% input$linechoices)
      dx
  })
  
  maxdf <- reactive({ max(df_ts()[3:8])})
  
  slider_allow1 <- reactive({ "CS" %in% input$dataset_checkbox })
  slider_allow2 <- reactive({ "AC" %in% input$dataset_checkbox })
  slider_allow3 <- reactive({  "EAC" %in% input$dataset_checkbox })
  slider_allow4 <- 
    reactive({ all(c("Corine","IACS","NFEW") %in% input$dataset_checkbox) })
  
})