### The `above` R package
#### authors: Elie Gurarie and collaborators




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


```
## Warning in readChar(con, 5L, useBytes = TRUE): cannot open compressed file
## './hidden/movebanklogin.rda', probable reason 'No such file or directory'
```

```
## Error in readChar(con, 5L, useBytes = TRUE): cannot open the connection
```

Load a few datasets:


```r
ge1 <- getMovebankData(study="ABoVE: HawkWatch International Golden Eagles", animalName="37307a", login=login) 
ge2 <- getMovebankData(study="Aquila chrysaetos interior west N. America, Craigs, Fuller", animalName="629-26704", login=login) 
```


```
## Warning in readChar(con, 5L, useBytes = TRUE): cannot open compressed file
## './hidden/eagles.rda', probable reason 'No such file or directory'
```

```
## Error in readChar(con, 5L, useBytes = TRUE): cannot open the connection
```


These are `Move` objects, but they're slightly different:

```r
is(ge1)
```

```
## Error in is(ge1): object 'ge1' not found
```

```r
is(ge2)
```

```
## Error in is(ge2): object 'ge2' not found
```



#### Processing data

For migration analysis we simplify (and get daily averages) using the `processMovedata` function, which reduces the data to daily average locations (in latitude, longited and x and y):


```r
ge1.simple <- processMovedata(ge1, idcolumn = "deployment_id")
```

```
## Error in inherits(movedata, "Move"): object 'ge1' not found
```

```r
head(ge1.simple)
```

```
## Error in head(ge1.simple): object 'ge1.simple' not found
```

This is a `movebank` object, which has some convenient methods:


```r
summary(ge1.simple)
```

```
## Error in summary(ge1.simple): object 'ge1.simple' not found
```


Note that `x` and `y` are UTM coordinates - you can either provide a `proj4` projection string or, by default, it will pick the zone of the midpoint. 

The plotting function is similar to the `scan.track` function in `marcher`


```r
plot(ge1.simple)
```

For the second data set (`ge2`) there are three deployments of 1 eagle, each with a unique identifier. 


```r
ge2.simple <- processMovedata(ge2, idcolumn = "deployment_id")
```

```
## Error in inherits(movedata, "Move"): object 'ge2' not found
```

```r
summary(ge2.simple)
```

```
## Error in summary(ge2.simple): object 'ge2.simple' not found
```

And we see a simple straight one-time migration in these data. 

#### Migration analysis

*Examples to come*


