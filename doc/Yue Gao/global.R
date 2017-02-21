library(plyr)

vehicles<-read.csv("vehicles.csv")

vehdata<-data.frame(
  manufacturer=vehicles$make,model=vehicles$model,class=vehicles$VClass,
  fueltype=vehicles$fuelType,fueltype1=vehicles$fuelType1,fueltype2=vehicles$fuelType2,savespend=vehicles$youSaveSpend,
  citympg1=vehicles$city08,citympg2=vehicles$cityA08,
  combmpg1=vehicles$comb08,combmpg2=vehicles$combA08,
  hw1=vehicles$highway08,hw2=vehicles$highwayA08,
  co2.1=vehicles$co2TailpipeGpm,co2.2=vehicles$co2TailpipeAGpm,
  fuelcost1=vehicles$fuelCost08,fuelcost2=vehicles$fuelCostA08,
  year=vehicles$year)


totaltype=unique(vehdata$fueltype)
makelist=unique(vehdata$manufacturer)
singlefuel=vehdata[vehdata$fueltype2=="",]
mixedfuel=vehdata[vehdata$fueltype2!="",]

singlefuel.avg=ddply(singlefuel,.(fueltype),summarize,savespend=mean(savespend),
   citympg=mean(citympg1),combmpg=mean(combmpg1),highwaympg=mean(hw1),
   co2=mean(co2.1),fuelcost=mean(fuelcost1))

mixedfuel.avg=ddply(mixedfuel,.(fueltype),summarize,savespend=mean(savespend),
  citympg=mean(c(citympg1,citympg2)),combmpg=mean(c(combmpg1,combmpg2)),
  highwaympg=mean(c(hw1,hw2)),co2=mean(c(co2.1,co2.2)),fuelcost=mean(c(fuelcost1,fuelcost2)))

fuel.avg=rbind(singlefuel.avg,mixedfuel.avg)




