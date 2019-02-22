# library(plotly)
# library(shiny)

ui <- fluidPage(
  plotlyOutput("plot"),
  verbatimTextOutput("click1")
)

server <- function(input, output, session) {
  
  output$plot <- renderPlotly({
    p1 <- plot_ly(mtcars, x = ~mpg, y = ~wt, type='scatter',
                  marker=list(color="blue"))
    p1 <- add_trace(p1, x = ~mpg, y = ~I(-wt), marker=list(color="orange"))

    #browser()
  })
  
  output$click1 <- renderPrint({
    d <- event_data("plotly_relayout", source='A')
    if (is.null(d)) "Click events appear here" else d
  })
  
}

shinyApp(ui, server)
