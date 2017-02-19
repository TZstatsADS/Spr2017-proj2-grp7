library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Using Geolocation"),
  
  tags$script('
      $(document).ready(function () {
              navigator.geolocation.getCurrentPosition(onSuccess, onError);
              
              function onError (err) {
              Shiny.onInputChange("geolocation", false);
              }
              
              function onSuccess (position) {
              setTimeout(function () {
              var coords = position.coords;
              console.log(coords.latitude + ", " + coords.longitude);
              Shiny.onInputChange("geolocation", true);
              Shiny.onInputChange("lat", coords.latitude);
              Shiny.onInputChange("long", coords.longitude);
              }, 1100)
              }
              });
              '),
  fluidRow(column(width = 2,
                  verbatimTextOutput("lat"),
                  verbatimTextOutput("long"),
                  verbatimTextOutput("geolocation"))
  )
  
    
    
  
))
