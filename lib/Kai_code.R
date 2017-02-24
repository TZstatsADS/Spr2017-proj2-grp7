
path_alt_fuel_station <- "../data/alt_fuel_stations (Feb 12 2017).csv"
alt_fuel_station <- read.csv(path_alt_fuel_station, 
                             stringsAsFactors = F,
                             header = T)
nrow(alt_fuel_station)

grow_afs <- 
  tbl_df(alt_fuel_station)  %>%
  select(Fuel.Type.Code, Expected.Date, Open.Date, State) %>%
  filter((nchar(Expected.Date)!=0)|(nchar(Open.Date)!=0))  %>% 
  mutate(Start.Date = as.Date(ifelse(nchar(Expected.Date)!=0,
                                     Expected.Date, 
                                     Open.Date))) %>%
  mutate(Start.Year = format(Start.Date, '%Y')) %>%
  mutate(Start.Month = format(Start.Date, '%m')) %>%
  select(Fuel.Type.Code, Start.Year, State)

table_grow_afs <- table(grow_afs)
## generate a table, with (x=year, y=fuel)
table_fuel_year <- apply(table_grow_afs, c(2,1), sum)
years_total <- as.numeric(rownames(table_fuel_year))
states_full <- dimnames(table_grow_afs)$State
states_total <- dimnames(table_grow_afs)$State
#table_fuel_state <- apply(table_grow_afs, c(3,1), sum) 


### A dataset which can help to transform our states' names
df_name_state <- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/2011_us_ag_exports.csv",
                          stringsAsFactors = F)
ABBR = df_name_state$code
FULL = df_name_state$state


for (i in 1:50){
  states_full <- replace(states_full,  states_full== ABBR[i], FULL[i])
}




# sort(FULL)
# grow_afs <- grow_afs[grow_afs$State!="DC",]
# 
# 
# grow_state_condition <- data.frame(state = sort(unique(grow_afs$State)), 
#                                    stringsAsFactors = F)
# grow_state_condition$state2 <- grow_state_condition$state


# specify some map projection/options
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa')
)


data(df_pop_state)
df_pop_state$region[9] <- "DC"
df_pop_state <- df_pop_state[order(df_pop_state$region),]
rownames(df_pop_state) <- 1:51

###
kaicolorset <- c("Reds","YlOrBr","YlGn","PuBu", "PuRd", "Purples", "Oranges")
#kaicolorset_trend <- c("Red","Yellow","Green","Blue","","")
# 
 folder_path_kai <- "../data/vehicle_station/"
 temp <- list.files(path = folder_path_kai, pattern = "*.csv")
 temp <- paste(folder_path_kai, temp, sep = "")
 vehicle_list <- lapply(temp, read.csv, header = T, stringsAsFactors = F)
 vehicle_length <- sapply(vehicle_list, nrow)
 vehicle_total <-
   rbind(vehicle_list[[1]],vehicle_list[[2]],
         vehicle_list[[3]],vehicle_list[[4]],
         vehicle_list[[5]],vehicle_list[[6]])
 vehicle_df <- ddply(vehicle_total, .(Year, Fuel.Type), function(df){
   return(sum(df$Number.of.Vehicles))
 })
vehicle_df
 name_fuel_vehicle <- substr(vehicle_df$Fuel, 
                             nchar(vehicle_df$Fuel)-3, 
                             nchar(vehicle_df$Fuel)-1)
 
 name_fuel_vehicle <- replace(name_fuel_vehicle, name_fuel_vehicle=="EVC", "ELEC")
 name_fuel_vehicle <- replace(name_fuel_vehicle, name_fuel_vehicle=="HYD", "HY")
 year_vehicle <- as.character(vehicle_df$Year)
 fuel_vehicle <- mapply(function(Year, type){
     selected_years <- as.numeric(rownames(table_fuel_year)) <= as.numeric(Year)
     fuel_number <- sum(table_fuel_year[selected_years,type])
     return(fuel_number)
     }, 
                        year_vehicle, 
                        as.vector(name_fuel_vehicle))
 
 fuel_vehicle_add <- mapply(function(Year, type){
   selected_years <- as.numeric(rownames(table_fuel_year)) == as.numeric(Year)
   fuel_number <- (table_fuel_year[selected_years,type])
   return(fuel_number)
 }, 
 year_vehicle, 
 as.vector(name_fuel_vehicle))
 
 
 
  year_total <- as.numeric(tapply(fuel_vehicle, names(fuel_vehicle), sum))
  num_year <- as.numeric(table(names(fuel_vehicle)))
  fenmu <- rep.int(year_total, num_year)
  prop <- round((fuel_vehicle / fenmu),4)
  vehicle_df$Fuel <- fuel_vehicle
  vehicle_df$Type <- name_fuel_vehicle 
  vehicle_df_final <- data.frame(Year = vehicle_df$Year,
                                 Type = vehicle_df$Type,
                                 Vehicle = vehicle_df$V1,
                                 Fuel = vehicle_df$Fuel,
                                 Prop =  prop,
                                 add_fuel = fuel_vehicle_add
                                 ) 

