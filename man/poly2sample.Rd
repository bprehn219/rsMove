% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/poly2sample.R
\name{poly2sample}
\alias{poly2sample}
\title{poly2sample}
\usage{
poly2sample(pol.shp = pol.shp, ref.ext = ref.ext, min.cover = NULL,
  pixel.res = NULL)
}
\arguments{
\item{pol.shp}{Object of class \emph{SpatialPolygons} or \emph{SpatialPolygonDataFrame}.}

\item{ref.ext}{Object of class \emph{Extent} or a \emph{RasterLayer} from which an extent can be derived.}

\item{min.cover}{Minimum percent a pixel should be covered by a polygon for sampling (0-100). Default is 100.}

\item{pixel.res}{Pixel resolution. Required if \emph{ref.ext} is an \emph{Extent} object. Unit depends on spatial projection.}
}
\value{
A \emph{SpatialPointsDataFrame} with sampled pixels reporting on polygon percent coverage.
}
\description{
{Converts a raster grid to points depending on how much each pixel is covered by a polygon.}
}
\details{
{\emph{poly2Sample} extends on the \code{\link[raster]{rasterize}} function from the raster package making it more efficient
over large areas and converting its output into point samples rather than a raster object. For each polygon in (\emph{"pol.shp"}),
\emph{poly2sample} extracts the overlapping pixels derived from \emph{ref.ext}. Then, for each pixel, the function estimates the
percentage of it that is covered by the reference polygon. Finally, the function extracts coordinate pairs for pixels that has a
percent coverage equal to or greater than \emph{min.cover}.}
}
\examples{
{

 require(raster)

 # load example probability image
 file <- system.file('extdata', 'konstanz_probabilities.tif', package="rsMove")
 img <- raster(file)

 # load area of interest
 file <- system.file('extdata', 'konstanz_roi.shp', package="rsMove")
 roi <- shapefile(file)

 # segment probabilities
 samples <- poly2sample(pol.shp=roi, ref.ext=img)

}
}
\seealso{
\code{\link{dataQuery}} \code{\link{imgInt}}
}
