# Zebrafish_behaviour
Data analysis of zebrafish behaviour: Forced Light-Dark - Novel tank diving - Habituation to startle

###  FORCED LIGHT-DARK (Rscript: Light-Dark.R) ###

We conducted forced Light/Dark tests in five days post fertilization larvae, between 9 am and 4 pm. We placed larvae in 48-well plates and to reduce stress due to manipulation, we let them acclimate for at least one hour in ambient light before testing.

Larvae were exposed to alternating light dark cycles of 10 min: There was an initial 10 minutes period of dark (baseline), followed by two cycles of 10 minutes of light and 10 minutes of dark. This protocol has been used elsewhere (Glazer et al. 2018). Distances travelled were recorded using Ethovision XT software and data were outputted in one minute time-bins.

Data analysis: Firstly, we performed an overall analysis to identify the experimental variables that were significant predictors of distance travelled during the whole duration of the experiment (50 minutes). We fitted the data to a linear mixed model with total distance travelled as response variable, experimental variables (e.g. genotype, dose, time) as fixed effects, and fish ID as random effects. 

We created three subsets of the experiment: baseline, dark, and light periods. We analysed each subset separately by fitting the data to linear mixed models. To assess differences between the first and second light periods, and between the first and second dark periods, we added the period number as fixed effect in the linear mixed models. Linear mixed models were calculated using the R package lme4. 

To identify significant fixed effects, we calculated Analysis of Deviance Tables (Type II Wald χ2 tests) for the models using the R package ‘car’. Where significant differences were established, we carried out post-hoc Tukey tests with the R package ‘emmeans’ to further characterise the effects.

Larvae usually increased the distance travelled during the course of the light periods. To further explore this behaviour, we calculated linear models for each zebrafish at each light period using distance travelled as response variable and time as independent variable. In these linear models, the β coefficient for time represents the increase in distance travelled over time, and can be interpreted as the larva ‘recovery rate’. We constructed ANOVA models (R function ‘aov’) to assess what variables were significant predictors of the ‘recovery rate’.

###  NOVEL TANK DIVING for a mutant line with and without drug exposure (Rscript: Tank_diving.R) ###

Novel tank diving exploits the natural tendency of zebrafish to initially stay at the bottom of a novel tank, and gradually move to upper parts of the tank. The degree of ‘bottom dwelling’ has been interpreted as an index of anxiety (Greater bottom dwelling meaning greater anxiety) and it is conceptually similar to the rodent open-field and elevated plus maze tasks. Other measures such as the distance travelled in the tank during the course of the assay and the transitions to bottom of the tank can give further insights on the hyper-responsiveness to novel environments.

We transported adult zebrafish (3-4 months) to the behavioural room in their housing tanks and let them acclimate to the room conditions for at least one hour before testing. Novel tank diving was assessed as previously described (Parker, Millington, et al. 2012): zebrafish were individually introduced in a 1.5 L trapezoid tanks (15.2 cm x 27.9 cm x 22.5 cm x 7.1 cm) and filmed for five minutes. Their behaviour was tracked using EthoVision system and data were outputted in one minute time-bins. Care was taken to ensure that experimental groups were randomised during testing. Behavioural testing was conducted between 9 am and 2 pm.

Data analysis: We analysed three behaviours in response to the novel tank: (1) time that zebrafish spent on the bottom third of the tank, (2) total distance that zebrafish travelled in the tank over the five minutes, and (3) number of visits that zebrafish made to the bottom of the tank.

To analyse genotype and/or treatment differences in the time that zebrafish spent on the bottom of the tank, we performed beta regressions using the R package ‘betareg’. We used beta regression because proportion time spent on the bottom of the tank was used as response variable. Proportion data is bounded by the interval [0,1] and often exhibits heterogeneity in variance, which violates statistical assumptions used by linear models.

To analyse genotype or treatment differences in the total distance that zebrafish travelled in the tank, we fitted the data to a linear mixed model with the total distance travelled during one minute as response variable, time, genotype and/or treatment as fixed effects, and fish ID as random effects.

To analyse genotype or treatment differences in the number of visits that zebrafish made to the bottom of the tank, we fitted the data to a generalised linear mixed model with Poisson distribution. The Poisson distributions is commonly used when the response variable is count data (Plan 2014). We used the number of visits to the bottom as response variable, time, genotype or/and treatment as fixed effects, and fish ID as random effects.

Experiments were replicated on different days, and data was jointly analysed afterwards. Mixed models were calculated using the R package lme4. To identify experimental variables with significant effects, we calculated Analysis of Deviance Tables (Type II Wald χ2 tests) for the models using the R package ‘car’. Where significant differences were established, we carried out post-hoc Tukey tests with the R package ‘emmeans’ to further characterise the effects.
