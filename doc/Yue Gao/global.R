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

fuels=data.frame(FuelName=c("CNG (Compressed Natural Gas)",
                        "Biodiesel",
                        "Electricity",
                        "Ethanol",
                        "Propane",
                        "Hydrogen",
                        "Gasoline"),
    Sign=c('<img src="http://www.fueleconomy.gov/feg/images/cng_logo.gif"></img>',
            '<img src="http://www.fueleconomy.gov/feg/images/biodiesel_logo.gif"></img>',
            '<img src="http://www.fueleconomy.gov/feg/images/sign-ev-plugin-station.png" width = "99" ></img>',
            '<img src="http://www.fueleconomy.gov/feg/images/e85_logo.gif"></img>',
           ' <img src="http://www.fueleconomy.gov/feg/images/cng_logo.gif"></img>',
            '<img src="http://www.fueleconomy.gov/feg/images/hydrogen_logo.gif"></img>',
            '<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/HAZMAT_Class_3_Gasoline.png/220px-HAZMAT_Class_3_Gasoline.png" width="99" ></img>'),
    Description=c(
"      Natural gas is a fossil fuel that is plentiful in the U.S. It produces less air pollutants and GHGs than gasoline.
","      Biodiesel is diesel derived from vegetable oils and animal fats. It usually produces less air pollutants than petroleum-based diesel.
","      Electricity is produced domestically from a variety of sources such as coal, natural gas, nuclear power, and renewables. Powering vehicles with electricity causes no tailpipe emissions, but generating electricity can produce pollutants and greenhouse gases.
","      Ethanol¾is produced domestically from corn and other crops. It produces less greenhouse gas emissions than gasoline or diesel. E85, also called flex fuel, is an ethanol-gasoline blend containing 51% to 83% ethanol.
","      Propane, also called liquefied petroleum gas (LPG), is a domestically abundant fossil fuel. It produces less harmful air pollutants and GHGs than gasoline.
","      Hydrogen can be produced domestically from fossil fuels (such as coal), nuclear power, or renewable resources, such as hydropower. Fuel cell vehicles powered by pure hydrogen emit no harmful air pollutants.
","      Most gas stations offer three octane levels: regular (about 87), mid-grade (about 89) and premium (91 to 93). Generally, gasoline octane ratings are a measure of how well the fuel mixture can resist pre-ignition or knocking. That is to say, higher rating gasoline (like Premium Gas) can keep engines cleaner due to its detergent additives and produce less pollution.
"    ))