kaicolorset2 <- c("red","blue","orange","brown","black","green")


vehicle_df_final2 <- vehicle_df_final[order(vehicle_df_final$Type),] 
rownames(vehicle_df_final2) <- 1:53
vehicle_df_final2 <- rbind(vehicle_df_final2[c(1,12,17,28,32,43),],
                           vehicle_df_final2)
vehicle_df_final2 <- vehicle_df_final2[order(vehicle_df_final2$Type),] 
vehicle_df_final2$Speed <- c(1,(vehicle_df_final2$Vehicle[2:59]-vehicle_df_final2$Vehicle[1:58]) / vehicle_df_final2$Vehicle[1:58])
rownames(vehicle_df_final2) <- 1:59
vehicle_df_final2 <- vehicle_df_final2[-c(1,13,19,31,36,48),]

makeupdata <- matrix(data = c(2004, "E85", 0,0,0,0,0,
                              2004, "HY",0,0,0,0,0,
                              2005, "E85", 0,0,0,0,0, 
                              2005, "HY",0,0,0,0,0,
                              2006, "E85", 0,0,0,0,0, 
                              2006, "HY",0,0,0,0,0,
                              2007, "E85", 0,0,0,0,0, 
                              2007, "HY",0,0,0,0,0,
                              2008, "E85", 0,0,0,0,0, 
                              2008, "HY",0,0,0,0,0,
                              2009, "E85", 0,0,0,0,0, 
                              2009, "HY",0,0,0,0,0,
                              2010, "HY",0,0,0,0,0), ncol = 7, byrow = T)



makeupdata <- data.frame(makeupdata)
colnames(makeupdata) <- c("Year","Type","Vehicle","Fuel","Prop","Speed","add_fuel")

vehicle_df_final2 <- rbind(vehicle_df_final2, makeupdata)
vehicle_df_final2 <- vehicle_df_final2[order(vehicle_df_final2$Type),]
vehicle_df_final2 <- vehicle_df_final2[order(vehicle_df_final2$Year),]

vehicle_df_final2$Year <- as.numeric(vehicle_df_final2$Year)
vehicle_df_final2$Vehicle <- as.numeric(vehicle_df_final2$Vehicle)
vehicle_df_final2$Fuel <- as.numeric(vehicle_df_final2$Fuel)
vehicle_df_final2$Speed <- as.numeric(vehicle_df_final2$Speed)
vehicle_df_final2$Prop <- as.numeric(vehicle_df_final2$Prop)
vehicle_df_final2$Type <- factor(vehicle_df_final2$Type)
vehicle_df_final2$add_fuel <- as.numeric(vehicle_df_final2$add_fuel)



### 21 rep.int(year_total, num_year)
  initial_vehicles2 <- rep(c(41711,254077,2227,33,1166,26978),  11)
  vehicle_df_final2$Vehicle_scale <- vehicle_df_final2$Vehicle / initial_vehicles2
 
###

