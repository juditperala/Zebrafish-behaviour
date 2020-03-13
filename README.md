# Zebrafish_behaviour
Data analysis of zebrafish behaviour: Forced Light-Dark - Novel tank diving - Habituation to startle

###  FORCED LIGHT-DARK ###

We conducted forced Light/Dark tests in five days post fertilization larvae, between 9 am and 4 pm. We placed larvae in 48-well plates and to reduce stress due to manipulation, we let them acclimate for at least one hour in ambient light before testing.

Larvae were exposed to alternating light dark cycles of 10 min: There was an initial 10 minutes period of dark (baseline), followed by two cycles of 10 minutes of light and 10 minutes of dark. This protocol has been used elsewhere (Glazer et al. 2018). Distances travelled were recorded using Ethovision XT software and data were outputted in one minute time-bins.

Data analysis: Firstly, we performed an overall analysis to identify the experimental variables that were significant predictors of distance travelled during the whole duration of the experiment (50 minutes). We fitted the data to a linear mixed model with total distance travelled as response variable, experimental variables (e.g. genotype, dose, time) as fixed effects, and fish ID as random effects. 

We created three subsets of the experiment: baseline, dark, and light periods. We analysed each subset separately by fitting the data to linear mixed models. To assess differences between the first and second light periods, and between the first and second dark periods, we added the period number as fixed effect in the linear mixed models. Linear mixed models were calculated using the R package lme4. 

To identify significant fixed effects, we calculated Analysis of Deviance Tables (Type II Wald χ2 tests) for the models using the R package ‘car’. Where significant differences were established, we carried out post-hoc Tukey tests with the R package ‘emmeans’ to further characterise the effects.

Larvae usually increased the distance travelled during the course of the light periods. To further explore this behaviour, we calculated linear models for each zebrafish at each light period using distance travelled as response variable and time as independent variable. In these linear models, the β coefficient for time represents the increase in distance travelled over time, and can be interpreted as the larva ‘recovery rate’. We constructed ANOVA models (R function ‘aov’) to assess what variables were significant predictors of the ‘recovery rate’.
