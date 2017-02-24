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
  iconWidth = 35, iconHeight = 35,
  iconAnchorX = 10, iconAnchorY = 10
)

station.icon2<- icons(
  iconUrl =("../lib/stationpic.png"),
  iconWidth = 15, iconHeight = 15,
  iconAnchorX = 10, iconAnchorY = 10
)

# start.icon<-icons("https://thumbs.dreamstime.com/z/cute-vector-orange-toy-car-icon-isolated-sticker-50095461.jpg")
# end.icon<-icons("https://s-media-cache-ak0.pinimg.com/564x/d9/7f/ea/d97feac57bebf6007994f6a6286d005b.jpg")


start.icon<-icons(iconUrl = "../lib/startpic.png",
                     iconWidth = 35,iconHeight = 35,
                     iconAnchorX = 22, iconAnchorY = 25)
end.icon<-makeIcon(iconUrl = "../lib/endpic.png",
                     iconWidth = 35,iconHeight = 35)

shinyServer(function(input, output,session) { 
      
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
  
  
  output$model1=renderUI({
    c1=input$make1
    m1=as.vector(unique(vehdata$model[vehdata$manufacturer==c1]))
    rm1=as.vector(unique(vehdata$model[(vehdata$manufacturer==c1)
                                       &(vehdata$fueltype %in% c("Regular","Premium"))]))
    am1=setdiff(m1,rm1)
    selectInput('model1', 'Select model:', 
                choices=list("Alternative Fuel"=am1,
                             "Regular Fuel"=rm1
                ))
    
  })
  
  output$model2=renderUI({
    c2=input$make2
    m2=as.vector(unique(vehdata$model[vehdata$manufacturer==c2]))
    rm2=as.vector(unique(vehdata$model[(vehdata$manufacturer==c2)
                                       &(vehdata$fueltype %in% c("Regular","Premium"))]))
    am2=setdiff(m2,rm2)
    selectInput('model2', 'Select model:', 
                choices=list(
                  "Regular Fuel"=rm2,
                  "Alternative Fuel"=am2
                  
                ))
  })
  
  
  output$savespend=renderPlot({
    temp=fuel.avg[fuel.avg$fueltype %in% input$type,]
    temp=data.frame(temp)
    if(length(input$type>0)){
      c<-ggplot(data=temp,aes(x=fueltype,y=savespend,fill=fueltype))
      
      (c+coord_flip()+geom_bar(stat="identity")
        +theme(legend.position="none")
        +ggtitle("Save/Spend on Fuel Costs in 5 Years")+
          xlab("")+ ylab("Save/Spend in 5 years")
        +theme(plot.title = element_text(size=22,face="bold",vjust=1,hjust=-1),
               axis.title.x = element_text(size=14,vjust=1,hjust=0.5),
               axis.text.y =element_text(size=14,face="bold"),
               plot.margin = unit(c(1,0.5,0.5,0.5),"cm")
        )
      )
      
    }
    
  })
  
  output$mpg=renderPlot({
    temp=subset(fuel.avg,select=c(fueltype,combmpg,citympg,highwaympg))
    mpg=temp[temp$fueltype %in% input$type,]
    mpg=data.frame(fueltype1=rep(mpg$fueltype,3),
                   mpgtype=rep(c("Combined MPG","City MPG","Highway MPG"),each=nrow(mpg)),
                   dmpg=c(mpg$combmpg,mpg$citympg,mpg$highwaympg))
    
    
    if(length(input$type>0)){
      
      c<-ggplot(data=mpg,aes(x=fueltype1,y=dmpg,fill=mpgtype))
      (c+geom_bar(stat="identity")+coord_flip()
        +labs(title="MPG for Different Fuels",x="",
              y ="MPG")+scale_fill_hue("Types of MPG")
        +theme(plot.title = element_text(size=22,face="bold",vjust=1),
               axis.title.x = element_text(size=14,vjust=1,hjust=0.5),
               axis.text.y =element_text(size=14,face="bold"),
               plot.margin = unit(c(1,0.5,0.5,0.5),"cm")
        )
      )
      
    }
  })
  
  output$co2=renderPlot({
    temp=subset(fuel.avg,select = c(fueltype,co2))
    temp=temp[temp$fueltype %in% input$type,]
    temp=data.frame(temp)
    
    if(length(input$type>0)){
      
      c<-ggplot(data=temp,aes(x=fueltype,y=co2,fill=fueltype))
      (c+geom_bar(stat="identity")+coord_flip()
        +theme(legend.position="none")
        +labs(title="CO2 for Different Fuels",
              x= "", y ="CO2")
        +theme(plot.title = element_text(size=22,face="bold",vjust=1),
               axis.title.x = element_text(size=14,vjust=1,hjust=0.5),
               axis.text.y =element_text(size=14,face="bold"),
               plot.margin = unit(c(1,0.5,0.5,0.5),"cm")
        )
      )
      
    }
  })
  
  output$fuelcost=renderPlot({
    temp=subset(fuel.avg,select = c(fueltype,fuelcost))
    temp=temp[temp$fueltype %in% input$type,]
    temp=data.frame(temp)
    
    if(length(input$type>0)){
      c<-ggplot(data=temp,aes(x=fueltype,y=fuelcost,fill=fueltype))
      (c+geom_bar(stat="identity")+coord_flip()
        +theme(legend.position="none")
        +labs(title="Annual Fuel Cost for Different Fuels",
              x= "", y ="Fuel Cost")
        +theme(plot.title = element_text(size=22,face="bold",vjust=1),
               axis.title.x = element_text(size=14,vjust=1,hjust=0.5),
               axis.text.y =element_text(size=14,face="bold"),
               plot.margin = unit(c(1,0.5,0.5,0.5),"cm")
        )
      )
    }
  })
  
  output$table=renderTable({
    table1=vehdata[(vehdata$manufacturer==input$make1)
                   &(vehdata$model==input$model1),]
    table1=table1[order(-table1$year),]
    
    table2=vehdata[(vehdata$manufacturer==input$make2)
                   &(vehdata$model==input$model2),]
    table2=table2[order(-table2$year),]
    m=rbind.data.frame(table1[1,],table2[1,])
    row.names(m)=c("Vehicle1","Vehicle2")
    if((m$fueltype2[1]=="")&(m$fueltype2[2]=="")){
      m=subset(m,select=c(-fueltype1,-fueltype2,-citympg2,-combmpg2,-hw2,-co2.2,-fuelcost2))
      m=t(m)
      m=cbind(" "=c("Manufacturer","Model","Class","Fuel Type","Save or Spend",
                    "City MPG","Combined MPG","Highway MPG","CO2","Fuel Cost","Year"),m)
    }else{
      m=subset(m,select=c(-fueltype))
      m=t(m)
      m=cbind(" "=c("Manufacturer","Model","Class","Fuel Type 1","Fuel Type 2",
                    "Save or Spend","City MPG1","City MPG2",
                    "Combined MPG1","Combined MPG2",
                    "Highway MPG1","Highway MPG2",
                    "CO2 for Fuel1","CO2 for Fuel2",
                    "Fuel Cost1","Fuel Cost2",
                    "Year"),m)
    }
    
    
    m
    
  })
  
  
  
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
      stationpoint<-data.frame(long=Nodes$Longtitude[Nodes$ID==myroute[[3]]],lat=Nodes$Latitude[Nodes$ID==myroute[[3]]])

        leafletProxy("mymap") %>%
          clearTiles() %>%
          clearShapes() %>%
          clearMarkers() %>%
          addTiles( urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                    attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')  %>%
          addMarkers(data=startpoint,icon=start.icon) %>%
          addMarkers(data=stationpoint,icon=station.icon) %>%
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
          addMarkers(data = mylongroute$stations, lat =  ~Latitude, lng = ~Longitude,icon =station.icon2) %>%
          addPolylines(data = mylongroute$routnode,lat = ~lat, lng = ~lon)
      })
    }
  
  })
  
  observe({
    
    start.coord<-as.numeric(geocode( AAA() )[2:1])
    end.coord<-as.numeric(geocode( BBB() )[2:1])
    startpoint<-data.frame(long=start.coord[1],lat=start.coord[2])
    endpoint<-data.frame(long=end.coord[1],lat=end.coord[2])
    startGeo<-geocode(AAA())
    endGeo<-geocode(BBB())
    
    start.city<-as.character(strsplit(revgeocode(start.coord),", ")[[1]][2])
    end.city<-as.character(strsplit(revgeocode(end.coord),", ")[[1]][2])
    
    if (start.city=="New York" && end.city=="New York"){
      ##start,end are location names
      myroute<-Findpath(aaa(),bbb(),Nodes,Segments,stations,CCC(),DDD(),EEE())
      myroute.df<-myroute[[2]]
      stationpoint<-data.frame(long=Nodes$Longtitude[Nodes$ID==myroute[[4]]],lat=Nodes$Latitude[Nodes$ID==myroute[[4]]])
      
      leafletProxy("mymap") %>%
        clearTiles() %>%
        clearShapes() %>%
        clearMarkers() %>%
        addTiles( urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                  attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')  %>%
        addMarkers(data=startpoint,icon=start.icon) %>%
        addMarkers(data=stationpoint,icon=station.icon) %>%
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
          addMarkers(data = mylongroute$stations, lat =  ~Latitude, lng = ~Longitude,icon =station.icon2) %>%
          addPolylines(data = mylongroute$routnode,lat = ~lat, lng = ~lon)
      })
    }
    
  })

})

