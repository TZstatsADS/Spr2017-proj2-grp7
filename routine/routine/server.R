library(shiny)




shinyServer(function(input, output) {
   
  output$lat <- renderPrint({
    
    input$lat
    
    
  })
  output$long <- renderPrint({
    
    input$long
    
  })
  output$geolocation<-renderPrint({
    input$geolocation
  })
  
})
