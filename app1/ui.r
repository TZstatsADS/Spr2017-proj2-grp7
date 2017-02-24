


library(shiny)
library(leaflet)
library(ggmap)
library(ggplot2)
library(shinydashboard)

header <- dashboardHeader(
  title = "How New York fill while driving",
  titleWidth = 320
)

sidebar<-dashboardSidebar(
  width = 320,
  sidebarMenu(
    menuItem("RouteFinder", tabName = "routefinder", icon = icon("map-marker")),
    menuItem("StatAnalysis", tabName = "statanalysis", icon = icon("signal"))
  )
)

body<-dashboardBody(
  tags$head(tags$style(HTML('.main-header .logo {
                              font-family: "Avenir",Avenir, "Avenir", serif;
                              font-weight: bold;
                              font-size: 20px;
                              }
                              '))),
  
  tabItems(
    #First Tab Item
    tabItem(tabName = "routefinder",
            
            fluidRow(
              column(width=7
                     ,box(
                width = NULL, solidHeader = TRUE,
                leafletOutput("mymap", height = 680)
            )),
            
              column(width=5,
                
                     tabBox(
                       width = NULL,
                       title = NULL,
                       side = c("left"),
                       id="locationinfo", height =NULL,
                       tabPanel("Plan a Route",
                                textInput("start","Where do you want to start?",value = "Columbia university"),
                                textInput("end","What is your destination?", value = "Time square"),
                       actionButton("calpath","draw the route"),
                       actionButton("altpath","want alternative?")),
                       tabPanel("Nearby Stations",
                                textInput("userlocation","Your Location"),
                       actionButton("nearby","Go!"))
                       
                     )
                
                ),
            fluidRow(
              column(width = 5,offset = -2,box(
                  title = "More Options",

                  status="warning",

                  checkboxGroupInput("fueltype","Fuel Type",
                                     choices = c(
                                       ELEC =1,CNG =2 
                                     ),selected = 1
                                     ),

                  p(
                    class = "text-muted",
                    paste("Note: there is Options regarding Elec can be used to advance search "
                    ))),
            box( title = "Options regarding Elec",
                
                status="warning",
              
                selectInput("elecnetwork","Elec Network",
                                   choices = c(
                                     "All" = 1,
                                     "ChargePoint Network" = 2,"Tesla"=3
                                   ),
                                   selected = 1),
                
                selectInput("elecconnecter","Elec Connector Types",
                            choices = c(
                              "All" = 1,
                              "CHADEMO" = 2,
                              "CHADEMO J1772COMBO" = 3,
                              "J1772" = 4,
                              "J1772 CHADEMO" = 5,
                              "J1772 J1772COMBO"=6,
                              "J1772 NEMA520"=7,
                              "J1772COMBO"=8,
                              "NEMA515 J1772"=9,
                              "NEMA520"=10,
                              "NEMA520 J1772"=11,
                              "NEMA520 J1772 CHADEMO"=12,
                              "TESLA"=13,
                              "TESLA J1772"=14
                            ),
                            selected = 1)
            ))))),
  
    tabItem(tabName = "statanalysis",
            h2('This is the tab for statistical analysis'))
    ))


dashboardPage(header,
              sidebar,
              body)