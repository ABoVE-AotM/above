# specify names of data file to annotate (e.g. output of grid) and xml file with the request

csv.file <- "../sandbox/testdata.csv"
xml.file <- "../sandbox/testrequest.xml"

# create a gridded dataset

lats <- seq(38.8, 39.0, length = 40)
lons <- seq(-77.12, -76.91, length = 40) 
start <- ymd("2014-01-01")
finish <- ymd("2014-01-01")

createEnvDataGrid(lats, lons, start, finish, 0, 
                  savefile = TRUE, 
                  fileout = csv.file)

# create an xml request
createEnvDataRequest(request_name = "TestRequest", 
                     type_name = "aster/ASTGTM2", 
                     variable_name = "dem",  
                     interpolation_type = "bilinear",
                     dist_func_spatial="geodetic",
                     email = email,
                     savefile = TRUE, 
                     fileout = xml.file)

# send the request to the server
uploadEnvDataRequest(csv.file, xml.file, 
                     link.file = "annotation_status_link.url")
