
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
  
    
    tabItem(tabName = "kaichenanalysis",
            ### KAI CHEN is responsible for the tab "StateAnalysis"
            h2('Trend Analysis'),
            fluidRow(
              
              tabBox(
                title = "Results on the quantity",
                id = "tabset2",
                width = "12",
                tabPanel("State Map",solidHeader = TRUE,
                         plotlyOutput("statecompare1")),
                tabPanel("State Ranking",solidHeader = TRUE,
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
                                      selected = "ALL", inline = TRUE, width = '75%')
                         
                         
                         
                ),
                
                tabPanel("Scale", 
                         radioButtons("index_scale", "Choose a way of scaling", 
                                      choices = c("None","By Areas","By number of vehicles"), 
                                      selected = "None", width = '75%')
                       
                ),
                tabPanel("Colobar", 
                          radioButtons("index_aim", "Let colorbar:", 
                                      choices = c("be fixed",
                                                  "change with the year"
                                      ), 
                                      selected = "be fixed", width = '75%')
                         
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
                                     animate = animationOptions(interval = c(300,800), 
                                                                loop = F,
                                                                playButton = "Click here to play!")))
              ),
              
              
              
              # tabBox(
              #   title = "Research on trend",
              #   id = "tabset3",
              #   width = "12",
              #   tabPanel("Overall",solidHeader = TRUE,
              #            plotlyOutput("trend1"))
              # ),
            
              tabBox(
        
                title = "Relation with Vehicles",
                id = "tabset5",
                width = "12",
                tabPanel("Scatters",solidHeader = TRUE,
                         h5("Choose a kind of energy in the legend:"),
                         plotlyOutput("vehicle_scatter1")),
                tabPanel("Animation",solidHeader = TRUE,
                         plotlyOutput("vehicle_animation")),
                tabPanel("这是什么玩意",solidHeader = TRUE,
                         plotlyOutput("vehicle_scatter"))
             
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
    menuItem("Trend Analysis", tabName = "kaichenanalysis", icon = icon("signal"))
    
    #          menuSubItem("TrendAnalysis", tabName = "TrendAnalysis")
    
  )
)

dashboardPage(header,
              sidebar,
              body)
