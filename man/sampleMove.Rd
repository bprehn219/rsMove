% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sampleMove.R
\name{sampleMove}
\alias{sampleMove}
\title{sampleMove}
\usage{
sampleMove(xy = xy, ot = ot, error = error, method = "m",
  tUnit = NULL)
}
\arguments{
\item{xy}{Object of class \emph{SpatialPoints} or \emph{SpatialPointsDataFrame}.}

\item{ot}{Object of class \emph{Date}, \emph{POSIXlt} or \emph{POSIXct} with the same length as \emph{xy}.}

\item{error}{Distance (in meters).}

\item{method}{How should the disntance be estimated? One of 'm' or 'deg'. Default is 'm'.}

\item{tUnit}{Time unit to estimate elapsed time. See \code{\link[base]{difftime}} for keywords. Default is \emph{mins}.}
}
\value{
A \emph{SpatialPointsDataFrame}.
}
\description{
Sampling of possible stops along a movement track.
}
\details{
{This function offers a simple approach to sample from locati where an animal showed little or no movement 
based on GPS tracking data. It looks at the distance among consecutive samples (\emph{error}) and estimates mean coordinates 
for the temporal segments where the animal moved less than the defined distance from the first location of the segment. 
The user should selected \emph{method} in accordance with the projection system associated to the data. If 'm' it estimates 
the ecludian distance. If 'deg' it uses the haversine formula. The output reports on the mean sample coordinates for 
the sample locations ('x' and 'y'), the total time spent per sample ('time' expressed in minutes) and the total number 
of observations per sample ('count').}
}
\examples{
\dontrun{

 # reference data
 moveData <- shapefile(system.file('extdata', 'latLon_example.shp', package="rsMove"))

 # sampling without reference grid
 ot = strptime(moveData$timestamp, "\%Y-\%m-\%d \%H:\%M:\%S")
 output <- sampleMove(xy=moveData, ot=ot, error=10, method='deg')
 
 # compare original vs new samples
 plot(moveData, col="black", pch=16)
 points(output$x, output$y, col="red", pch=15)
 
}
}