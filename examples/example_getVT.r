## Not run: 
### Enter Login and Password information for Movebank
# login <- movebankLogin(username="xxxx", password="xxxx")

# Download data
ds <- getMovebankData(study="ABoVE: NPS Dall Sheep Lake Clark", login=login) 

# Process data for use in above package
ds.mt <- processMovedata(ds,  idcolumn = "individual_id", projTo = '+init=epsg:3338', 
                        keepCols = c('sex'), dailymean = TRUE)

# Summarize and find individual
ds.vt <- getVT(ds.mt, units = 'hours', geoDist = FALSE)
