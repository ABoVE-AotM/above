#### To-Do:

-   Include simulated data for quick loading and examples
-   Improve multimigration (EG)
-   Add step-selection functions (PM)
-   Annotation code

#### Background

This R package will collaboratively help participants of the Animals on
the Move subproject of the Arctic Boreal Vulnerability Experiment
(above) share code for analysis of animal movements and migrations.

For now, it contains:

1.  preprocesseing [movebank.org]() functions to get daily means
2.  some convenient methods (`summary`, `plot`, `map.track`) to work
    with movetrack’s
3.  functions for multi-migration analysis

#### Install package

    require(devtools)
    install_github("ABoVE-AotM/above")

#### Loading eagle data

ABoVE members with access to some golden eagle data can load it using

    login <- movebankLogin(username = "somethingsecret", password = "somethingsecret")

Load a few datasets:

    ge1 <- getMovebankData(study="ABoVE: HawkWatch International Golden Eagles", animalName="37307a", login=login)
    ge2 <- getMovebankData(study="Aquila chrysaetos interior west N. America, Craigs, Fuller", animalName="629-26704", login=login) 

These are `Move` objects, but they’re slightly different:

    is(ge1)

    ##  [1] "Move"                   ".MoveTrackSingle"      
    ##  [3] ".MoveGeneral"           ".OptionalMove"         
    ##  [5] ".MoveTrack"             ".unUsedRecords"        
    ##  [7] "SpatialPointsDataFrame" "SpatialPoints"         
    ##  [9] "Spatial"                "SpatialVector"

    is(ge2)

    ##  [1] "Move"                   ".MoveTrackSingle"      
    ##  [3] ".MoveGeneral"           ".OptionalMove"         
    ##  [5] ".MoveTrack"             ".unUsedRecords"        
    ##  [7] "SpatialPointsDataFrame" "SpatialPoints"         
    ##  [9] "Spatial"                "SpatialVector"

#### Processing data

For migration analysis we simplify (and get daily averages) using the
`processMovedata` function, which reduces the data to daily average
locations (in latitude, longited and x and y):

    ge1.simple <- processMovedata(ge1, idcolumn = "deployment_id")

    ## Warning in processMovedata(ge1, idcolumn = "deployment_id"): Transforming
    ## LonLat into Canadian Lambert Conformal Conic for units in meters.

    head(ge1.simple)

    ##          id                time      lon    lat        x         y
    ## 1 171299043 2003-10-06 04:45:00 -106.411 34.704 -1019430 -540165.1
    ## 2 171299043 2003-10-06 17:44:53 -106.473 34.644 -1026582 -546256.7
    ## 3 171299043 2003-10-06 19:25:04 -106.227 34.215 -1010585 -600598.5
    ## 4 171299043 2003-10-06 20:04:42 -106.111 33.898 -1005013 -639820.1
    ## 5 171299043 2003-10-08 23:44:41 -105.922 31.710 -1025980 -903409.4
    ## 6 171299043 2003-10-09 00:49:38 -105.888 31.705 -1022582 -904538.8

This is a `track` object (specific for this package), which has some
convenient methods:

    summary(ge1.simple)

    ## study: ABoVE: HawkWatch International Golden Eagles
    ## projection: +proj=lcc +lat_1=50 +lat_2=70 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs
    ## dateDownloaded: 2019-07-01 18:22:15
    ## citation: Portions of these data are represented in Goodrich LJ and Smith JP (2008) Raptor migration in North America. In Bildstein KL, Smith JP, Ruelas Inzunza E, and Veit RR (eds) State of North America’s Birds of Prey. Series in Ornithology 3. Nuttall Ornithological Club, Cambridge, MA, and American Ornithologist’s Union, Washington, DC.  Smith JP (2010) Raptor migration dynamics in New Mexico. In Cartron J-L E (ed) Raptors of New Mexico. University of New Mexico Press, Albuquerque, NM. p 29-67.  Smith JP, Vekasy M, Gross HP (2001) HawkWatch International expands Western Migratory Raptor Satellite Telemetry Project. North American Bird Bander 26(4): 199-200.  These publications are available as file attachments in this study.
    ## license: Anyone is free to examine these data. This is a version of data in the study "HawkWatch International Raptor Migration Study" intended for use as part of NASA's Arctic-Boreal Vulnerability Experiment (ABoVE).
    ## dailymean: FALSE

    ##          id    n               start duration  dt.median
    ## 1 171299043 1002 2003-10-06 04:45:00 391 days 9.37 hours

Note that `x` and `y` are UTM coordinates - you can either provide a
`proj4` projection string or, by default, it will pick the zone of the
midpoint.

The plotting function is similar to the `scan.track` function in
`marcher`

    plot(ge1.simple)

    ## png 
    ##   2

![](%22c:/eli/sandbox/plots/ge1.png%22)

For the second data set (`ge2`) there are three deployments of 1 eagle,
each with a unique identifier.

    ge2.simple <- processMovedata(ge2, idcolumn = "deployment_id")

    ## Warning in processMovedata(ge2, idcolumn = "deployment_id"): Transforming
    ## LonLat into Canadian Lambert Conformal Conic for units in meters.

    summary(ge2.simple)

    ## study: Aquila chrysaetos interior west N. America, Craigs, Fuller
    ## projection: +proj=lcc +lat_1=50 +lat_2=70 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs
    ## dateDownloaded: 2019-07-01 18:22:15
    ## citation: Craig EG, Craig TH (1998) Lead and mercury levels in golden and bald eagles and annual movements of golden eagles wintering in east central Idaho 1990–1997. Idaho Bureau of Land Management Technical Bulletin No. 98-12. http://www.blm.gov/style/medialib/blm/id/publications/technical_bulletins.Par.18405.File.dat/TB_98-12.pdf <br> <br> Craig EH, Craig TH, Huettmann F, Fuller MR (2008) Use of machine learning algorithms to predict the incidence of lead exposure in golden eagles in Watson RT, Fuller M, Pokras M, Hunt WG (eds) Ingestion of lead from spend ammunition: implications for wildlife and humans. The Peregrine Fund, Boise, Idaho, USA. doi:10.4080/ilsa.2009.0303. http://www.peregrinefund.org/subsites/conference-lead/PDF/0303%20Craig.pdf
    ## license: NA
    ## dailymean: FALSE

    ##          id   n               start duration   dt.median
    ## 1 196430584 247 1993-01-07 21:58:39 217 days 21.15 hours
    ## 2 196430597 276 1994-01-27 22:40:46 105 days  9.17 hours
    ## 3 196430599  98 1995-12-10 02:32:49 338 days 83.52 hours

And we see a simple straight one-time migration in these data.

    plot(subset(ge2.simple, id == "196430584"))

    ## png 
    ##   2

![](%22c:/eli/sandbox/plots/ge2.png%22)

#### Migration analysis

*Examples to come*
