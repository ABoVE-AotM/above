### The `above` R package
#### authors: Elie Gurarie and Peter Mahoney and Scott LaPoint and Sarah Davidson and others




#### To-Do:

- Include simulated data for quick loading and examples 
- Improve multimigration (EG)
- Add step-selection functions (PM)
- Annotation code





#### Background

This R package will collaboratively help participants of the Animals on the Move subproject of the Arctic Boreal Vulnerability Experiment (above) share code for analysis of animal movements and migrations. 

For now, it contains: 

1. preprocesseing [movebank.org]() functions to get daily means
2. some convenient methods (`summary`, `plot`, `map.track`) to work with movetrack's 
3. functions for multi-migration analysis

Example below:


#### Install package

From GitHub, you need to install first the [`marcher`](https://github.com/EliGurarie/marcher) package, then this package:


```r
require(devtools)
install_github("EliGurarie/marcher")
install_github("ABoVE-AotM/above")
```




#### Loading eagle data

ABoVE members with access to some golden eagle data can load it using 


```r
login <- movebankLogin(username = "somethingsecret", password = "somethingsecret")
```



Load a few datasets:


```r
ge1 <- getMovebankData(study="ABoVE: HawkWatch International Golden Eagles", animalName="37307a", login=login) 
ge2 <- getMovebankData(study="Aquila chrysaetos interior west N. America, Craigs, Fuller", animalName="629-26704", login=login) 
```




These are `Move` objects, but they're slightly different:

```r
is(ge1)
```

```
##  [1] "Move"                   ".MoveTrackSingle"      
##  [3] ".MoveGeneral"           ".OptionalMove"         
##  [5] ".MoveTrack"             ".unUsedRecords"        
##  [7] "SpatialPointsDataFrame" "SpatialPoints"         
##  [9] "Spatial"                "SpatialVector"
```

```r
is(ge2)
```

```
##  [1] "MoveStack"              ".MoveTrackStack"       
##  [3] ".MoveGeneral"           ".OptionalMove"         
##  [5] ".MoveTrack"             ".unUsedRecordsStack"   
##  [7] "SpatialPointsDataFrame" ".unUsedRecords"        
##  [9] "SpatialPoints"          "Spatial"               
## [11] "SpatialVector"
```



#### Processing data

For migration analysis we simplify (and get daily averages) using the `processMovedata` function, which reduces the data to daily average locations (in latitude, longited and x and y):


```r
ge1.simple <- processMovedata(ge1, idcolumn = "deployment_id")
head(ge1.simple)
```

```
##   movebank_study        id                time      lon    lat        x
## 1           <NA> 171299043 2003-10-06 04:45:00 -106.411 34.704 -106.411
## 2           <NA> 171299043 2003-10-06 17:44:53 -106.473 34.644 -106.473
## 3           <NA> 171299043 2003-10-06 19:25:04 -106.227 34.215 -106.227
## 4           <NA> 171299043 2003-10-06 20:04:42 -106.111 33.898 -106.111
## 5           <NA> 171299043 2003-10-08 23:44:41 -105.922 31.710 -105.922
## 6           <NA> 171299043 2003-10-09 00:49:38 -105.888 31.705 -105.888
##        y                                            proj4string
## 1 34.704 +proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0
## 2 34.644 +proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0
## 3 34.215 +proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0
## 4 33.898 +proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0
## 5 31.710 +proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0
## 6 31.705 +proj=longlat +ellps=WGS84 +datum=WGS84 +towgs84=0,0,0
##        dateDownloaded
## 1 2017-02-23 00:48:13
## 2 2017-02-23 00:48:13
## 3 2017-02-23 00:48:13
## 4 2017-02-23 00:48:13
## 5 2017-02-23 00:48:13
## 6 2017-02-23 00:48:13
```

This is a `track` object (specific for this package), which has some convenient methods:


```r
summary(ge1.simple)
```

```
##          id    n               start duration  dt.median
## 1 171299043 1002 2003-10-06 04:45:00 391 days 9.37 hours
```


Note that `x` and `y` are UTM coordinates - you can either provide a `proj4` projection string or, by default, it will pick the zone of the midpoint. 

The plotting function is similar to the `scan.track` function in `marcher`


```r
plot(ge1.simple)
```

```
## png 
##   2
```

![]("./plots/ge1.png")

For the second data set (`ge2`) there are three deployments of 1 eagle, each with a unique identifier. 


```r
ge2.simple <- processMovedata(ge2, idcolumn = "deployment_id")
summary(ge2.simple)
```

```
##          id   n               start duration   dt.median
## 1 196430584 247 1993-01-07 21:58:39 217 days 21.15 hours
## 2 196430597 276 1994-01-27 22:40:46 105 days  9.17 hours
## 3 196430599  98 1995-12-10 02:32:49 338 days 83.52 hours
```

And we see a simple straight one-time migration in these data. 

```r
plot(subset(ge2.simple, id == "196430584"))
```


```
## png 
##   2
```

![]("./plots/ge2.png")

#### Migration analysis

*Examples to come*


