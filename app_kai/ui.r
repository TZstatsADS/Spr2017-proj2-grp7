
  # This is the user-interface definition of a Shiny web application. You can
  # run the application by clicking 'Run App' above.
  #
  # Find out more about building applications with Shiny here:
  # 
  #    http://shiny.rstudio.com/
    
library(shiny)
library(leaflet)
library(ggmap)
library(ggplot2)
library(shinydashboard)
library(plotly)
library(shinyBS)

header <- dashboardHeader(
  title = "How New York fill while driving",
  titleWidth = 450
)
  


body<-dashboardBody(
  
  tabItems(
    #First Tab Item
    tabItem(tabName = "routefinder",
            fluidRow(
              
              box(width = NULL, solidHeader = TRUE,
                  leafletOutput("mymap", height = 500)
              )
            )
            
    ),
  
    
    tabItem(tabName = "kaichenanalysis",
            ### KAI CHEN is responsible for the tab "StateAnalysis"
            h2('Trend Analysis'),
            h4('A tip: \"Map Setting\" and \"Animation Center\" can help you a lot to find an interesting trend!'),
            
            fluidRow(
              
              tabBox(
                title = "Results on the quantity",
                id = "tabset2",
                width = "12",
                tabPanel("State Map",solidHeader = TRUE,
                         plotlyOutput("statecompare1")),
                tabPanel("State Ranking",solidHeader = TRUE,
                         textInput("rank_n","Top:",value = "20", width = "100px"),
                         plotlyOutput("statecompare2")),
                tabPanel("Overall Trend",solidHeader = TRUE,
                         plotlyOutput("trend1"))
                
              ),
               
              
              tabBox( 
                title = "Map Settings",
                # The id lets us use input$tabset1 on the server to find the current tab
                id = "tabset1", height = "180px", width = 6,
                # tabPanel( 
                #   title = "Years", solidHeader = TRUE, 
                #   sliderInput("range_year", "Range Slider: Choose a range of years: ", 
                #               min=1970, max=2018, value = c(1970,2018), 1, 
                #               dragRange = T)),
                # 
                
                
                tabPanel("Fuels Selections", 
                         title = "Fuels", solidHeader = T,
                         radioButtons("fuel_type1", "Choose a type of fuel to analyze", 
                                      choices = c("ALL","HY","BD","LPG","LNG","ELEC","E85","CNG"), 
                                      selected = "ALL", inline = TRUE, width = '100%'),
                         bsTooltip("fuel_type1", "HY: hydrogen<br>BD: biodiesel<br>LPG: liquefied petroleum gas<br>LNG: liquefied natural gas<br> ELEC: electricity<br>E85: 85% ethanol,15% gasoline <br>CNG: compressed natural gas",
                                   "bottom")
 
                ),
                
                tabPanel("Scale", 
                         radioButtons("index_scale", "Choose a way of scaling", 
                                      choices = c("None","By Areas(km^2)","By Areas(mi^2)"), 
                                      selected = "None", width = '100%'),
                         bsTooltip("index_scale", "*By Areas: <br>Show the number of stations per 10000 km^2 or mi^2",
                                   "bottom")
                       
                ),
                tabPanel("Colobar", 
                          radioButtons("index_aim", "Let colorbar:", 
                                      choices = c("be fixed",
                                                  "change with the year"
                                      ), selected = "be fixed", width = '100%'),
                         bsTooltip("index_aim", "*change with the year: <br>the range of colorbar will change with the year",
                                   "bottom")
                  )
              ),
              
              
              tabBox( 
                title = "Animation Center",
                # The id lets us use input$tabset1 on the server to find the current tab
                id = "tabset1", height = "180px", width = 6,
                tabPanel("", 
                         title = "", solidHeader = TRUE, 
                         sliderInput("animationslider", "Year control/Animation Play", 
                                     min=1971, max=2018, value = c(2018), 1, 
                                     dragRange = T, 
                                     animate = animationOptions(interval = c(150,300), 
                                                                loop = F,
                                                                playButton = "PLAY!"),
                                     width = "100%"),
                         
                         bsTooltip("animationslider", "Click the \"PLAY\" button to see the trend from 1971",
                                   "bottom")
                         
                         )
              ),
              

            
              tabBox(
        
                title = "Relation with Vehicles",
                id = "tabset5",
                width = "12",
                height = 550,
                tabPanel("Scatters",solidHeader = TRUE,
                         plotlyOutput("vehicle_scatter1")),
                tabPanel("Animation",solidHeader = TRUE,
                         plotlyOutput("vehicle_animation"))
             
              )
              
             )
            
            
    )
    
    
    
    
    
    
    

    
  )
)


sidebar<-dashboardSidebar(
  sidebarMenu(
    menuItem("RouteFinder", tabName = "routefinder", icon = icon("map-marker")),
    menuItem("Trend Analysis", tabName = "kaichenanalysis", icon = icon("signal"))
    
    #          menuSubItem("TrendAnalysis", tabName = "TrendAnalysis")
    
  )
)

dashboardPage(header,
              sidebar,
              body)
