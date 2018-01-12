<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/kcha/psiplot.svg?branch=master)](https://travis-ci.org/kcha/psiplot)

psiplot
=======

psiplot is an R package for generating plots of percent spliced-in (PSI) values of alternatively-spliced exons that were computed by [vast-tools](https://github.com/vastgroup/vast-tools), an RNA-Seq pipeline for alternative splicing analysis. The plots are generated using `ggplot2`.

For a demo of psiplot, take a look at the companion Shiny app: <http://kcha.shinyapps.io/psiplotter-app>.

Installation
------------

See [Releases](https://github.com/kcha/psiplot/releases) for the latest stable release or get the most up-to-date development version via devtools:

``` r
if (!require("devtools")) install.packages("devtools")
devtools::install_github("kcha/psiplot")
```

Usage
-----

### Input

psiplot takes as input the PSI and/or cRPKM results generated by vast-tools (e.g. after running `vast-tools combine` or `vast-tools diff`). For example,

``` r
psi <- read.table("INCLUSION_LEVELS_FULL-Mmu53.tab", header = TRUE, sep = "\t",
                  stringsAsFactors = FALSE)
crpkm <- read.table("cRPKM-Mmu53.tab", header = TRUE, sep = "\t",
                    stringsAsFactors = FALSE)
```

This README uses the provided sample datasets, `psi` and `crpkm`, as example input data.

### Plotting

Events can be plotted individually as a scatterplot (a.k.a "psiplots") or collectively as a heatmap.

#### Individual events

The function `plot_event()` generates a plot of a single event:

``` r
library(psiplot)

# Plot an event using provided sample dataset
plot_event(psi[1,])

# Alternatively, to plot an event by gene name (for example, TSPAN6):
plot_event(psi[psi$GENE == "TSPAN6",])
```

![plot](https://raw.githubusercontent.com/vastgroup/vast-tools/master/R/sample_data/PsiExample.png "Example")

In addition, cRPKM expression values generated by vast-tools can also be plotted in a similar manner using the function `plot_expr()`:

``` r
# Using sample dataset
plot_expr(crpkm[1,])

# Alternatively
plot_expr(crpkm[crpkm$NAME == "TSPAN6",])
```

#### Multiple events

The function `plot_multi` generates a heatmap of multiple events (*this is currently an experimental feature and not fully tested*). If you have the R package `gplots` installed (optional; need to install manually if desired), `plot_multi` will use `heatmap.2` to perform hierarchical clustering and generate a heatmap. Otherwise, it will use `ggplot2::geom_tile` to produce the heatmap.

``` r
plot_multi(psi)

# For cRPKM, use expr = TRUE
plot_multi(crpkm, expr = TRUE)

# To disable clustering of events
plot_multi(psi, cluster_rows = FALSE)

# To disable clustering of samples
plot_multi(psi, cluster_cols = FALSE)

# To generate a ggplot2-based heatmap (default if gplots is not installed)
plot_multi(psi, usepkg = "ggplot2")
```

### Customizing plots

There are two ways to customize the plots: using a configuration file or using R arguments.

#### The `.config` file way

In `vast-tools plot`, an optional config file can be used to customize the plots' visual appearance. The same config file can be supplied here as well.

``` r
plot_event(psi[1,], config = "/path/to/config")

# config can also be pre-loaded into a data frame
cfg <- read.table("/path/to/config", header = TRUE, sep = "\t", stringsAsFactor = FALSE)
plot_event(psi[1,], config = cfg)
plot_multi(psi, config = cfg)
plot_expr(crpkm[1,], config = cfg)
```

The color and ordering of samples can be customized by supplying a plot configuration file. This file is tab-delimited and must be manually created. For example:

``` r
# sample config data
config
#>   Order SampleName GroupName RColorCode
#> 1     1    Sample4    Neural    #ff0000
#> 2     2    Sample3    Neural        red
#> 3     3    Sample2    Muscle       blue
#> 4     4    Sample1    Muscle    #0000ff
```

-   **Order**: The ordering of the samples from left to right.
-   **SampleName**: Name of the sample. MUST match sample name in input table.
-   **GroupName**: Group name. Use for plotting the average PSI of samples belonging to the same group (enable by setting `groupmean=TRUE`)
-   **RColorCode**: An R color specification:
    1.  color name (as specified by `colors()`)
    2.  hex color code (\#rrggbb)

Tips:

-   The samples under SampleName MUST MATCH the names in the input table. Only the samples listed in the config file will be represented in the resulting plots. Other samples in the input table but not in the config file will be ignored. This may be useful for plotting only a subset of samples.
-   The column **Order** does not need to be in sorted order. Thus, you can change the ordering of your samples by simply changing the order number.
-   For `plot_multi`, specifying a config file will disable clustering of samples and instead use the config order.

#### The R way

The colors and other graphical parameters can also be configured in R via arguments. `plot_events()` and `plot_expr()` provides a limited set of arguments and can be used in conjunction with a config file. See `?plot_events` and `?plot_expr` for more details on the available options.

For example, the following command uses the configuration settings, sets the point symbol, and restricts the y-axis to (20, 80):

``` r
plot_event(psi[1,], config = config, pch = 9, ylim = c(20, 80))
```

Because the `plot_*` methods return ggplot2 objects, you can further customize the plots by appending additional aesthetics or themes (if the option is not supported within the method itself). Certain options may interfere or overwite those already set within the `plot_*` methods, so please use at your discretion. For example, to increase the text size of the legend:

``` r
plot_event(psi[1,], config = config) + theme(legend.text = element_text(size = 20))
```

Issues
------

Please report all bugs and issues using the [issue tracker](https://github.com/kcha/psiplot/issues).

Related Projects
----------------

-   [vast-tools](https://github.com/vastgroup/vast-tools)
-   [psiplotter-app](https://github.com/kcha/psiplotter-app): A companion Shiny app for visualizing PSI plots based on this package

Acknowledgements
----------------

-   Manuel Irimia
-   Nuno Barbosa-Morais
-   Tim Sterne-Weiler

Citation
--------

Tapial, J., Ha, K.C.H., Sterne-Weiler, T., Gohr, A., Braunschweig, U., Hermoso-Pulido, A., Quesnel-Vallières, M., Permanyer, J., Sodaei, R., Marquez, Y., Cozzuto, L., Wang, X., Gómez-Velázquez, M., Rayón, M., Manzanares, M., Ponomarenko, J., Blencowe, B.J., Irimia, M. (2017). An Alternative Splicing Atlas Reveals New Regulatory Programs and Genes Simultaneously Expressing Multiple Major Isoforms in Vertebrates. Genome Res, 27(10):1759-1768
