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
                tabPanel("Save/Spend", plotOutput("savespend")), 
                tabPanel("MPG", plotOutput("mpg")), 
                tabPanel("CO2", plotOutput("co2")),
                tabPanel("Fuel Cost", plotOutput("fuelcost"))
    )
  ),
  
  wellPanel(tableOutput("table"))
  )

)
)
)
