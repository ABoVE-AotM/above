#######################
## Class Definitions ##
#######################
#setClassUnion(".OptionalCHAR", c("character","NA"))
#setClassUnion(".OptionalDF", c("data.frame","NULL"))
#setClassUnion(".OptionalPOSIXct", c("POSIXct","NA"))
setClassUnion(".OptionalMove", c("Move","MoveStack","data.frame"))
setClassUnion(".OptionalCHAR", c("character","missing"))
setClassUnion(".OptionalLogical", c("logical","missing"))
#setOldClass(c('data.frame'))

setClass(Class = "trackSPDF", contains=c("SpatialPointsDataFrame"),
         representation = representation(
           VT = 'data.frame',
           dateDownloaded = "POSIXct",
           movebank_study = "character",
           movebank_citation = "character",
           movebank_license = "character"),
         prototype = prototype(
           VT = NULL,
           dateDownloaded = as.POSIXct(NA),
           movebank_study = NA_character_,
           movebank_citation = NA_character_,
           movebank_license = NA_character_),
         validity = function(object){
           return(TRUE)
         }
)

#setClass(Class = "track", contains=c("data.frame"),
#         representation = representation(),
#         prototype = prototype(),
#         validity = function(object){
#           return(TRUE)
#         }
#)

#setMethod("[", "track", function(x, i, j, ..., drop = TRUE) {
#  S3Part(x) <- callNextMethod()
#  return(x) })
