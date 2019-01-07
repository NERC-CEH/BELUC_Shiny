
# About the BELUC Model

## Terminology

In this Land Use Change (LUC) model, *Land Use* and *Land Cover* will by synonymous, and abbreviated to LU. 

## Data sets

The datasets that are used in the model are as follows:

| Acronym | Name                                          | Reference   |
|---------|-----------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| AC      | Agricultural Census                           | [Scottish Government (2017)](https://www.gov.scot/Topics/Statistics/Browse/Agricultural-Fisheries/PubFinalResultsuneCensus) |
| ALCM    | Agricultural Land Capability Map              | x |
| Corine  | Corine satellite-based land cover information | x |
| CS      | Countryside Survey                            | [Norton *et al.* (2012)](https://doi.org/10.1016/j.jenvman.2012.07.030); [Wood *et al.* (2017)] |
| EAC     | EDINA Agricultural Census                     | x |
| FC      | FC new planting                               | x |
| IACS    | Integrated Administration and Control System  | x |
| LCM     | CEH Land Cover Map                            | x |
| NFEW    | FC National Forest Estate and Woodlands       | x |

# The BELUC approach

The model is spatio-temporal. It estimates land cover on a fine rectangular grid (100 x 100 m), with annual time steps. 

In the paper, the approach is applied to the time period 1969-2016, 47 years long, so there are 46 opportunities for LUC in each grid cell. Six land cover types were  distinguished: forest (1), crop (2), grassland (3), rough grazing (4), urban (5), other (6).

The Bayesian calibration of the model proceeds in two steps:

1. Estimation of the non-spatial *LUC-parameters*, denoted as \( \beta_{ijt} \) , with $ i=1..6, j=1..6, t=2..47, i\neq j $. These parameters quantify the total area of land that changes from LU=i in year t-1 to LU=j in year t. For each year, there are $6 \times 5 = 30$ different LUC-areas to be quantified, so the total number of LUC-parameters to be estimated for the whole time period is $30 \times 46 = 1380$.
2. For each year, allocation of the 30 estimated LUC-areas to different grid cells.

Only the first step is done in a truly Bayesian way, i.e. a prior probability distribution for the parameters is specified, as is a data-likelihood function, and then the posterior distribution for the parameters is derived (by application of Bayes' Theorem) as being proportional to prior and likelihood.

## Main model parameters to be estimated

| Parameter set | Dimension | Units of elements | Meaning |
|------------|--------------|---------|-----------------------------------------------------------|
| $ A = A_{ut} $ | 6 x 47 | $ m^2 $ | Total area in Scotland of LU-type u in year t |
| $ B = \beta_{ijt} $ | 6 x 6 x 46 | $ m^2 y^{-1} $ | Total LUC from  LU=i in year t-1 to LU=j in year t |
| $ U = U_{xyt} $ | $n_x \times n_y \times 47 $ | (1..6) | LU-type in grid cell (x,y) in year t |

## Details of step 1

Step 1 starts out with data from CS and then uses data from AC, Corine, EAC, IACS, NFEW. 

The prior for the 1380 $\beta$-parameters is based on linear interpolation of LUC-observations in consecutive CS. All $\beta$ -parameters are a priori considered to be independent, so their joint prior probability distribution is simply the product of all 1380 marginal priors. The marginal priors are Gaussian distributions, and they all share the same standard deviation ( $ \sigma_{\beta} $ ), derived using bootstrapping from the CS-data [@scott_CS_2008; @wood_Longterm_2017].

Three likelihood functions are specified ($ L_{net}, L_{gross}, L_B $) which use data from AC, EAC, and {Corine, IACS, NFEW} respectively. The three likelihood functions are multiplied to arrive at one overall likelihood function $L(\beta)$. In other words, the three (groups of) data sets are assumed to provide independent information.

The Bayesian calibration of the $ \beta $-parameters is carried out by means of MCMC, which generates a representative sample from the posterior distribution for the parameters. To make the sampling tractable, this is done separately for the different years, i.e. 46 separate MCMCs are run. This allows for correlations between parameter estimates within individual years, but correlations between parameter estimates for different years are thereby ignored. The joint posterior distribution for all 1380 parameters is thus assumed to be the direct product of the 46 within-year posterior distributions.

## Details of step 2

Step 2 uses data from AC, ALCM, Corine, IACS, LCM, NFEW. The goal of this step is to allocate the annual LUC-areas (represented by the $\beta$-parameters for which we found a posterior distribution in Step 1) to different grid cells. Thereby, full 47-year long time series of LU are generated for each of the about eight million grid cells (of 100 x 100 m) in Scotland. In other words, Step 2 estimates about $47 \times 8.10^6 \approx 3.8 \times 10^8$ parameters.

The procedure is fairly complicated and involves making a large number of assumptions about the relative reliabilities of the different data sets. The procedure is probabilistic but not Bayesian (no priors, no likelihoods).
