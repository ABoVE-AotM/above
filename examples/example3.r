## Not run: 
### Enter Login and Password information for Movebank
# login <- movebankLogin(username="xxxx", password="xxxx")

# Download data
ds <- getMovebankData(study="ABoVE: NPS Dall Sheep Lake Clark", login=login) 

# Process data for use in above package
ds.mt <- processMovedata(ds,  idcolumn = "individual_id", projTo = '+init=epsg:3338', 
                        keepCols = c('sex'), dailymean = TRUE)

# Summarize and find individual
summary(ds.mt)
plot(ds.mt)

#240653478 or 240653490
di <- subset(ds.mt, id == 240653490)

# Plot movement tracks to identify migrations and use
# with locator below
par(mfrow=c(2,1), mar = c(0,0,0,0), oma = c(5,5,2,2))
with(di, plot(day, x, type='o'))
with(di, plot(day, y, type='o'))

# Use locator to bracket each individual (i.e., directional) migration
span1 <- locator(4)$x
span2 <- locator(4)$x

di.migrations <- fitMultiMigration(di, span1, span2, plot = TRUE)
di.migrations
