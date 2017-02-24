


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
                                     choices = c("ELEC","CNG"),selected ="ELEC"),

                  p(
                    class = "text-muted",
                    paste("Note: there is Options regarding Elec can be used to advance search "
                    ))),
            box( title = "Options regarding Elec",
                
                status="warning",
              
                selectInput("elecnetwork","Elec Network",
                                   choices = c(
                                     "All","ChargePoint Network","Tesla"
                                   ),
                                   selected = "All"),
                
                selectInput("elecconnecter","Elec Connector Types",
                            choices = c(
                              "All",
                              "CHADEMO",
                              "CHADEMO J1772COMBO",
                              "J1772",
                              "J1772 CHADEMO",
                              "J1772 J1772COMBO",
                              "J1772 NEMA520",
                              "J1772COMBO",
                              "NEMA515 J1772",
                              "NEMA520",
                              "NEMA520 J1772",
                              "NEMA520 J1772 CHADEMO",
                              "TESLA",
                              "TESLA J1772"
                            ),
                            selected ="All")
            ))))),
  
    tabItem(tabName = "statanalysis",
            h2('This is the tab for statistical analysis'))
    ))


dashboardPage(header,
              sidebar,
              body)