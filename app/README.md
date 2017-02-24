# Project: NYC Open Data
### App folder

The App directory contains the app files for the Shiny App (i.e., ui.r and server.r).

Notice:
If your plotly version is not 4.5.6.9, then please run the code in the comments to make sure there's no bug:

#if(!require("devtools")) install.packages("devtools")
#devtools::install_github("ropensci/plotly",force=TRUE)
