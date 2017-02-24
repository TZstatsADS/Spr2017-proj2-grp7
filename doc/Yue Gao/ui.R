shinyUI(
fluidPage(

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
  ),

  wellPanel(tableOutput("fuel"),
            
  wellPanel(tableOutput("team"))  
    
  )

)
)
)
