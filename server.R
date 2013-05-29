require(shiny)
require(rCharts)
shinyServer(function(input, output, session){
  output$map <- renderText({
    source('code.R', local = TRUE)
    h = L1$html('map')
    Encoding(h) <- 'UTF-8'
    h
  })
})
