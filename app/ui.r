

#install uninstalled packages
packages.used=c("shiny", "leaflet", "ggmap",
                "ggplot2","shinydashboard","plotly","shinyBS")


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
library(shinydashboard)
library(plotly)
library(shinyBS)


header <- dashboardHeader(
  title = "The Alternative Fuels",
  titleWidth = 320
)

sidebar<-dashboardSidebar(
  width = 300,
  sidebarMenu(
 
    menuItem("Fuel Analysis", tabName = "statanalysis", icon = icon("bar-chart-o")),
    menuItem("Trend Analysis", tabName = "patternanalysis", icon = icon("signal")),
    menuItem("RouteFinder", tabName = "routefinder", icon = icon("map-marker")),
    menuItem("Appendix", tabName = "appendix",icon=icon("list-alt"))
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
            
            titlePanel("Fuel Analysis"),
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
                                      choices = makelist,selected="Honda"),
                       
                       uiOutput("model1"),
                       
                       h4("Vehicle 2:"),
                       
                       selectizeInput("make2", label = "Select the manufacturtor:",
                                      choices = makelist,selected = "BMW"),
                       
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
                       
), 

tabItem(tabName = "appendix",
        h2("Appendix"),
        tableOutput("fuel"),
        h2("About Us"),
        tableOutput("team")
  
),

tabItem(tabName = "patternanalysis",
        ### KAI CHEN is responsible for the tab "StateAnalysis"
        h2('Trend Analysis'),
        h4('Based on alternative fuel stations'),
        fluidRow(
          
          tabBox(
            title = "History",
            id = "tabset2",
            width = 9,
            height = 550,
            tabPanel("State Map",solidHeader = TRUE,
                     plotlyOutput("statecompare1")),
            tabPanel("State Ranking",solidHeader = TRUE,
                     textInput("rank_n","Top:",value = "20", width = "100px"),
                     plotlyOutput("statecompare2")),
            tabPanel("Overall Trend",solidHeader = TRUE,
                     plotlyOutput("trend1")),
            bsTooltip("tabset2", "A tip: Using \"Map Settings\" and \"Animation Center\" can help you a lot to find an interesting trend!",
                      "top")
            
          ),
          
          
          tabBox( 
            title = "Map Settings",
            # The id lets us use input$tabset1 on the server to find the current tab
            id = "tabset1", height = 250, width = 3,
            # tabPanel( 
            #   title = "Years", solidHeader = TRUE, 
            #   sliderInput("range_year", "Range Slider: Choose a range of years: ", 
            #               min=1970, max=2018, value = c(1970,2018), 1, 
            #               dragRange = T)),
            # 
            
            
            tabPanel("Fuels", 
                    solidHeader = T,
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
            id = "tabset1", height = "150px", width = 3,
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
            width = 9,
            height = 550,
            tabPanel("Scatters",solidHeader = TRUE,
                     plotlyOutput("vehicle_scatter1")),
            tabPanel("Animation",solidHeader = TRUE,
                     plotlyOutput("vehicle_animation"))
            
          )
          
        )
        
        
)
    ))


dashboardPage(header,
              sidebar,
              body)