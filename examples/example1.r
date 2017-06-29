### Enter Login and Password information for Movebank

## Not run: 
# login <- movebankLogin(username="xxxx", password="xxxx")

# Pull data from movebank
ge1 <- getMovebankData(study="ABoVE: HawkWatch International Golden Eagles", login=login)     #multiple birds

# Estimate daily mean locations
ge1.dailymean <- processMovedata(ge1,  id = "individual_id", dailymean = TRUE)

# Three convenient "movetrack" methods:
summary(ge1.dailymean)
plot(ge1.dailymean)
map(ge1.dailymean)


# one bird, three deployments
ge2 <- getMovebankData(study="Aquila chrysaetos interior west N. America, Craigs, Fuller", animalName="629-26704", login=login) 

# all locations and all columns
ge2.dailymean <- processMovedata(ge2,  id = "individual_id", keepCols = "all")
summary(ge2.dailymean)



# all locations and all columns
ds.df <- processMovedata(ds,  id = "individual_id", keepCols = "all", dailymean=TRUE)
summary(ds.df)
map(ds.df)
