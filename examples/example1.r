### Enter Login and Password information for Movebank

## Not run: 
# login <- movebankLogin(username="xxxx", password="xxxx")

ge1 <- getMovebankData(study="ABoVE: HawkWatch International Golden Eagles", animalName="37307a", login=login) #one bird, one deployment
ge1.dailymean <- processMovedata(ge1,  id = "deployment_id")

ge2 <- getMovebankData(study="Aquila chrysaetos interior west N. America, Craigs, Fuller", animalName="629-26704", login=login) 
# one bird, three deployments
ge2.dailymean <- processMovedata(ge2,  id = "deployment_id")

# a few simple methods:
plot(ge2.dailymean)

## Not run:
# load("./hidden/ge.rda")
ge.dailymean <- processMovedata(ge)
