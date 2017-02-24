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
library(dplyr)
library(reshape2) 
library(UScensus2010)
library(choroplethr)

#if(!require("devtools")) install.packages("devtools")
#devtools::install_github("ropensci/plotly",force=TRUE)

library(plotly)
library(tibble)

source("../lib/findpath.R")
source("../lib/longroute.R")
source("../lib/Kai_code.R")

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
  
  
  ##################Yue's code############################
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
  
  output$fuel=renderTable({
    fuels
  }, sanitize.text.function = function(x) x)
  
 #########################Yue's code############################# 
  
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
  
  observe({
    
    mylocationcoord<-as.numeric(geocode(FFF())[2:1])
    mylocation<-data.frame(long=mylocationcoord[1],lat=mylocationcoord[2])
    nearbystations<-Nearest.station(FFF())
    output$mymap<-renderLeaflet({
      leafletProxy("mymap") %>%
        clearShapes() %>%
        clearMarkers() %>%
        addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                 attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')  %>%
        addMarkers(data=mylocation,icon=start.icon) %>%
        addMarkers(data=nearbystations,lat = ~lat,lng = ~lng,icon=station.icon)
    })
  })
  
  int_data <- reactive({
    
    ### Find selected Years_ ###
    
    range_year_v <- c(1970,input$animationslider)
    selected_years <- (years_total>= range_year_v[1]) & (years_total <= range_year_v[2])
    selected_years_v <- years_total[selected_years]
    
    
    ### Overall Trend ###
    
    #### Create a dataframe: row - year,  column - fuel.type and year
    table_fuel_year_int <- table_fuel_year[selected_years,]
    df_fuel_year_int <- data.frame(table_fuel_year_int) 
    df_fuel_year_int$Year <- factor(rownames(df_fuel_year_int))
    
    
    ### State Trend ###
    
    
    #### Scale by areas if required
    
    
    expl <- ""
    
    table_fuel_state_int <- apply(table_grow_afs[, selected_years, ], c(3,1), sum)
    df_fuel_state_int <- data.frame(table_fuel_state_int)
    df_fuel_state_int$SUM <- rowSums(df_fuel_state_int)
    df_fuel_state_int$state <- rownames(df_fuel_state_int)
    df_fuel_state_int$state2 <- states_total
    
    df_color <- data.frame(apply(table_grow_afs, c(3,1), sum))
    if (input$index_scale == "By Areas(km^2)"|input$index_scale == "By Areas(mi^2)"){
      df_fuel_state_int[,1:8] <- 10^4 * df_fuel_state_int[,1:8] / df_state_area$Areas_sq_km
      df_color <- 10^4 * data.frame(apply(table_grow_afs, c(3,1), sum)) / df_state_area$Areas_sq_km
      expl <- "; Per 10000 km^2"
      if (input$index_scale == "By Areas(mi^2)"){
        df_fuel_state_int[,1:8] <- df_fuel_state_int[,1:8] * 2.58999
        df_color <- df_color * 2.58999
        expl <- "; Per 10000 mi^2"
      }
      ## Delete DC, or the result might be misleading
      df_fuel_state_int <- df_fuel_state_int[-8,]
      df_color <- df_color[-8,]
      
    }
    
    
    df_color$SUM <- rowSums(df_color)
    
    
    ### Choose a column to compare 
    if (input$fuel_type1 == "ALL"){
      df_fuel_state_int$tempt <- df_fuel_state_int[,8]
      color_max <- max(df_color[,8])
      colorset <- "YlOrRd"
    }  
    
    else{
      selected_set <- which(input$fuel_type1 == colnames(df_fuel_state_int))
      df_fuel_state_int$tempt <- df_fuel_state_int[,selected_set]
      df_fuel_state_int <- df_fuel_state_int[order(df_fuel_state_int$state2),]
      color_max <- max(df_color[,selected_set])
      colorset <- kaicolorset[selected_set]
      #      colorset <- "Oranges"
    }
    
    
    
    
    
    if (input$index_aim == "change with the year"){
      color_max <- max(df_fuel_state_int$tempt)
      map_aim <- "Mode = Same Year, " 
    }
    else
      map_aim <- "Mode = Accumulation, "
    
    
    
    # if (input$index_scale == "By number of vehicles"){
    #   df_fuel_state_int$tempt <- df_fuel_state_int$tempt / df_pop_state$value
    #   color_max <- max(df_fuel_state_int$tempt)
    # }
    
    
    if (input$rank_n %in% as.character(1:51)){
      new_rank_n <- as.numeric(input$rank_n)
    }
    else{
      new_rank_n <- 50
    }
    
    
    
    
    
    
    
    
    state_rank <- order(df_fuel_state_int$tempt, decreasing = T)
    
    list(YEAR = selected_years_v, 
         DATA_trend1 = df_fuel_year_int, 
         DATA_statecompare = df_fuel_state_int,
         DATA_ranking = df_fuel_state_int[state_rank,],
         COLORMAX1 = color_max,
         COLORMAX2 = colorset,
         Name_fuel = input$fuel_type1,
         MAP_SET = map_aim,
         EXPL = expl,
         RANK_N = new_rank_n)
  })
  
  
  output$statecompare1 <- renderPlotly({
    int_data()$DATA_statecompare %>%
      plot_geo(locationmode = 'USA-states',
               hoverinfo = "location+text") %>%
      ### ALL
      add_trace(
        z = ~tempt, text = ~paste(state2,':<br>',tempt), locations = ~state,
        color = ~tempt, colors = int_data()$COLORMAX2, visible = T, 
        showscale = T
      ) %>%
      colorbar(title = "# Stations",
               len = 1,
               limits = c(0.001,int_data()$COLORMAX1)) %>%
      layout(
        title = paste('Fuel Stations Distribution<br> Fuel = ', 
                      int_data()$Name_fuel,int_data()$EXPL),
        geo = g)
  })
  
  output$statecompare2 <- renderPlotly({
    
    int_data()$DATA_ranking %>%
      plot_ly(x = ~ factor(state, levels = state)[1:int_data()$RANK_N],
              y = ~tempt[1:int_data()$RANK_N], type = 'bar', text =~factor(state2, levels = state2)[1:int_data()$RANK_N],
              marker = list(color = ~tempt, colors = int_data()$COLORMAX2,
                            line = list(color = ~tempt, width = 1.5))) %>%
      layout(title = paste('State Ranking<br>By type of Fuel = ', 
                           int_data()$Name_fuel,int_data()$EXPL),
             xaxis = list(title = ""),
             yaxis = list(title = "")
      )
    
  })
  
  
  
  output$trend1 <- renderPlotly({
    
    
    int_data()$DATA_trend1 %>%
      plot_ly(x = ~Year, y = ~BD, type = 'bar', name = 'BD', visible = T) %>%
      add_trace(y = ~CNG, name = 'CNG', visible = T) %>%
      add_trace(y = ~E85, name = 'E85', visible = T) %>%
      add_trace(y = ~ELEC, name = 'ELEC', visible = T) %>%
      add_trace(y = ~HY, name = 'HY', visible = T) %>%
      add_trace(y = ~LNG, name = 'LNG', visible = T) %>%
      add_trace(y = ~LPG, name = 'LPG', visible = T) %>%
      
      layout(
        title = "Trend of Fuel Stations in USA",
        xaxis = list(title = ''),
        yaxis = list(title = '# Alternative Fuel Stations'), 
        barmode = 'stack'
        
      )
    
  })
  
  output$vehicle_animation <- renderPlotly({
    p34
  })
  
  output$vehicle_scatter <- renderPlotly({
    p35
  })
  output$vehicle_scatter1 <- renderPlotly({
    p36
  })

})

