#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
#
# 

#install uninstalled packages
packages.used=c("shiny", "leaflet", "ggmap",
                "ggplot2", "RCurl","RJSONIO","igraph","geosphere"
                ,"data.table")


# check packages that need to be installed.
packages.needed=setdiff(packages.used,
                        intersect(installed.packages()[,1],
                                  packages.used))
# install additional packages
if(length(packages.needed)>0){
  install.packages(packages.needed, dependencies = TRUE,
                   repos='http://cran.us.r-project.org')
}

library(shiny)
library(leaflet)
library(ggmap)
library(ggplot2)
library(RCurl)
library(RJSONIO)
library(igraph)
library(geosphere)
library(data.table)
library(googleway)

source("../lib/findpath.R")
source("../lib/longroute.R")

station.icon<- icons(
  iconUrl =("../lib/stationpic.png"),
  iconWidth = 10, iconHeight = 10,
  iconAnchorX = 10, iconAnchorY = 10
)

# start.icon<-icons("https://thumbs.dreamstime.com/z/cute-vector-orange-toy-car-icon-isolated-sticker-50095461.jpg")
# end.icon<-icons("https://s-media-cache-ak0.pinimg.com/564x/d9/7f/ea/d97feac57bebf6007994f6a6286d005b.jpg")


start.icon<-icons(iconUrl = "../lib/startpic.png",
                     iconWidth = 35,iconHeight = 35,
                     iconAnchorX = 22, iconAnchorY = 25)
end.icon<-makeIcon(iconUrl = "../lib/endpic.png",
                     iconWidth = 35,iconHeight = 35)

shinyServer(function(input, output) { 
      
  aaa<-eventReactive(input$calpath,{input$start})
  bbb<-eventReactive(input$calpath,{input$end})
  ccc<-eventReactive(input$calpath,{input$fueltype})
  ddd<-eventReactive(input$calpath,{input$elecnetwork})
  eee<-eventReactive(input$calpath,{input$elecconnecter})
  
  AAA<-eventReactive(input$altpath,{input$start})
  BBB<-eventReactive(input$altpath,{input$end})
  CCC<-eventReactive(input$altpath,{input$fueltype})
  DDD<-eventReactive(input$altpath,{input$elecnetwork})
  EEE<-eventReactive(input$altpath,{input$elecconnecter})
  FFF<-eventReactive(input$nearby,{input$userlocation})
  

  output$mymap <- renderLeaflet({
    leaflet() %>%
      setView(lng=-95.7, lat=37.1, zoom=4 )%>%
      addTiles( urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')
  })
  
  observe({

    start.coord<-as.numeric(geocode( aaa() )[2:1])
    end.coord<-as.numeric(geocode( bbb() )[2:1])
    startpoint<-data.frame(long=start.coord[1],lat=start.coord[2])
    endpoint<-data.frame(long=end.coord[1],lat=end.coord[2])
    startGeo<-geocode(aaa())
    endGeo<-geocode(bbb())

    start.city<-as.character(strsplit(revgeocode(start.coord),", ")[[1]][2])
    end.city<-as.character(strsplit(revgeocode(end.coord),", ")[[1]][2])

    if (start.city=="New York" && end.city=="New York"){
      ##start,end are location names
      myroute<-Findpath(aaa(),bbb(),Nodes,Segments,stations,ccc(),ddd(),eee())
      myroute.df<-myroute[[1]]

        leafletProxy("mymap") %>%
          clearTiles() %>%
          clearShapes() %>%
          clearMarkers() %>%
          addTiles( urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                    attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')  %>%
          addMarkers(data=startpoint,icon=start.icon) %>%
          addMarkers(data=endpoint,icon=end.icon) %>%
          addPolylines(lng=myroute.df$Longtitude,lat=myroute.df$Latitude) %>%
          fitBounds(lng1=max(myroute.df$Longtitude),lat1=max(myroute.df$Latitude),
                    lng2 = min(myroute.df$Longtitude),lat2 = min(myroute.df$Latitude))

    }else if (start.city!="New York" || end.city!="New York"){
      #if at least one location is not in new york
      mylongroute<-get_myrouteandstations(start = aaa(),end = bbb())
      output$mymap <- renderLeaflet({
        leafletProxy("mymap") %>%
          clearShapes() %>%
          clearMarkers() %>%
          addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                   attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')  %>%
          addMarkers(data=startpoint,icon=start.icon) %>%
          addMarkers(data=endpoint,icon=end.icon) %>%
          addMarkers(data = mylongroute$stations, lat =  ~Latitude, lng = ~Longitude,icon =station.icon) %>%
          addPolylines(data = mylongroute$routnode,lat = ~lat, lng = ~lon)
      })
    }
  
  })

})

