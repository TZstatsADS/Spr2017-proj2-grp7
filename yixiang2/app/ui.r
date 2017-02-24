


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
            
            titlePanel("Analysis of fuel types and costs"),
            br(),
            fluidRow(
              
              column(3,
                     #panel1
                     wellPanel(
                       
                       selectizeInput(
                         'type', 'Select the fuel type you want to compare:', 
                         choices = totaltype, multiple = TRUE,selected=totaltype)),
                     wellPanel(
                       
                       h4("Comparison of 2 specific vehicles:"),
                       #panel2
                       
                       h4("Vehicle 1:"),
                       
                       selectizeInput("make1", label = "Select the manufacturtor:",
                                      choices = makelist,selected="Audi"),
                       
                       uiOutput("model1"),
                       
                       h4("Vehicle 2:"),
                       
                       selectizeInput("make2", label = "Select the manufacturtor:",
                                      choices = makelist,selected = "Volvo"),
                       
                       uiOutput("model2")
                       
                     )
              ),
              
              column(9,
                     wellPanel(
                       tabsetPanel(type = "tabs", 
                                   tabPanel("Save/Spend", plotOutput("savespend"),
                                            br(),
                                            helpText("The Save/Spend here refers to by how much you save/spend over 5 years 
                                                     compared to an average new car. If your 5-year fuel cost is less than average,
                                                     which means you save money, the amount is positive; otherwise, you spend more than average,
                                                     the amount is negative. The calculation is based on 45% highway, 55% city driving, 15,000 annual miles and current fuel prices.")), 
                                   
                                   
                                   tabPanel("MPG", plotOutput("mpg"),
                                            br(),
                                            helpText("MPG means Mile per Gallon. For electric and CNG vehicles this number
                                                     is MPGe (gasoline equivalent miles per gallon). MPG deviates on the traffic condition,
                                                     thus we show a result of city MPG, highway MPG and combined MPG (45% highway, 55% city driving).")
                                            ), 
                                   
                                   
                                   tabPanel("CO2", plotOutput("co2"),
                                            
                                            helpText("CO2 means tailpipe CO2 in grams/mile.")        
                                   ),
                                   
                                   
                                   tabPanel("Fuel Cost", plotOutput("fuelcost"),
                                            
                                            helpText("Annual fuel cost is based on 15,000 miles, 55% city driving, 
                                                     and the price of fuel used by the vehicle.
                                                     Fuel prices are from the Energy Information Administration."))
                                            )
                                            ),
                     
                     wellPanel(tableOutput("table"),
                               helpText("For single fuel vehicles, there will be only one fuel. 
                                        For dual fuel vehicles, this will be a conventional fuel (fueltype1) and an alternative fuel (fueltype2)."))
                               )
              
                                            )
                       
)
    ))


dashboardPage(header,
              sidebar,
              body)