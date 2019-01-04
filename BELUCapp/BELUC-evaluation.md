<!---
---
title: "Bayesian Estimation of Land-Use Change"
subtitle: "(UK-SCaPE 1.1)"
author:
- Van Oijen, M., Buys, G., Cameron, D., Griffin, A., Keith, A., Levy, P.
date: '2019-01-04'
output:
  pdf_document:
    fig_caption: yes
    keep_tex: no
    number_sections: yes
    toc: yes
  html_document: default
  word_document:
    reference_docx: word-styles-reference-01.docx
fontsize: 11pt
geometry: margin=1in
csl: environmental-modelling-and-software.csl
bibliography: BayesianLUC.bib
---
--->

# Introduction

This document provides an evaluation of the Bayesian approach to estimating  land-use change published by Levy et al. [-@levy_Estimation_2018]. The main purpose is to list assumptions and parameter settings whose importance can be tested by running the model calculations multiple times, each time varying one or more of the settings.

The different model runs can form the basis of a to-be-developed Shiny app whose purpose would be to make identification of the key model assumptions and parameter sensitivities easy.

# File locations

We use the shared project folder for UK-SCaPE Task 1.1 "Land Use Change Exemplar", subfolder "BELUC", where the following files can be found:

* This report in different formats (.rmd, .pdf, .doc, .html)
* A BibTeX-file with the references used in this report (.bib)
* Some additional files that R markdown uses for formatting (.csl, .doc)
* An annotated copy of the original Levy et al. paper (.pdf)

The model files themselves are located elsewhere.

# Terminology

We ignore semantic distinctions between "land use" and "land cover" for the moment.

| Acronym ||
|-|-|
| BELUC | Bayesian Estimation of Land-Use Change [@levy_Estimation_2018] |
| LU | Land Use (types 1..6) |
| LUC | Land-Use Change |

## Data sets

| Acronym ||
|-|-|
| AC | Agricultural Census |
| ALCM | Agricultural Land Capability Map |
| Corine | Corine satellite-based land cover information |
| CS | Countryside Survey |
| EAC | EDINA Agricultural Census |
| FC | FC new planting |
| IACS | Integrated Administration and Control System |
| LCM | CEH Land Cover Map |
| NFEW | FC National Forest Estate and Woodlands |

# The BELUC approach

The model is spatio-temporal. It estimates land cover on a fine rectangular grid (100 x 100 m), with annual time steps. 

In the paper, the approach is applied to the time period 1969-2016, 47 years long, so there are 46 opportunities for LUC in each grid cell. Six land cover types were  distinguished: 1. forest, 2. crop, 3. grassland, 4. rough grazing, 5. urban, 6. other.

The Bayesian calibration of the model proceeds in two steps:

1. Estimation of the non-spatial *LUC-parameters*, denoted as {$\beta_{ijt}$}, with $i=1..6, j=1..6, t=2..47, i\neq j$. These parameters quantify the total area of land that changes from LU=i in year t-1 to LU=j in year t. For each year, there are $6 \times 5 = 30$ different LUC-areas to be quantified, so the total number of LUC-parameters to be estimated for the whole time period is $30 \times 46 = 1380$.
2. For each year, allocation of the 30 estimated LUC-areas to different grid cells.

