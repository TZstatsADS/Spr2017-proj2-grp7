##find nearby route of fueling stations
library(RCurl)
library(RJSONIO)
library(leaflet)
library(googleway)

fuelstationicon<-icons("http://www.clker.com/cliparts/d/8/3/4/131550836610655076Gas%20Station%20Sign.svg.med.png",iconWidth = 18,iconHeight = 18)
key <- "AIzaSyCikL8oIlbvv77sFqclmjt4crRL_08zffk"

#function to get the geocode of an address
geocode<-function(add){
  root<-"https://maps.google.com/maps/api/geocode/"
  url<-paste0(root,"json?address=",add,"&key=AIzaSyC82ht4goSYy9M7Dp9tXc-vO9qxCoeF0jM")
  u<-getURL(URLencode(url))
  u<-fromJSON(u,simplify=FALSE)
  if (u$status=="OK"){
    lat<-as.numeric(u$results[[1]]$geometry$location$lat)
    lng<-as.numeric(u$results[[1]]$geometry$location$lng)
    location_type<-u$results[[1]]$geometry$location_type
    formatted_address<-u$results[[1]]$formatted_address
    return(c(lat,lng,location_type,formatted_address))
  } else {
    return(rep(NA,4))
  }
}

#start <- "Columbia University in the city of new york"
#end <- "Chicago University"

#function to return the stations and route nodes
get_myrouteandstations<-function(start,end){
  #get the geocode of origin and destination
  
  startcoord <- geocode(start)[2:1]
  endcoord <- geocode(end)[2:1]
  
  #get locations of fueling stations along the road  
  fileUrl2<-paste("https://developer.nrel.gov/api/alt-fuel-stations/v1/nearby-route.csv?api_key=Qf1NPRTeyq65qExWvjIVoGmqxyNu6QxYEHgFrZM4&route=LINESTRING(",startcoord[1],"+"
                  ,startcoord[2],",",endcoord[1],"+",endcoord[2],")",sep = "")
  download.file(fileUrl2,'./route.csv','curl')
  nearbyfuelstations<-read.csv('./route.csv')
  
  #use google direction API to get the direction of two locations
  myroute<-google_directions(origin = start,
                             destination = end,
                             mode = "driving",
                             key = key)
  
  df_polyline <- decode_pl(myroute$routes$overview_polyline$points)
  return(list(stations=nearbyfuelstations,routnode=df_polyline))
}


#mylongroute<-get_myrouteandstations(start,end)
#plot the fueling stations on the map
# leaflet() %>%
#   addTiles() %>%
#   addMarkers(data = mylongroute$stations, lat =  ~Latitude, lng = ~Longitude,icon =fuelstationicon) %>%
#   addPolylines(data = mylongroute$routnode,lat = ~lat, lng = ~lon)



