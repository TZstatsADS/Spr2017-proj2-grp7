library(shiny)
library(DT)
shinyServer(
  function(input, output,session) {

    
    output$model1=renderUI({
      c1=input$make1
      m1=as.vector(unique(vehdata$model[vehdata$manufacturer==c1]))
      selectInput('model1', 'Select model:', m1)
      
    })
    
    output$model2=renderUI({
      c2=input$make2
      m2=as.vector(unique(vehdata$model[vehdata$manufacturer==c2]))
      selectInput('model2', 'Select model:', m2)
    })
    
    
    output$savespend=renderPlot({
      temp=fuel.avg[fuel.avg$fueltype %in% input$type,]
      temp2=temp$savespend
      if(length(input$type>0)){
      barplot(temp2,
              main="Save/Spend on fuel costs in five years",
              horiz=TRUE,names.arg=temp$fueltype,las=1,beside=TRUE)
    }
    })
     
  output$mpg=renderPlot({
    temp=subset(fuel.avg,select=c(fueltype,combmpg,citympg,highwaympg))
    mpg=temp[temp$fueltype %in% input$type,]
    mpg.m=subset(mpg,select=-fueltype)
    mpg.m=t(mpg.m)
    if(length(input$type>0)){
    barplot(mpg.m,main="MPG for different fuels",xlab="fuels",
            col=c("darkblue","red","yellow"),beside=TRUE,names.arg=mpg$fueltype,
            legend=c("combined MPG","city MPG","highway MPG"))
    }
})

  output$co2=renderPlot({
      temp=subset(fuel.avg,select = c(fueltype,co2))
      temp=temp[temp$fueltype %in% input$type,]
      if(length(input$type>0)){
      barplot(temp$co2,names.arg=temp$fueltype)}
  })
  
  output$fuelcost=renderPlot({
    temp=subset(fuel.avg,select = c(fueltype,fuelcost))
    temp=temp[temp$fueltype %in% input$type,]
    if(length(input$type>0)){
    barplot(temp$fuelcost,names.arg=temp$fueltype)}
  })
  
  output$table1=DT::renderDataTable(DT::datatable({
    table1=vehdata[(vehdata$manufacturer==input$make1)
                   &(vehdata$model==input$model1 )
                   &(vehdata$year>=input$year1[1])
                   &(vehdata$year<=input$year1[2])
                   ,]
    table1

  })
  )
  
  output$table2=DT::renderDataTable(DT::datatable({
    table2=vehdata[(vehdata$manufacturer==input$make2)
                   &(vehdata$model==input$model2)
                   &(vehdata$year>=input$year2[1])
                   &(vehdata$year<=input$year2[2])
                   ,]
    table2
  })
  )
})