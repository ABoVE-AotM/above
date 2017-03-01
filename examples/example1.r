### Enter Login and Password information for Movebank

## Not run: 
# login <- "somethingsecret"
# password <- "somethingsecret"

ge1 <- getMovebankData(study="ABoVE: HawkWatch International Golden Eagles", animalName="37307a", login=login) #one bird, one deployment
ge1.dailymean <- processMovedata(ge1,  id = "deployment_id")

ge2 <- getMovebankData(study="Aquila chrysaetos interior west N. America, Craigs, Fuller", animalName="629-26704", login=login) 
# one bird, three deployments
ge2.dailymean <- processMovedata(ge1,  id = "deployment_id")


ge.dailymean <- processMovedata(ge)
