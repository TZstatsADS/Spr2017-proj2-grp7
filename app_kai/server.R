
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

## Kai's edit
library(dplyr)
library(reshape2) 
library(UScensus2010)
library(choroplethr)

#if(!require("devtools")) install.packages("devtools")
#devtools::install_github("ropensci/plotly",force=TRUE)

library(plotly)
library(tibble)
## Kai's edit 

source("../lib/findpath.R")
source("../lib/Kai_code.R")

#-------------------------------------------------------------------------------------------------------------
##start and end will be input from ui, here we just give an example by giving them value directly
start<-"Columbia University"
end<-"Time square"
##start,end are location names
myroute<-Findpath(start,end,Nodes,Segments,stations,"CNG","All","All")
myroute.df<-myroute[[1]]

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
      addPolylines(lng=myroute.df$Longtitude,lat=myroute.df$Latitude)
  })
  
  
  
  #-------- KAI's code ---------#
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
    df_fuel_state_int$state2 <- states_full
    
    df_color <- data.frame(apply(table_grow_afs, c(3,1), sum))
    if (input$index_scale == "By Areas"){
      df_fuel_state_int[,1:8] <- 10^4 * df_fuel_state_int[,1:8] / df_state_area$Areas_sq_km
      df_color <- 10^4 * data.frame(apply(table_grow_afs, c(3,1), sum)) / df_state_area$Areas_sq_km
      
      ## Delete DC, or the result might be misleading
      df_fuel_state_int <- df_fuel_state_int[-8,]
      df_color <- df_color[-8,]
      expl <- "; Per 10000 km^2"
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
    

    
    
    if (input$index_scale == "By Population"){
      df_fuel_state_int$tempt <- df_fuel_state_int$tempt / df_pop_state$value
      color_max <- max(df_fuel_state_int$tempt)
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
         EXPL = expl)
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
      plot_ly(x = ~ factor(state, levels = state)[1:10],
              y = ~tempt[1:10], type = 'bar', text =~factor(state, levels = state)[1:10],
              marker = list(color = 'rgb(58, 107, 107)',
                            line = list(color = 'rgb(58,48,107)', width = 1.5))) %>%
      layout(title = paste('Fuel Stations Distribution<br>Fuel = ', 
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
        title = "the Number of Fuel Stations",
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
  
  
  
  ### KAI -1 
  
})

##we can use leafletproxy to modify existing maps.
# observe({
#   leafletProxy("mymap") %>% addMarkers(lng=as.numeric(input$points_starts[[1]]),lat=as.numeric(input$points_starts[[2]]))
#   leafletProxy("mymap") %>% addMarkers(lng=as.numeric(input$points_end[[1]]),lat=as.numeric(input$points_end[[2]]))
# })



### Kai ----------------



### Kai __________ 







