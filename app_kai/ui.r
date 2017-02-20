#
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
  
    tabItem(tabName = "stateanalysis",
            ### KAI CHEN is responsible for the tab "StateAnalysis"
            h2('State Analysis'),
            fluidRow(

              tabBox(
                title = "Results on the quantity",
                id = "tabset2",
                width = "12",
                tabPanel("US Map",solidHeader = TRUE,
                         plotlyOutput("statecompare1")),
                tabPanel("Ranking",solidHeader = TRUE,
                         plotlyOutput("statecompare2"))
                                 
              ),
              
              
              tabBox( 
                title = "Settings",
                # The id lets us use input$tabset1 on the server to find the current tab
                id = "tabset1", height = "180px", width = 6,
                tabPanel( 
                         title = "Years", solidHeader = TRUE, 
                         sliderInput("range_year", "Range Slider: Choose a range of years: ", 
                                     min=1970, max=2018, value = c(1970,2018), 1, 
                                     dragRange = T)),
                
                
                
                tabPanel("Fuels", 
                         title = "Fuels", solidHeader = TRUE,
                         radioButtons("fuel_type1", "Choose a type of fuel to analyze", 
                                      choices = c("ALL","HY","BD","LPG","LNG","ELEC","E85","CNG"), 
                                      selected = "ALL", inline = TRUE, width = '75%')
                         
                         
                         
                ),
                tabPanel("Scale", 
                         title = "Scale", solidHeader = TRUE,
                         radioButtons("index_scale", "Choose a way of scaling", 
                                      choices = c("None","By Area","By Population"), 
                                      selected = "None", width = '75%')
                         
                )
              ),
              
              
              tabBox( 
                title = "Animation Slider",
                # The id lets us use input$tabset1 on the server to find the current tab
                id = "tabset1", height = "180px", width = 6,
                tabPanel("", 
                         title = "", solidHeader = TRUE, 
                         sliderInput("animationslider", "Let's start an animation: ", 
                                     min=1971, max=2018, value = c(1971), 1, 
                                     dragRange = T, animate = animationOptions(interval = 500, loop = F)))
                ),
              
              
              
              
              
              
            
              
              
              
              
              
              
              tabBox(
                title = "Research on trend",
                id = "tabset3",
                width = "12",
                tabPanel("Overall",solidHeader = TRUE,
                         plotlyOutput("trend1"))
              )
              
              
              
              
              
              
              
              
              
              
              
                     
              # box(
              #   width = 12,
              #   title = "Choose your interested years", solidHeader = TRUE,
              #   textInput("text", "Text input:"),
              #   plotlyOutput("trend1")
              #   # plotOutput("niubi2")
              #    )
            )
            
            
          )
    
    
    
    
    
    
    
     # 
     # 
     # tabItem(tabName = "trendanalysis",
     #         ### KAI CHEN is responsible for the tab "StateAnalysis"
     #         h2('Trend Analysis'),
     #         fluidRow(
     # 
     #           tabBox(
     #             title = "Result",
     #             id = "tabset6",
     #             width = "12",
     #            tabPanel("Fuels",solidHeader = TRUE,
     #                      plotlyOutput("trend1")),
     #            tabPanel("Vehicles by States",solidHeader = TRUE,
     #                     h2("233333"))
     #            # tabPanel("Fuels Precentage",solidHeader = TRUE,
     #            #          plotlyOutput("trend1")),
     #            # tabPanel("Vehicles",solidHeader = TRUE,
     #            #          plotlyOutput("trend1")),
     #            # tabPanel("Vehicles by States",solidHeader = TRUE,
     #            #          plotlyOutput("trend1"))
     # 
     #           )
     # 
     #         )
     # 
     # 
     # )

    
    
    
    
    
    # 
    # 
    # tabItem(tabName = "TrendAnalysis",
    #         ### KAI CHEN is responsible for the tab "StateAnalysis"
    #         h2('Trend Analysis'),
    #         fluidRow(
    #           tabBox(
    #             title = "Settings",
    #             # The id lets us use input$tabset1 on the server to find the current tab
    #             id = "tabset3", height = "200px",
    #             tabPanel("Years",
    #                      title = "Years", solidHeader = TRUE,
    #                      sliderInput("range_year", "Choose a range of years: ",
    #                                  min=1970, max=2018, value = c(1970,2018), 1,
    #                                  dragRange = T))
    # 
    # 
    #             ),
    # 
    #           tabBox(
    #             title = "Results",
    #             id = "tabset4",
    #             width = "12",
    #             tabPanel("Fuels",solidHeader = TRUE,
    #                      width = 12,
    #                      plotlyOutput("trend1")),
    #             tabPanel("Vehicles",solidHeader = TRUE,
    #                      plotlyOutput("trend1"))
    # 
    #             )
    #         )
    # #         
    #         
    # )
    
)
)


sidebar<-dashboardSidebar(
  sidebarMenu(
    menuItem("RouteFinder", tabName = "routefinder", icon = icon("map-marker")),
    menuItem("Trend Analysis", tabName = "trendanalysis", icon = icon("signal")),
    menuItem("State Analysis", tabName = "stateanalysis", icon = icon("signal"))
            
   #          menuSubItem("TrendAnalysis", tabName = "TrendAnalysis")
    
  )
)

dashboardPage(header,
              sidebar,
              body)
