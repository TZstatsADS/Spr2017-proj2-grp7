library(shiny)
library(plyr)

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
  
  output$table=renderTable({
    table1=vehdata[(vehdata$manufacturer==input$make1)
                   &(vehdata$model==input$model1),]
    table1=table1[order(-table1$year),]
    
    table2=vehdata[(vehdata$manufacturer==input$make2)
                   &(vehdata$model==input$model2),]
    table2=table2[order(-table2$year),]
    m=rbind.data.frame(table1[1,],table2[1,])
    row.names(m)=c("Vehicle1","Vehicle2")
    if((m$fueltype2[1]=="")&(m$fueltype2[2]=="")){
      m=subset(m,select=c(-fueltype1,-fueltype2,-citympg2,-combmpg2,-hw2,-co2.2,-fuelcost2))
      m=t(m)
      m=cbind(" "=c("Manufacturer","Model","Class","Fuel Type","Save or Spend",
                     "City MPG","Combined MPG","Highway MPG","CO2","Fuel Cost","Year"),m)
    }else{
      m=subset(m,select=c(-fueltype))
      m=t(m)
      m=cbind(" "=c("Manufacturer","Model","Class","Fuel Type 1","Fuel Type 2",
                     "Save or Spend","City MPG1","City MPG2",
                     "Combined MPG1","Combined MPG2",
                     "Highway MPG1","Highway MPG2",
                     "CO2 for Fuel1","CO2 for Fuel2",
                     "Fuel Cost1","Fuel Cost2",
                     "Year"),m)
      }


  print(m)
    
  })
  

})