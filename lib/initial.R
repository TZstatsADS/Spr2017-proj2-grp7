fileUrl<-"https://developer.nrel.gov/api/alt-fuel-stations/v1.csv?api_key=Qf1NPRTeyq65qExWvjIVoGmqxyNu6QxYEHgFrZM4&state=NY"
download.file(fileUrl,'./data.csv','curl')
metadata<-read.csv('./data.csv')

fileUrl2<-"https://developer.nrel.gov/api/alt-fuel-stations/v1/nearby-route.csv?api_key=Qf1NPRTeyq65qExWvjIVoGmqxyNu6QxYEHgFrZM4&route=LINESTRING(-74.0+40.7,-87.63+41.87,-104.98+39.76)"
download.file(fileUrl2,'./route.csv','curl')
