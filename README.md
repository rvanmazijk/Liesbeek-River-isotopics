# Isotopic tracing of storm-water in the urban Liesbeek River

*Ruan van Mazijk, Lucy K. Smyth, Eleanor A. Weideman and Adam G. West*

*Department of Biological Sciences, University of Cape Town, Rondebosch, South Africa*

Corresponding author: <adam.west@uct.ac.za>, +27 21 650 3628

![](logos/UCT-logo.png) ![](logos/BIO-logo.png)

This is an open access repository for data-sets and analyses for publication in review, to be in *Water SA*

# How to replicate our results

In R, run each of the R-scripts in `analyses/` in the order numbered. The first few scripts call on `setup.R`, to install all the required packages (with [`pacman`](https://cran.r-project.org/web/packages/pacman/vignettes/Introduction_to_pacman.html)) and load-in all our data.

The figures should appear in `figures/`. Outputs for the Bayesian SIMM, the residuals vs time regressions, and the total storm-flow estimate should appear on the console.

Like so:

```r
source("analyses/01_make-fig-1.R")
source("analyses/02_make-fig-2.R")
...
```

And so forth.
