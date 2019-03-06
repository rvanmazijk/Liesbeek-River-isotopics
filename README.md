# Isotopic tracing of stormwater in the urban Liesbeek River

Water SA 44(4):674-679. DOI: [10.4314/wsa.v44i4.16](http://dx.doi.org/10.4314/wsa.v44i4.16)

*Ruan van Mazijk[1], Lucy K. Smyth[1,2], Eleanor A. Weideman[1,3] and Adam G. West[1,§]*

- [1] Department of Biological Sciences, University of Cape Town, Rondebosch, South Africa
- [2] Institute for Communities and Wildlife in Africa (iCWild), University of Cape Town, Rondebosch, South Africa
- [3] FitzPatrick Institute of African Ornithology, University of Cape Town, Rondebosch, South Africa
- [§] Corresponding author: adam.west@uct.ac.za , +27 21 650 3628

<p>
  <img src="logos/UCT-logo.png"         height=100 />
  <img src="logos/BIO-logo.png"         height=100 />
  <img src="logos/ICWild-logo.jpg"      height100  />
  <img src="logos/FitzPatrick-logo.png" height=100 />
</p>

This is an open access repository for data-sets and analyses for publication in review in *Water SA*

## How to replicate our results

Clone this repository use `git` or a GitHub client, or download it as a `.zip` above.

Our results can be replicated either with the bash command-line-interface or in [RStudio](https://www.rstudio.com/products/RStudio/). After running the R-scripts, figures appear as TIFF-files in the working directory, while other outputs appear on the console.

Note, `uncertainty-propagation.Rmd` is an [R Markdown](https://rmarkdown.rstudio.com/) document, showing the arithmetic behind how we propagated analytical uncertainty in our mass-balance model (to determine rainfall contribution to Liesbeek River storm-flow). It is viewable [here](https://rvanmazijk.github.io/Liesbeek-River-isotopics/analyses/uncertainty-propagation.pdf).

### In RStudio

Open the R-project in RStudio. Before you can run the R-scripts in `analyses/`, you must install the correct versions of R-packages used in our analysis. This is made easy by [`packrat`](https://rstudio.github.io/packrat/), a version-controlled dependency manager for R-projects. To install the packages needed:

```r
packrat::restore()
```

Once this is done, you can run the R-scripts in `analyses/`. These scripts automatically call on `setup.R`, to install all the required packages (with [`pacman`](https://cran.r-project.org/web/packages/pacman/vignettes/Introduction_to_pacman.html)), define our own functions, and load all our data as needed.

### On the command line

Navigate to the project on the command line, substituting the appropriate path:

```sh
cd ~/mypath/Liesbeek-River-isotopics/
```

Before you can run the R-scripts in `analyses/`, you must install the correct versions of R-packages used in our analysis. This is made easy by [`packrat`](https://rstudio.github.io/packrat/), a version-controlled dependency manager for R-projects. To install the packages needed:

```sh
Rscript -e "packrat::restore()"
```

Once this is done, you can run the R-scripts in `analyses/`. These scripts automatically call on `setup.R`, to install all the required packages (with [`pacman`](https://cran.r-project.org/web/packages/pacman/vignettes/Introduction_to_pacman.html)), define our own functions, and load all our data as needed. For example:

```sh
Rscript analyses/make-fig-1.R
Rscript analyses/mass-balance.R
```

