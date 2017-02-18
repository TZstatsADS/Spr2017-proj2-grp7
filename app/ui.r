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
  
    tabItem(tabName = "statanalysis",
            h2('This is the tab for statistical analysis'))
    
  ))


sidebar<-dashboardSidebar(
  sidebarMenu(
    menuItem("RouteFinder", tabName = "routefinder", icon = icon("map-marker")),
    menuItem("StatAnalysis", tabName = "statanalysis", icon = icon("signal"))
  )
)



dashboardPage(header,
              sidebar,
              body)