p34 <- vehicle_df_final2 %>%
  plot_ly(x = ~Fuel, y = ~Vehicle_scale, color = ~Type, 
               size = ~Prop^(1/2) * 50, colors = kaicolorset2, 
               type = 'scatter', mode = 'markers', frame = ~Year, 
               opacity = 0.3,
               sizes = 120*(c(min(vehicle_df_final2$Prop), max(vehicle_df_final2$Prop)))^(1/3),
               marker = list(symbol = 'circle', sizemode = 'diameter',
                             line = list(width = 0.5, color = '#FFFFFF')),
               text = ~paste(Type, ':<br>', Prop*100, '%')) %>%
  layout(title = 'Relation between Vehicles and Fuel Stations<br>Animation',
         height = 477,
         xaxis = list(title = 'Fuel Stations Accumulation<br>Animation',
                      gridcolor = '#ffffff',
                    range = c(0, 5300),
                      zerolinewidth = 1,
                      ticklen = 5,
                      gridwidth = 2),
         yaxis = list(title = 'Vehicles',
                      gridcolor = '#ffffff',
                      zerolinewidth = 1,
                      range = c(0, 4.6),
                      ticklen = 5,
                      gridwith = 2),
         # paper_bgcolor = 'rgb(243, 243, 243)',
          plot_bgcolor = 'rgb(243, 243, 243)'
  )%>%
  animation_opts(1000, easing = "elastic") %>%
  animation_button(
    x = 0, xanchor = "right", y = 0.1, yanchor = "top"
  ) %>%
  animation_slider(
    currentvalue = list(prefix = "Year ", font = list(color="Orange"))
  )

 
p34


rownames(vehicle_df_final2) <- 1:nrow(vehicle_df_final2)
fuel_vehicle_add3 <- fuel_vehicle_add[-c(1,2,3,4,27,33)]
regular <- which(vehicle_df_final2$Speed ==0)
regular <- regular[1:(length(regular)-1)]
vehicle_df_final3 <- vehicle_df_final2[-regular,]

reg_df <- data.frame(add_station = fuel_vehicle_add3, 
                     rate_increasing = vehicle_df_final3$Speed,
                     Type = vehicle_df_final3$Type,
                     Year = vehicle_df_final3$Year)



reg_df <- reg_df[order(reg_df$rate_increasing),]


vehicle_df_final3 <- vehicle_df_final2[-c(2,4,8,10,14,16,20,22,26,28,32,34,40),]

p36 <- 
  vehicle_df_final3 %>%
  plot_ly(x =~ Fuel, y =~ Vehicle_scale, color =~ Type, visible = T,
          type = "scatter", size = 10, sizes = c(11,15), text =~ Year)%>%
  layout(
    title = "Relation between Vehicles and Fuel Stations<br>Scatter Plots",
    updatemenus = list(
      list(
        x = 0,
        y = 1.1,
        type = "buttons",
        showactive = F,
   #     bgcolor = "yellow",
        bgcolor = "#fc9272",
        borderwidth = 0,
        active = 1,
        buttons = list(
          list(method = "restyle",
             args = list("visible", "legendonly"),
              label = "CLEAR")
        )
       )
    ),
    
    
    xaxis = list(title = 'Number of Stations',
                 gridcolor = 'rgb(255, 255, 255)',
                 zerolinewidth = 1,
                 ticklen = 5,
                 gridwidth = 1),
    yaxis = list(title = 'Vehicles',
                 gridcolor = 'rgb(255, 255, 255)',
                 zerolinewidth = 1,
                 ticklen = 5,
                 gridwidth = 1),
    #paper_bgcolor = 'rgb(243, 243, 243)',
     plot_bgcolor = 'rgb(243, 243, 243)'
    
    
  ) 
 p36

df_state_area <- read.csv("../data/State_Areas.csv", 
                          header = F,
                          stringsAsFactors = F)

str(df_state_area)
areas <- df_state_area$V4
areas <- substr(areas, 1, nchar(areas)-6)
Areas <- as.numeric(sapply(strsplit(areas, ","), paste, collapse = ""))
df_state_area <- data.frame(State = df_state_area$V1, 
                            Areas_sq_km = Areas,
                            stringsAsFactors = F)

df_state_area$State[51] <- "DC"
states_abbr <- df_state_area$State
for (i in 1:50){
  states_abbr <- replace(states_abbr,  states_abbr== FULL[i], ABBR[i])
}
df_state_area$State <- states_abbr
df_state_area <- df_state_area[order(df_state_area$State),]
rownames(df_state_area) <- 1:51



