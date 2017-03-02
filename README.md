### The `above` R package
#### authors: Elie Gurarie and collaborators




This R package will collaboratively help participants of the Animals on the Move subproject of the Arctic Boreal Vulnerability Experiment (above) share code for analysis of animal movements and migrations. 

For now, it contains: 

1. preprocesseing [movebank.org]() functions to get a simpler data frame (and daily means) in the form of an (invented) `movetrack` object.
2. some convenient methods (`summary`, `plot`, `map.track`) to work with `movetrack`'s
2. functions for multi-migration analysis

Example below:

### Install package

From GitHub, you need to install first the [`marcher`](https://github.com/EliGurarie/marcher) package, then this package:


```r
require(devtools)
install_github("EliGurarie/marcher")
install_github("ABoVE-AotM/above")
```

### Loading eagle data

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
## [1] "Move"                   ".MoveTrackSingle"      
## [3] ".MoveGeneral"           ".MoveTrack"            
## [5] ".unUsedRecords"         "SpatialPointsDataFrame"
## [7] "SpatialPoints"          "Spatial"               
## [9] "SpatialVector"
```


```r
is(ge2)
```

```
##  [1] "MoveStack"              ".MoveTrackStack"       
##  [3] ".MoveGeneral"           ".MoveTrack"            
##  [5] ".unUsedRecordsStack"    "SpatialPointsDataFrame"
##  [7] ".unUsedRecords"         "SpatialPoints"         
##  [9] "Spatial"                "SpatialVector"
```

The second one is a "Stack" of three eagles

### Processing data

The central function is  `processMovedata`, which simlpifies a Movebank object to a simpler structure: 'id', 'time', 'lon', 'lat', 'x' and 'y' (UTM locations).   The output is a `movetrack` object:


```r
ge1.simple <- processMovedata(ge1, idcolumn = "deployment_id")
ge2.simple <- processMovedata(ge2, idcolumn = "deployment_id")
head(ge1.simple)
```

```
##          id day            day.date                time       lon      lat
## 1 171299043 278 2003-10-06 12:00:00 2003-10-06 15:29:54 -106.3055 34.36525
## 2 171299043 280 2003-10-08 12:00:00 2003-10-08 23:44:41 -105.9220 31.71000
## 3 171299043 281 2003-10-09 12:00:00 2003-10-09 01:35:52 -105.8807 31.70867
## 4 171299043 283 2003-10-11 12:00:00 2003-10-11 04:49:55 -106.3147 30.90686
## 5 171299043 285 2003-10-13 12:00:00 2003-10-13 12:49:15 -106.5515 29.09225
## 6 171299043 287 2003-10-15 12:00:00 2003-10-15 17:48:17 -106.5428 27.53000
##           x         y
## 1 -1.855381 0.5997868
## 2 -1.848688 0.5534439
## 3 -1.847966 0.5534206
## 4 -1.855542 0.5394264
## 5 -1.859674 0.5077555
## 6 -1.859523 0.4804891
```

Compare:

```r
summary(ge1.simple)
```

```
##          id   n               start duration   dt.median
## 1 171299043 165 2003-10-06 15:29:54 390 days 57.09 hours
```

```r
summary(ge2.simple)
```

```
##          id   n               start duration    dt.median
## 1 196430584 138 1993-01-07 21:58:39 217 days  37.97 hours
## 2 196430597  94 1994-01-27 22:40:46 105 days  27.10 hours
## 3 196430599  56 1995-12-10 02:32:49 338 days 147.29 hours
```

The `x` and `y` are UTM coordinates - you can either provide a `proj4` projection string, it will take it from the orginal data or it will pick the UTM zone of the midpoint. 

A plotting function and a mapping function are worth checking out:


```r
plot(ge1.simple)
map.track(ge2.simple, zoom = 3)
```

### Migration analysis

*Examples to come*


