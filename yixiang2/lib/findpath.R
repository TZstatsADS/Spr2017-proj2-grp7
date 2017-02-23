library(RCurl)
library(RJSONIO)
library(leaflet)
library(igraph)
library(geosphere)
load("../data/Nodes.RData")
load("../data/Segments.RData")
load("../data/Original Segments.RData")


stations<-read.csv("../data/data.csv",header=TRUE)





#----------------------------------------------------
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

Nearest.Node<-function(Nodes=Nodes,Coord){
  D = (Nodes[,1]-Coord[1])^2+(Nodes[,2]-Coord[2])^2
  return(Nodes[which.min(D),"ID"])
}

sift.station<-function(scoord,ecoord,type,net,con){
  station0<-data.frame(lat=as.numeric(stations$Latitude),
                      lng=as.numeric(stations$Longitude))
  m<-length(type)
  station<-data.frame(lat=NULL,lng=NULL)
  for (i in 1:m){
    if (type[i]!="ELEC"){
      station<-rbind(station,station0[stations$Fuel.Type.Code==type[i],])
    }
    else{
      if (con=="All"&net=="All") station<-rbind(station,station0[stations$Fuel.Type.Code==type[i],])
      if (con!="All"&net=="All") station<-rbind(station,station0[stations$Fuel.Type.Code==type[i]&grepl(con,stations$EV.Connector.Types),])
      if (con=="All"&net!="All") station<-rbind(station,station0[stations$Fuel.Type.Code==type[i]&stations$EV.Network==net,])
      if (con!="All"&net!="All")
      station<-rbind(station,station0[stations$Fuel.Type.Code==type[i]&grepl(con,stations$EV.Connector.Types)&stations$EV.Network==net,])
    }
  }
  
  x<-ecoord-scoord
  station.dir<-data.frame(lat=(station$lat-scoord[2]),lng=(station$lng-scoord[1]))
  station.l<-station.dir$lat^2+station.dir$lng^2
  l<-station.dir$lat*x[2]+station.dir$lng*x[1]
  l<-l/station.l
  i1<-which.max(l)
  i2<-which.max(l[-i1])
  return(c(station$lat[i1],station$lng[i1],station$lat[i2],station$lng[i2]))
} 


Shortest<-function(New.Segments,U.Nodes,Start.ID,End.ID){
  float <- 0.01
  Start <- U.Nodes[Start.ID,]
  End <- U.Nodes[End.ID,]
  Segments <- New.Segments
  Segments$Distance<-rep(1,nrow(Segments))
  df <- as.data.frame(Segments[c("Start","End","Distance")])
  names(df) <- c("start_node","end_node","dist")
  gdf <- graph.data.frame(df, directed=FALSE)
  SHORT.Go = shortest_paths(gdf,as.character(Start.ID),as.character(End.ID),weights = E(gdf)$dist)$vpath
  EDGE.Go = as.numeric(shortest_paths(gdf,as.character(Start.ID),as.character(End.ID),output = "epath",weights = E(gdf)$dist)$epath[[1]])
  names<-V(gdf)$name  
  Sequence.Go =as.numeric(lapply(SHORT.Go,function(x){names[x]})[[1]])
  
  EDGE.Back = rev(EDGE.Go)
  EDGE.index = c(EDGE.Go,EDGE.Back[-1])
  EDGE = Segments[EDGE.index,]
  Sequence.Back = rev(Sequence.Go)
  Sequence = c(Sequence.Go,Sequence.Back[-1])
  
  return(list(Path = EDGE,edge.index =c(EDGE.Go,EDGE.Back[-1]),Nodes.Go = Nodes[Sequence.Go,1:2],Nodes.Back = Nodes[Sequence.Back,1:2]))
}

GetLength<-function(Edge){
  GL<-function(r){
    return(distm(r[1:2],r[3:4],fun = distHaversine)[,1]/1000)
  }
  D = apply(Edge,1,GL)
  return(sum(D))
}



Findpath<-function(start,end,Nodes=Nodes,Segments=Segments,stations=stations
                   ,fueltype=c("CNG","ELEC"),
                   network="All",connector="All"){
  startCoord<-as.numeric(geocode(start)[2:1])
  start.Node<- Nearest.Node(Nodes,startCoord)
  endCoord<-as.numeric(geocode(end)[2:1])
  end.Node <- Nearest.Node(Nodes,endCoord)
  fuel.stat<-sift.station(startCoord,endCoord,fueltype,network,connector)[2:1]
  station.Node<-Nearest.Node(Nodes,fuel.stat)
  fuel.stat2<-sift.station(startCoord,endCoord,fueltype,network,connector)[4:3]
  station.Node2<-Nearest.Node(Nodes,fuel.stat2)
  
  Path1 <- Shortest(Segments,Nodes,start.Node,station.Node)
  Path2 <- Shortest(Segments,Nodes,station.Node,end.Node)
  Path <-list(Path=rbind(Path1$Path,Path2$Path),
              edge.index=c(Path1$edge.index,Path2$edge.index),
              Nodes.Go=rbind(Path1$Nodes.Go,Path2$Nodes.Go))
  P1 <- Shortest(Segments,Nodes,start.Node,station.Node2)
  P2 <- Shortest(Segments,Nodes,station.Node2,end.Node)
  P <-list(Path=rbind(P1$Path,P2$Path),
           edge.index=c(P1$edge.index,P2$edge.index),
           Nodes.Back=rbind(P2$Nodes.Back,P1$Nodes.Back))
  
  #Edge.index = Path$edge.index
  #Edge = Path$Path
  #colnames(startCoord) = c("Longtitude","Latitude")
  #colnames(endCoord) = c("Longtitude","Latitude")
  Route.Go = rbind(startCoord,Path$Nodes.Go,endCoord)
  Route.Back = rbind(endCoord,P$Nodes.Back,startCoord)
  
  #EDGE = Segments[Edge.index,]
  #Length = GetLength(EDGE)
  #Route.Score = sum(1/Edge$Distance)/nrow(Edge)
  #,Edge = EDGE ,Length = Length, Score = Route.Score,End.Point = endCoord))
  return(list(go=Route.Go,back=Route.Back,station=station.Node,station2=station.Node2))
}

Nearest.station<-function(add){
  addr<-as.numeric(geocode(add)[2:1])
  fileUrl<-"https://developer.nrel.gov/api/alt-fuel-stations/v1/nearest.csv?api_key=Qf1NPRTeyq65qExWvjIVoGmqxyNu6QxYEHgFrZM4&"
  fileUrl<-paste0(fileUrl,"latitude=",addr[2],"&longitude=",addr[1])
  download.file(fileUrl,'../data/nearbystation.csv','curl')
  df<-read.csv("../data/nearbystation.csv",header=TRUE)
  return(list(lat=as.numeric(df$Latitude),lng=as.numeric(df$Longitude)))
}


