library(shiny)
library(plyr)
library(ggplot2)


shinyServer(
  function(input, output,session) {

    
    output$model1=renderUI({
      c1=input$make1
      m1=as.vector(unique(vehdata$model[vehdata$manufacturer==c1]))
      rm1=as.vector(unique(vehdata$model[(vehdata$manufacturer==c1)
                  &(vehdata$fueltype %in% c("Regular","Premium"))]))
      am1=setdiff(m1,rm1)
      selectInput('model1', 'Select model:', 
                  choices=list("Alternative Fuel"=am1,
                               "Regular Fuel"=rm1
                               ))
      
    })
    
    output$model2=renderUI({
      c2=input$make2
      m2=as.vector(unique(vehdata$model[vehdata$manufacturer==c2]))
      rm2=as.vector(unique(vehdata$model[(vehdata$manufacturer==c2)
                  &(vehdata$fueltype %in% c("Regular","Premium"))]))
      am2=setdiff(m2,rm2)
      selectInput('model2', 'Select model:', 
                  choices=list(
                    "Regular Fuel"=rm2,
                    "Alternative Fuel"=am2
                               
                  ))
    })
    
    
    output$savespend=renderPlot({
      temp=fuel.avg[fuel.avg$fueltype %in% input$type,]
      temp=data.frame(temp)
      if(length(input$type>0)){
        c<-ggplot(data=temp,aes(x=fueltype,y=savespend,fill=fueltype))

        (c+coord_flip()+geom_bar(stat="identity")
          +theme(legend.position="none")
          +ggtitle("Save/Spend on Fuel Costs in 5 Years")+
                xlab("")+ ylab("Save/Spend in 5 years")
          +theme(plot.title = element_text(size=22,face="bold",vjust=1,hjust=-1),
                 axis.title.x = element_text(size=14,vjust=1,hjust=0.5),
                 axis.text.y =element_text(size=14,face="bold"),
                 plot.margin = unit(c(1,0.5,0.5,0.5),"cm")
                 )
          )

          }
      
    })
     
  output$mpg=renderPlot({
    temp=subset(fuel.avg,select=c(fueltype,combmpg,citympg,highwaympg))
    mpg=temp[temp$fueltype %in% input$type,]
    mpg=data.frame(fueltype1=rep(mpg$fueltype,3),
        mpgtype=rep(c("Combined MPG","City MPG","Highway MPG"),each=nrow(mpg)),
        dmpg=c(mpg$combmpg,mpg$citympg,mpg$highwaympg))
    

    if(length(input$type>0)){
      
      c<-ggplot(data=mpg,aes(x=fueltype1,y=dmpg,fill=mpgtype))
      (c+geom_bar(stat="identity")+coord_flip()
        +labs(title="MPG for Different Fuels",x="",
         y ="MPG")+scale_fill_hue("Types of MPG")
        +theme(plot.title = element_text(size=22,face="bold",vjust=1),
               axis.title.x = element_text(size=14,vjust=1,hjust=0.5),
               axis.text.y =element_text(size=14,face="bold"),
               plot.margin = unit(c(1,0.5,0.5,0.5),"cm")
        )
      )
      
    }
})

  output$co2=renderPlot({
      temp=subset(fuel.avg,select = c(fueltype,co2))
      temp=temp[temp$fueltype %in% input$type,]
      temp=data.frame(temp)
      
      if(length(input$type>0)){
      
        c<-ggplot(data=temp,aes(x=fueltype,y=co2,fill=fueltype))
        (c+geom_bar(stat="identity")+coord_flip()
          +theme(legend.position="none")
          +labs(title="CO2 for Different Fuels",
                x= "", y ="CO2")
          +theme(plot.title = element_text(size=22,face="bold",vjust=1),
                 axis.title.x = element_text(size=14,vjust=1,hjust=0.5),
                 axis.text.y =element_text(size=14,face="bold"),
                 plot.margin = unit(c(1,0.5,0.5,0.5),"cm")
          )
        )
        
        }
  })
  
  output$fuelcost=renderPlot({
    temp=subset(fuel.avg,select = c(fueltype,fuelcost))
    temp=temp[temp$fueltype %in% input$type,]
    temp=data.frame(temp)
    
    if(length(input$type>0)){
      c<-ggplot(data=temp,aes(x=fueltype,y=fuelcost,fill=fueltype))
      (c+geom_bar(stat="identity")+coord_flip()
        +theme(legend.position="none")
        +labs(title="Annual Fuel Cost for Different Fuels",
              x= "", y ="Fuel Cost")
        +theme(plot.title = element_text(size=22,face="bold",vjust=1),
               axis.title.x = element_text(size=14,vjust=1,hjust=0.5),
               axis.text.y =element_text(size=14,face="bold"),
               plot.margin = unit(c(1,0.5,0.5,0.5),"cm")
        )
      )
      }
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


  m
    
  })
  

})