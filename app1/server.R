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

##start,end are location names
#-----------------------------------------------------------------------------------------------------------


#m <- leaflet() %>% setView(lng=-95.7, lat=37.1, zoom=4)    
#m %>% addTiles()
shinyServer(function(input, output) { 
      
  output$mymap <- renderLeaflet({
    aaa<-eventReactive(input$calpath,{input$start})
    bbb<-eventReactive(input$calpath,{input$end})
    ccc<-eventReactive(input$calpath,{input$fueltype})
    ddd<-eventReactive(input$calpath,{input$elecnetwork})
    eee<-eventReactive(input$calpath,{input$elecconnecter})
    fff<-eventReactive(input$nearby,{input$userlocation})
    
    myroute<-Findpath( aaa(), bbb() ,Nodes,Segments,stations
                )
    myroute.df<-myroute[[1]]
    start.coord<-as.numeric(geocode( aaa() )[2:1])
    end.coord<-as.numeric(geocode( bbb() )[2:1])
    
    point<-data.frame(long=c(start.coord[1],end.coord[1]),lat=c(start.coord[2],end.coord[2]))  
       
#    alternative.df <-myroute[[2]]

#    find.station<-Nearest.station(fff())
#    userlocation.coord<-as.numeric(geocode(fff()[2:1]))
#    point2<-data.frame(long=userlocation.coord[1],lat=uerlocation.coord[2])
   leaflet() %>%
       
        addTiles( urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')  %>% 
        addMarkers(data=point) %>%
        addPolylines(lng=myroute.df$go.Longtitude,lat=myroute.df$go.Latitude) 
        
 
#   leaflet() %>%
    
#    addTiles( urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
#              attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')  %>% 
#    addMarkers(data=point) %>%
#    addPolylines(lng=alternative.df$go.Longtitude,lat=alternative.df$go.Latitude) 
   
   
#   leaflet() %>%
#     
#     addTiles( urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
#               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')  %>% 
#     addMarkers(data=point2)
  })
}) 
 #       setView(lng=-95.7, lat=37.1, zoom=4 )%>%

##we can use leafletproxy to modify existing maps.
  # observe({
  #   leafletProxy("mymap") %>% addMarkers(lng=as.numeric(input$points_starts[[1]]),lat=as.numeric(input$points_starts[[2]]))
  #   leafletProxy("mymap") %>% addMarkers(lng=as.numeric(input$points_end[[1]]),lat=as.numeric(input$points_end[[2]]))
  # })
  


