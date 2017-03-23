### Enter Login and Password information for Movebank

## Not run: 
# login <- movebankLogin(username="xxxx", password="xxxx")

# Pull data from movebank
ge1 <- getMovebankData(study="ABoVE: HawkWatch International Golden Eagles", login=login)     #multiple birds

# Estimate daily mean locations
ge1.dailymean <- processMovedata(ge1,  id = "individual_id", dailymean = TRUE)


# one bird, three deployments
ge2 <- getMovebankData(study="Aquila chrysaetos interior west N. America, Craigs, Fuller", animalName="629-26704", login=login) 

# Estimate daily mean locations
ge2.dailymean <- processMovedata(ge2,  id = "individual_id", dailymean = FALSE)

# Plot daily movements (currently only displays 1 individual)
plot(ge2.dailymean)
