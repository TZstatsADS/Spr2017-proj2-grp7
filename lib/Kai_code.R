
path_alt_fuel_station <- "../data/alt_fuel_stations (Feb 12 2017).csv"
alt_fuel_station <- read.csv(path_alt_fuel_station, 
                             stringsAsFactors = F,
                             header = T)
nrow(alt_fuel_station)

### Remove stations with no record on either open date or expected open date
### Then Create a new variable to give the date of opening
grow_afs <- 
  alt_fuel_station %>%
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
                                      return(table_fuel_year[Year,type])
                                            }, 
                        year_vehicle, 
                        as.vector(name_fuel_vehicle))
  vehicle_df$Fuel <- fuel_vehicle
  vehicle_df$Type <- name_fuel_vehicle 
  vehicle_df_final <- data.frame(Year = vehicle_df$Year,
                                 Type = vehicle_df$Type,
                                 Vehicle = vehicle_df$V1,
                                 Fuel = vehicle_df$Fuel) 
  
# sapply(ca_vehicle, colnames, c("Year","Vehicles","Comsumption"))
# 
# ca_vehicle_df <- ca_vehicle[[1]]
# colnames(ca_vehicle_df) <- c("Year", "Vehicles", "Consumptions")
# ca_vehicle_df$Type = "CNG"
# 
# for (i in 2:6){
#   temp_df <- ca_vehicle[[i]]
#   colnames(temp_df) <- c("Year", "Vehicles", "Consumptions")
#   temp_df$Type = substr(temp[i],22,24)
#   ca_vehicle_df <- rbind(ca_vehicle_df, temp_df)
# }
# 



### p2 location differences 
# 
# 
# 
# names_fuel <- sort(unique(grow_afs$Fuel.Type.Code))
# x <- c(names_fuel,"Total")
# y1 <- unlist(grow_state_condition["CA",3:10])
# y2 <- unlist(grow_state_condition["NY",3:10])
# data <- data.frame(x, y1, y2)
# 
# #The default order will be alphabetized unless specified as below:
# data$x <- factor(data$x, levels = data[["x"]])
# 
# p <- plot_ly(data, x = ~x, y = ~y1, type = 'bar', name = paste(), marker = list(color = 'rgb(49,130,189)')) %>%
#   add_trace(y = ~y2, name = 'Secondary Product', marker = list(color = 'rgb(204,204,204)')) %>%
#   layout(xaxis = list(title = "", tickangle = -45),
#          yaxis = list(title = ""),
#          margin = list(b = 100),
#          barmode = 'group')
# 
# p
#   
#   




# g <- list(
#   scope = 'usa',
#   projection = list(type = 'albers usa')
# )








# 
# 
# 
# df <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2014_ebola.csv')
# # restrict from June to September
# df <- subset(df, Month %in% 6:9)
# # ordered factor variable with month abbreviations
# df$abbrev <- ordered(month.abb[df$Month], levels = month.abb[6:9])
# # September totals
# df9 <- subset(df, Month == 9)

# # common plot options
# g <- list(
#   scope = 'africa',
#   showframe = F,
#   showland = T,
#   landcolor = toRGB("grey90")
# )
# 
# g1 <- c(
#   g,
#   resolution = 50,
#   showcoastlines = T,
#   countrycolor = toRGB("white"),
#   coastlinecolor = toRGB("white"),
#   projection = list(type = 'Mercator'),
#   list(lonaxis = list(range = c(-15, -5))),
#   list(lataxis = list(range = c(0, 12))),
#   list(domain = list(x = c(0, 1), y = c(0, 1)))
# )
# 
# g2 <- c(
#   g,
#   showcountries = F,
#   bgcolor = toRGB("white", alpha = 0),
#   list(domain = list(x = c(0, .6), y = c(0, .6)))
# )


# 
# zipcode <- read.csv("../data/zip_codes_states.csv")
# new_df <- melt(df_fuel_state_int)
# new_zipcode$Lat <- tapply(new_df)
# 
# p <- new_df %>%
#   plot_geo(
#     locationmode = 'USA-states', sizes = c(1, 1000), color = I("black")
#   ) %>%
#   layout(
#     title = 'Ebola cases reported by month in West Africa 2014<br> Source: <a href="https://data.hdx.rwlabs.org/dataset/rowca-ebola-cases">HDX</a>',
#     geo = g
#   ) %>%
# 
#     add_markers(
#     y = ~Lat, x = ~Lon, locations = ~state,
#     size = ~ value, color = ~ variable, text = ~paste(Value, "cases")
#   ) %>%
#   add_trace(
#     data = df_fuel_state_int[,1:7], z = ~df_fuel_state_int[,1:7], locations = ~state,
#     showscale = F, geo = g
#   ) %>%
#   p


# 
# 
#  
#  data.frame(table_grow_afs[,"1971",])
# 
# 
# data(gapminder, package = "gapminder")
# gg <- ggplot(gapminder, aes(gdpPercap, lifeExp, color = continent)) +
#   geom_point(aes(size = pop, frame = year)) +
#   scale_x_log10()
# ggplotly(gg)


# 
# find_info <- function(year, state){
#     Fuel.Type <- names(which.max(table_grow_afs[,as.character(year:(year+3))), state]))
#     Sum.Year <- sum(table_grow_afs[,as.character(year), state])
#     return(c(year, state, Fuel.Type, Sum.Year))
# }
# ma <- t(mapply(find_info,rep(seq(1970,2014,4), each=51),rep(states_total,time = 12)))
# ani_df <- data.frame(Year = as.numeric(ma[,1]), State  = factor(ma[,2]), 
#                      Fuel = factor(ma[,3]), Total = as.numeric(ma[,4]),
#                      stringsAsFactors = FALSE)
# ani_df
# 
# # 



df_fake <- data.frame(Year = 1995:2015,
                      Prop = runif(21)*40,
                      Vehicle = rnorm(21,10000,2000),
                      Station = rnorm(21,10000,2000),
                      Col = c(rep(c("Green","Red"),10),"Red")
                      )


p33 <- plot_ly(vehicle_df_final, x = ~Fuel, y = ~Vehicle, text = ~Fuel,
               type = 'scatter', mode = 'markers', frame = ~Year,
             marker = list(size = ~20, opacity = 0.5,
                           color = ~Type)) %>%
  layout(title = 'Gender Gap in Earnings per University',
         xaxis = list(showgrid = T),
         yaxis = list(showgrid = T)) %>%
  animation_opts(1000, easing = "elastic") %>%
  animation_button(
    x = 1, xanchor = "right", y = 0, yanchor = "bottom"
  ) %>%
  animation_slider(
    currentvalue = list(prefix = "Year ", font = list(color="red"))
  )
p33
# 
# # 
# # base <- df_fake %>%
# #   plot_ly(x = ~Station, y = ~Vehicle, size = ~(Prop),
# #           hoverinfo = "text", trace = Year) %>%
# #   layout() %>%
# #   add_markers(color = ~Fuel, frame = ~Year, ids = ~State) %>%
# #   animation_opts(1000, easing = "elastic") %>%
#   animation_button(
#     x = 1, xanchor = "right", y = 0, yanchor = "bottom"
#   ) %>%
#   animation_slider(
#     currentvalue = list(prefix = "Year ", font = list(color="red"))
#   )
# 
# 
# base
# find_info(2016,"CA")



