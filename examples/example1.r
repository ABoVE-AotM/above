### Enter Login and Password information for Movebank

## Not run: 
# login <- movebankLogin(username="xxxx", password="xxxx")

# Pull data from movebank
ge1 <- getMovebankData(study="ABoVE: HawkWatch International Golden Eagles", login=login)     #multiple birds

# Estimate daily mean locations
ge1.dailymean <- processMovedata(ge1,  id = "individual_id", dailymean = TRUE, getVT = TRUE, geoDist = FALSE)

# Include trajectory statistics
ge1.traj <- processMovedata(ge1,  id = "individual_id", getVT = TRUE)

# one bird, three deployments
ge2 <- getMovebankData(study="Aquila chrysaetos interior west N. America, Craigs, Fuller", animalName="629-26704", login=login) 

# Estimate daily mean locations
ge2.dailymean <- processMovedata(ge2,  id = "individual_id", dailymean = TRUE, geoDist = FALSE)

# Plot daily movements (currently only displays 1 individual)
plot(ge2.dailymean)

# Return a SpatialPointsDataFrame
ge2.spdf <- processMovedata(ge2,  id = "individual_id", dailymean = TRUE, returnSPDF = T)

# Include trajectory statistics
ge2.traj <- processMovedata(ge2,  id = "individual_id", getVT = TRUE)
