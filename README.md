# Isotopic tracing of storm-water in the urban Liesbeek River

*Ruan van Mazijk[1], Lucy K. Smyth[1,2], Eleanor A. Weideman[1,3] and Adam G. West[1,§]*

- [1]: Department of Biological Sciences, University of Cape Town, Rondebosch, South Africa
- [2]: Institute for Communities and Wildlife in Africa (iCWild), University of Cape Town, Rondebosch, South Africa
- [3]: Fitzpatrick Institute of African Ornithology, University of Cape Town, Rondebosch, South Africa
- [§]: Corresponding author: adam.west@uct.ac.za , +27 21 650 3628

![](logos/UCT-logo.png) ![](logos/BIO-logo.png) ![](logos/ICWild-logo.jpg) ![](logos/FitzPatrick-logo.png)

This is an open access repository for data-sets and analyses for publication in review in *Water SA*

## How to replicate our results

In R, run each of the R-scripts (in `analyses/`).

These scripts automatically call on `setup.R`, to install all the required packages (with [`pacman`](https://cran.r-project.org/web/packages/pacman/vignettes/Introduction_to_pacman.html)), define our own functions, and load all our data as needed.

Figures should appear in the working directory, while other outputs appear on the console.

Note, `uncertainty-propagation.Rmd` is an [R Markdown](https://rmarkdown.rstudio.com/) document. Open this in Studio, and use the "knit" button to generate the HTML report showing the arithmetic behind the propagation of analytical uncertainty in our mass-balance model determination of rainfall contribution to Liesbeek River storm-flow. You can also see this documentation [here](https://rvanmazijk.github.io/Liesbeek-River-isotopics/analyses/uncertainty-propagation.html).
