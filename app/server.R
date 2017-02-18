#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
#

library(shiny)
library(leaflet)
library(ggmap)
library(ggplot2)
library(RCurl)
library(RJSONIO)
library(igraph)
library(geosphere)
library(data.table)

source("../lib/findpath.R")


#-------------------------------------------------------------------------------------------------------------
##start and end will be input from ui, here we just give an example by giving them value directly
start<-"Columbia University"
end<-"Time Square"
##start,end are location names
myroute<-Findpath(start,end,Nodes,Segments,stations)
myroute.df<-data.frame(myroute)

start.coord<-as.numeric(geocode(start)[2:1])
end.coord<-as.numeric(geocode(end)[2:1])

point<-data.frame(long=c(start.coord[1],end.coord[1]),lat=c(start.coord[2],end.coord[2]))

shinyServer(function(input, output) {
#-----------------------------------------------------------------------------------------------------------  
  output$mymap <- renderLeaflet({
      leaflet() %>%
     # setView(lng=-95.7, lat=37.1, zoom=4 )%>%
      addTiles( urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')  %>% 
      addMarkers(data=point) %>%
      addPolylines(lng=myroute.df$go.Longtitude,lat=myroute.df$go.Latitude)
  })
})
  
##we can use leafletproxy to modify existing maps.
  # observe({
  #   leafletProxy("mymap") %>% addMarkers(lng=as.numeric(input$points_starts[[1]]),lat=as.numeric(input$points_starts[[2]]))
  #   leafletProxy("mymap") %>% addMarkers(lng=as.numeric(input$points_end[[1]]),lat=as.numeric(input$points_end[[2]]))
  # })
  