Only the first step is done in a truly Bayesian way, i.e. a prior probability distribution for the parameters is specified, as is a data-likelihood function, and then the posterior distribution for the parameters is derived (by application of Bayes' Theorem) as being proportional to prior and likelihood.

## Main model parameters to be estimated

| Parameter set | Dimension | Units of elements | Meaning |
|------------|--------------|---------|-----------------------------------------------------------|
| A = {$A_{ut}$} | 6 x 47 | m$^2$ | Total area in Scotland of LU-type u in year t |
| B = {$\beta_{ijt}$} | 6 x 6 x 46 | m$^2$ y$^{-1}$ | Total LUC from  LU=i in year t-1 to LU=j in year t |
| U = {$U_{xyt}$} | $n_x$ x $n_y$ x 47 | (1..6) | LU-type in grid cell (x,y) in year t |

## Details of step 1

Step 1 starts out with data from CS and then uses data from AC, Corine, EAC, IACS, NFEW. 

The prior for the 1380 $\beta$-parameters is based on linear interpolation of LUC-observations in consecutive CS. All $\beta$-parameters are a priori considered to be independent, so their joint prior probability distribution is simply the product of all 1380 marginal priors. The marginal priors are Gaussian distributions, and they all share the same standard deviation ($\sigma_{\beta}$), derived using bootstrapping from the CS-data [@scott_CS_2008; @wood_Longterm_2017].

Three likelihood functions are specified ($L_{net}, L_{gross}, L_B$) which use data from AC, EAC, and {Corine, IACS, NFEW} respectively. The three likelihood functions are multiplied to arrive at one overall likelihood function $L(\beta)$. In other words, the three (groups of) data sets are assumed to provide independent information.

The Bayesian calibration of the $\beta$-parameters is carried out by means of MCMC, which generates a representative sample from the posterior distribution for the parameters. To make the sampling tractable, this is done separately for the different years, i.e. 46 separate MCMCs are run. This allows for correlations between parameter estimates within individual years, but correlations between parameter estimates for different years are thereby ignored. The joint posterior distribution for all 1380 parameters is thus assumed to be the direct product of the 46 within-year posterior distributions.

## Details of step 2

Step 2 uses data from AC, ALCM, Corine, IACS, LCM, NFEW. The goal of this step is to allocate the annual LUC-areas (represented by the $\beta$-parameters for which we found a posterior distribution in Step 1) to different grid cells. Thereby, full 47-year long time series of LU are generated for each of the about eight million grid cells (of 100 x 100 m) in Scotland. In other words, Step 2 estimates about $47 \times 8.10^6 \approx 3.8 \times 10^8$ parameters.

The procedure is fairly complicated and involves making a large number of assumptions about the relative reliabilities of the different data sets. The procedure is probabilistic but not Bayesian (no priors, no likelihoods).

# Some questions from MvO *and some answers from PL*

* How do the FC and NFEW data sets differ from each other, and how are they used?
*The FC data is for gross afforestation on previously non-forest land, but is non-spatial; NFEW is spatial data on current forests.*
* Are the data indeed, as stated in the Abstract and at the end of the paper, "available in the widely used netCDF file format from http://eidc.ceh.ac.uk/", with "DOI pending"?
*Not yet but could be.*
* How were the MCMCs initialised? We state on p. 1501 that a least-squares fit of the $\beta$-values on the $\Delta A$ was carried out, but how? There are constraints on the beta's (non-negativity etc.), and there are six times as many $\beta$-parameters as there are $\Delta A$ observations. So fitting a linear model B=f($\Delta A$) is non-trivial.
* Which of the many $\sigma$ values are considered to be constant over time? Constancy would seem to be a sensible assumption if data acquisition methods do not change over time.
* In Step 2, why is the chance of misclassification ($W_{xy} \leftarrow p_m$) only applied to year t-1 and not to year t? And we are not concerned with overall misclassification but with misclassification regarding our land uses of interest (i resp. j). That specific misclassification probability should be ultra-small, perhaps < 0.01. But how should that be estimated properly? How was the 0.05 for the overall misclassification probability estimated?
* There were 1000 samples. Does that mean 1000 samples from $p_{post}(B)$? 
*Yes.*
And the semi-random spatial allocation procedure: was any representative sampling from that carried out as well?
*Yes, 1000 samples were used.*
* Could the general idea that temporal trends exist that lead to all kinds of correlations between consecutive or nearby years be accommodated by including penalty parameters that prevent overly strong fluctuations? The penalty parameters would embody, with uncertainty, our knowledge about the likely stability over time of different types of LU and LUC. It could for example be a Jeffreys' prior for interannual variability.
* In general, does the BELUC approach lead to correct estimation of spatial and temporal correlations in LUC? Neignbouring fields are likely to have similar LUC but this is not proscribed by the method.
* Is there a possible role for hierarchical modelling, e.g. to have hyperparameters for spatial and/or temporal patterns?
*Almost certainly.*
* Is there a possible role for quantifying model discrepancy as it was done in project MU-MAP?
* How can we test the accuracy of the model? Could we use independent datasets initially only for model testing, before incorporating those data in the procedure? Or use cross-validation? Expert judgment?
* How could we speed up computation without loss of accuracy?
*Parallelising on a per chain basis and by year (if these are done independently) is relatively straightforward.*
* How would we use computer memory most efficiently?
*Not a big issue I think.*

# Major assumptions and parameter settings

In this section, we discuss assumptions and parameter settings that may have a major influence on the model's outputs. Some of these were already mentioned in the short description of BELUC given above.

* How much do we overestimate uncertainty by running 46 separate annual MCMCs rather than just one for all years together?
* The prior for the $\beta$-parameters was derived by linear interpolation between consecutive CS, and uncertainty was based on bootstrapping.
    + This is two very strong assumptions in one. Between any two consecutive CS:
        1. every year has the same LUC (i.e. $\beta$-values do not change over time),
        2. there are no rotational (cyclic) changes.
    + Bootstrapping is a procedure that does not step "outside" of a data set, so it can by definition not account for any systematic errors shared by all data.
    + The same value of $\sigma_{\beta}$ is applied to each $\beta$-value to specify its marginal Guassian distribution. But surely some types of LUC are a priori much less unreliable than others? For example, some types of LUC are almost certainly always equal to zero (e.g. all transitions away from urban) and should therefore have a $\sigma$-value close to zero.
    + Gaussian distributions are not suitable anyway for non-negative variables (such as LUC): do we want to use other distributions such as the lognormal?
    + How representative are the CS grid cells? Note that we derive a prior for 1380 different types of LUC from the relatively small CS data set. Are there not many types of LUC that happen to be absent from (one or more of) the CS but do occur elsewhere in Scotland? Does that not skew the prior (and therefore the model results) to those LUC-types that happen to occur in the CS?
* The nine data sets are considered to be fully independent from each other.
    + This is likely incorrect, e.g. the LCM may have used CS-data, and EDINA will have used the Agricultural Census (as mentioned on p. 1500). Linkages between datasets will make it hard to specify the likelihood function. *They mostly are independent*
* $L_{net}$ (Eq. 5)
    + This is a likelihood for the AC-data, yet the equation defines a loop over all six LU-types. How is that done given that only two of the six LU-types are agricultural (2. crop, 3. grassland)?
*AC has forest, crop, grassland, and rough grazing*
    + What values were given to the $\sigma^{obs}_{ut}$ for u=1..6, and how certain are we of those values?
    + The equation assumes independence between LU-types but that is incorrect: e.g. years with high net afforestation should be years with high loss of rough grazing.
    + Also, consecutive years cannot be independent: an overestimate in any area value (A) for year t leads to overestimated LUC in year t-1 as well as year t.
* $L_{gross}$ (Eq. 6)
    + To what extent are cyclical changes (e.g. grass-crop-grass etc.) underestimated because of the coarse spatial resolution (2 x 2 km) of the AC-data?
    + How does the skewed normal distribution of Eq. (6) address that problem?
    + Was the $\alpha$ in Eq. (6) indeed calibrated (as suggested on p. 1501)? If not, what value was given to it, and how much uncertainty around that value should we accept?
    + What values were given to the $\sigma_{L^{obs}_{ut}}$ and $\sigma_{G^{obs}_{ut}}$ for u=1..6, and how certain are we of those values?
* $L_B$ (Eq. 7)
    + What values were given to the $\sigma_{\beta^{obs}_{ijt}}$ for u=1..6, and how certain are we of those values? And how do the $\sigma_{\beta^{obs}_{ijt}}$-values account for the different uncertainties associated with the underlying data sets (Corine, IACS, NFEW)?
* Step 2: selection of grid cells for spatial allocation of LUC.
    + This is done annually, working backward from the most recent year. Is uncertainty in $U^{obs}_{t=2015}$ accounted for?
    + Probability of misclassification was set at 0.05. That seems too high; the importance of the setting needs to be assessed.
    + Various terms are added to the weighing factors for the probabilistic allocation of LUC to grid cells, depending on the different data sets (EDINA, LCM, ALCM). How were the different weighing factors chosen, and how much do they affect the results?

# Toward a Shiny app for testing BELUC assumptions

The goal is to create a Shiny-app that can be used to interrogate the model. It should allow changing assumptions and settings for the prior and likelihoods of Step 1, and for the various choices made in Step 2. So Which settings of the BELUC approach can we make 'tunable' in a Shiny-app?

Obvious candidates for inclusion in the Shiny-app are the many assumptions and parameter values listed in the preceding section. The model is slow to run (several hours) so all model runs should be done beforehand, and the resulting 'data cube' should be what's driving the app. But even if we only examine a small number of values for each parameter (say 3 to 5 values), the total number of combinations will be unfeasibly large. So we cannot do full-factorial runs. Possible solutions are to allow the user to vary only one parameter at-a-time (OAAT), or to run the model for a Latin Hypercube of parameter settings and interpolate the model results.

It will be interesting to allow the user of the Shiny-app to exclude one or more data sets completely. That could be implemented by setting the respective log-likelihood to a constant, or by setting the respective observational uncertainty to infinity. That will reveal the influence of the different data sets on the final posterior distribution. Note that if we exclude all data sets, we should retrieve the prior: this can be used to check that our procedure works correctly.

Which model outputs to be displayed by the app needs to be carefully considered. Some examples of possible outputs are given in the paper [@levy_Estimation_2018]. For model testing (the initial purpose of the app) we may want to consider alternative outputs, such as the average frequency of land-use change (average number of LUC per grid cell over the whole 46-year period), or the average persistence (number of years) of the six different LU-types over time, or the spatial variability (average number of neighbour grid cells that have the same LU).

A very simple first version of the app could have the following properties.

INPUTS (each with just three values: {0.1, 1, 10}):

* Multiplier for $\sigma_{\beta}$ (prior uncertainty for the LUC-parameters {$\beta_{ijt}$}).
* Multiplier for $\sigma^{obs}_{ut}$ (uncertainty in likelihood for AC-data (Eq. (5))
* Multiplier for both $\sigma_{L^{obs}_{ut}}$ and $\sigma_{G^{obs}_{ut}}$ (uncertainty in likelihood for EAC-data (Eq. (6))
* Multiplier for $\sigma_{\beta^{obs}_{ijt}}$ (uncertainty in likelihood for Corine, IACS and NFEW data (Eq. (7))

OUTPUTS:

* Table showing the frequency with which the 10 most common LUC-types occur
* Average persistence for each of the six LU-types
* Table showing the spatial variability for each of the 47 years

# References
