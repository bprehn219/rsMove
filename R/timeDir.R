#' @title timeDir
#'
#' @description Analysis of environmental change in time for a set of coordinate pairs.
#' @param xy Object of class "SpatialPoints" or "SpatialPointsDataFrame".
#' @param obs.dates Object of class \emph{Date} with \emph{xy} observation dates.
#' @param img Object of class
#' @param env.data Object of class \emph{RasterStack} or \emph{RasterBrick} or \emph{data.frame}.
#' @param env.dates Object of class \emph{Date} with \emph{env.data} observation dates.
#' @param temporal.buffer two element vector with temporal window size (expressed in days).
#' @param stat.fun Output statistical metric.
#' @param min.count Minimum number of samples required by \emph{stat.fun}. Default is 2.
#' @importFrom raster crs extract
#' @importFrom stats lm
#' @importFrom grDevices colorRampPalette
#' @importFrom ggplot2 ggplot geom_point theme guides scale_fill_gradientn scale_size_continuous ylab xlab
#' @seealso \code{\link{spaceDir}} \code{\link{dataQuery}} \code{\link{imgInt}}
#' @return A \emph{vector} with a requested statistical metric for each point in \emph{xy}.
#' @details {This function evaluates how environmental conditions change in time along a movement track.
#' First, for each point in \emph{xy}, the function compares its observation date (\emph{obs.dates}) against
#' the acquisition dates (\emph{env.dates}) of \emph{env.data} to select non \emph{NA} timesteps within a
#' predefined temporal window (\emph{temporal.buffer}). The user can adjust this window to determine which
#' images are the most important. For example, if one wishes to know how the landscape evolved up to the
#' observation date of the target sample and daily satellite data is available, \emph{temporal.buffer} can be
#' define as, e.g., c(30,0) forcing the function to use all images to only use pixels recorded within the previous
#' 30 days. After selecting adequate temporal information for each data point, a statistical metric is estimated.
#' The statistical metric is provided by (\emph{stat.fun}). By default, the slope is reported from a linear regression
#' between the acquisition times of \emph{env.data} and their corresponding values. When providing a new function, set x
#' for \emph{env.dates} and y for \emph{env.data}.}
#' @examples {
#'
#'  require(raster)
#'
#'  # read raster data
#'  file <- list.files(system.file('extdata', '', package="rsMove"), 'ndvi.tif', full.names=TRUE)
#'  r.stk <- stack(file)
#'  r.stk <- stack(r.stk, r.stk, r.stk) # dummy files for the example
#'
#'  # read movement data
#'  data(shortMove)
#'
#'  # raster dates
#'  r.dates <- seq.Date(as.Date("2013-08-01"), as.Date("2013-08-09"), 1)
#'
#'  # sample dates
#'  obs.dates <- as.Date(shortMove@data$date)
#'
#'  # perform directional sampling
#'  of <- function(x,y) {lm(y~x)$coefficients[2]}
#'  time.env <- timeDir(xy=shortMove, obs.dates=obs.dates, env.data=r.stk,
#'  env.dates=r.dates, temporal.buffer=c(30,30), stat.fun=of)
#'
#' }
#' @export

#-------------------------------------------------------------------------------------------------------------------------------#

timeDir <- function(xy=NULL, obs.dates=obs.dates, img=NULL, env.data=NULL, env.dates=env.dates, temporal.buffer=temporal.buffer, stat.fun=NULL, min.count=2) {

#-------------------------------------------------------------------------------------------------------------------------------#
# 1. check variables
#-------------------------------------------------------------------------------------------------------------------------------#

  # samples
  if (!is.null(xy)) {if (!class(xy)%in%c('SpatialPoints', 'SpatialPointsDataFrame')) {stop('"xy" is not of a valid class')}}

  # sample dates
  if (!exists('obs.dates')) {stop('"obs.dates" is missing')}
  if (class(obs.dates)[1]!='Date') {stop('"obs.dates" is nof of a valid class')}
  if (length(obs.dates)!=length(xy)) {stop('"xy" and "obs.dates" have different lengths')}

  # environmental data dates
  if (class(env.dates)[1]!='Date') {stop('"env.dates" is nof of a valid class')}

  # environmental data
  if (!class(env.data)[1]%in%c("RasterStack", "RasterBrick", "data.frame")) {stop('"env.data" is not of a valid class')}
  if (class(env.data)[1]%in%c("RasterStack", "RasterBrick")) {
    if (is.null(xy)) {stop('"env.data" is a raster object. Please define "xy"')}
    if (crs(xy)@projargs!=crs(env.data)@projargs) {stop('"xy" and "env.data" have different projections')}
    if (length(env.dates)!=nlayers(env.data)) {stop('"env.data" and "env.dates" have different lengths')}}
  if (class(env.data)[1]=='data.frame') {if (length(env.dates)!=ncol(env.data)) {stop('"env.data" and "env.dates" have different lengths')}}

  # time information
  if (!is.numeric(temporal.buffer)) {stop('"temporal.buffer" us not numeric')}
  if (length(temporal.buffer)!=2) {stop('"temporal.buffer" does not have two elements')}

  # check/define input metrics
  if (is.null(stat.fun)) {stat.fun <- function(x,y) {lm(y~x)$coefficients[2]}} else {
    if(!is.function(stat.fun)) {stop('"stat.fun" is not a valid function')}}

#-------------------------------------------------------------------------------------------------------------------------------#
# 2. retrieve environmental data
#-------------------------------------------------------------------------------------------------------------------------------#

  if (!is.data.frame(env.data)) {

    # retrieve environmental variables
    ind <- which(env.dates%in%seq.Date(min(obs.dates-temporal.buffer[1]), max(obs.dates+temporal.buffer[2]), by=1))
    env.data <- extract(env.data[[ind]], xy@coords)
    env.dates <- env.dates[ind]

  }

#-------------------------------------------------------------------------------------------------------------------------------#
# 3. apply sampling approach
#-------------------------------------------------------------------------------------------------------------------------------#

  f <- function(i) {
    ind <- which(env.dates >= (obs.dates[i]-temporal.buffer[1]) & env.dates <= (obs.dates[i]+temporal.buffer[2]))
    x <- as.numeric(env.dates[ind])
    y <- env.data[i,]
    u <- !is.na(y)
    if (sum(u) >= min.count) {return(stat.fun(x[u],y[u]))} else {return(NA)}}

#-------------------------------------------------------------------------------------------------------------------------------#
# 4. query samples
#-------------------------------------------------------------------------------------------------------------------------------#

  df <- data.frame(value=unlist(lapply(1:nrow(env.data), f)))

#-------------------------------------------------------------------------------------------------------------------------------#
# 5. build plot
#-------------------------------------------------------------------------------------------------------------------------------#

  # build plot object
  if (!is.null(xy)) {
    cr <- colorRampPalette(c("dodgerblue3", "khaki2", "forestgreen"))
    df0 <- data.frame(x=xy@coords[,1], y=xy@coords[,2], value=df$value)
    p <- ggplot(df0) + theme_bw() + xlab('X') + ylab('Y') +
      geom_point(aes_string(x="x", y="y", size="value", fill="value"), color="black", pch=21) +
      scale_size_continuous(guide=FALSE) + guides(col=cr(10)) +
      scale_fill_gradientn(colours=cr(10)) +
      theme(legend.text=element_text(size=10), panel.grid.major=element_blank(),
            panel.grid.minor=element_blank())
    return(list(stats=df, plot=p))} else {return(list(stats=df))}

}
