### The  `above` R pacakge
#### authors: Elie Gurarie and collaborators

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, cache=TRUE)
```

This R package will collaboratively help participants of the Animals on the Move subproject of the Arctic Boreal Vulnerability Experiment (above) share code for analysis of animal movements and migrations. 

For now, it contains: 

1. preprocesseing [movebank.org]() functions to get daily means
2. functions for multi-migration analysis

Example below:


### Install package

From GitHub, you need to install first the [`marcher`](https://github.com/EliGurarie/marcher) package, then this package:

```{r, eval = FALSE}
require(devtools)
install_github("EliGurarie/marcher")
install_github("EliGurarie/above")
```

```{r, echo = FALSE, message=FALSE, warning=FALSE}
require(above)
```


### Loading eagle data

ABoVE members with access to some golden eagle data can load it using 

```{r, eval = FALSE}
login <- movebankLogin(username = "somethingsecret", password = "somethingsecret")
```

```{r, echo = FALSE}
load(file ="./hidden/movebanklogin.rda")
```

Load a few datasets:

```{r, eval = FALSE}
ge1 <- getMovebankData(study="ABoVE: HawkWatch International Golden Eagles", animalName="37307a", login=login) 
ge2 <- getMovebankData(study="Aquila chrysaetos interior west N. America, Craigs, Fuller", animalName="629-26704", login=login) 
```

```{r, echo = FALSE}
load("./hidden/eagles.rda")
```


These are `Move` objects, but they're slightly different:
```{r}
is(ge1)
is(ge2)
```

### Processing data

For migration analysis we simplify (and get daily averages) using the `processMovedata` function, which reduces the data to daily average locations (in latitude, longited and x and y):

```{r}
ge1.simple <- processMovedata(ge1, idcolumn = "deployment_id")
head(ge1.simple)
```

Note that `x` and `y` are UTM coordinates - you can either provide a `proj4` projection string or, by default, it will pick the zone of the midpoint. 

A `scan.track` (from `marcher`):

```{r, eval = FALSE, fig.height = 3}
with(ge1.simple, scan.track(time = time, x = x, y = y))
```


For the second data set (`ge2`) there are three eagles and a different unique identifier. 

```{r}
ge2.simple <- processMovedata(ge2, idcolumn = "deployment_id")
head(ge2.simple)
table(ge2.simple$id)
```

We can `scan.track` the first one:

```{r, eval = FALSE}
with(subset(ge2.simple, id == "196430584"), scan.track(x = x, y = y, time = time))
```

And we see a simple straight one-time migration in these data. 

### Migration analysis

*Examples to come*


```{r Render, echo =FALSE,  eval=FALSE, include = FALSE}
render("README.rmd", output_dir = "./hidden", intermediates_dir = ".", clean = FALSE)
shell("move README.knit.md README.md")
```

