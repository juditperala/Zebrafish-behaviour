
# Title: Rbfox1 Tank diving analysis
# Date: 08/10/19
# Author: Judit Garcia-Gonzalez

# ---------------- Required packages ----------------

library(plyr)
library(ggplot2)
library(Hmisc)
library(lme4)
library(car)
library(betareg)
library(emmeans)

# ---------------- Load data ----------------

data = read.csv(file="RBFOX1_Tank_diving_Nicotine.csv", h=T)

# Check data structure
str(data)

# Add timepoint variable
data$timepoint = ifelse(data$Time == "Start-0:01:00", 1, ifelse(
  data$Time == "0:01:00-0:02:00", 2, ifelse(
    data$Time == "0:02:00-0:03:00", 3, ifelse(
      data$Time == "0:03:00-0:04:00", 4, ifelse(
        data$Time == "0:04:00-0:05:00", 5, NA)))))

# Change data structure 
data$In_zone_mean = as.numeric(levels(data$In_zone_mean))[data$In_zone_mean]
data$Trial = as.factor(data$Trial)
data$Arena = as.factor(data$Arena)  

# ---------------- Descriptives & confounder check ----------------

#Check number of fish by Dose and Genotype (Needs to divide)
table(data$Genotype_Dose)/5  
#By Arena
barplot(table(data$Arena, data$Genotype_Dose)/5, legend=TRUE, ylab="Number of fish", xlab= "Genotype & Dose")
#By test date
barplot(table(data$Day, data$Genotype_Dose)/5, legend=TRUE,  ylab="Number of fish", xlab = "Genotype & Dose group")

# ---------------- Plot results ----------------

Genotypes <- list(
  'WT'= "rbfox1 +/+",
  'HET'= "rbfox1 +/-",
  'HOM'= "rbfox1 -/-")

genotypes_labeller <- function(variable,value){
  return(Genotypes[value])
}

data$Genotype_f = factor(data$Genotype, levels=c('WT','HET','HOM'))

# Time on bottom of the tank
ggplot (data, aes(x=timepoint, y=In_zone_cumulative, group=Dose, colour=Dose)) + 
  stat_summary(fun.y="mean", geom="line") + 
  stat_summary(fun.data = "mean_cl_normal", fun.args = list(mult = 1)) +
  xlab("Time (min)") + ylab("Mean time spent on bottom (s)") +
  scale_color_manual(name = "Treatment group",
                     labels = c("30uM Nic", "H2O"),
                     values = c("VioletRed4", "steelblue3")) +
  theme(text = element_text(size=15), 
        panel.background = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.border = element_rect(colour = "grey", fill=NA, size=0.5),
        axis.line = element_line(colour = "grey")) +
  theme(axis.title.y = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.text.x = element_text(angle = 55, size = 12, vjust=1, hjust=1))  +
  ggtitle("Time spent on bottom of the tank") + 
  ylim(0,60) +
  facet_grid( ~ Genotype_f, labeller = genotypes_labeller)+
  theme(strip.text = element_text(face = "italic"))

# Frequency to bottom
ggplot (data, aes(x=timepoint, y=In_zone_frequency, group=Dose, colour=Dose)) + 
  stat_summary(fun.y="mean", geom="line") + 
  stat_summary(fun.data = "mean_cl_normal", fun.args = list(mult = 1)) +
  xlab("Time (min)") + ylab("Number of visits") +
  scale_color_manual(name = "Treatment group",
                     labels = c("30uM Nic", "H2O"),
                     values = c("VioletRed4", "steelblue3")) +
  theme(text = element_text(size=15), 
        panel.background = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.border = element_rect(colour = "grey", fill=NA, size=0.5),
        axis.line = element_line(colour = "grey")) +
  theme(axis.title.y = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.text.x = element_text(angle = 55, size = 12, vjust=1, hjust=1))  +
  ggtitle("Number of visits to bottom of the tank") + 
  facet_grid( ~ Genotype_f, labeller = genotypes_labeller)

# Distance travelled
ggplot (data, aes(x=timepoint, y=Distance_total, group=Dose, colour=Dose)) + 
  stat_summary(fun.y="mean", geom="line") + 
  stat_summary(fun.data = "mean_cl_normal", fun.args = list(mult = 1)) +
  xlab("Time (min)") + ylab("Distance travelled (cm)") +
  scale_color_manual(name = "Treatment group",
                     labels = c("30uM Nic", "H2O"),
                     values = c("VioletRed4", "steelblue3")) +
  theme(text = element_text(size=15), 
        panel.background = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.border = element_rect(colour = "grey", fill=NA, size=0.5),
        axis.line = element_line(colour = "grey")) +
  theme(axis.title.y = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.text.x = element_text(angle = 55, size = 12, vjust=1, hjust=1))  +
  ggtitle("Cumulative distance travelled per minute") + 
  facet_grid( ~ Genotype_f, labeller = genotypes_labeller)

# ---------------- Analysis of time spent on bottom - Beta regression ----------------

#data transformation
data$In_zone_pct = data$In_zone_cumulative/100
summary(data$In_zone_pct)
data$In_zone_pct<-((data$In_zone_pct)*(length(data$In_zone_pct)-1)+0.5)/(length(data[,1])) # Transform data according to Smithson and Verkuilen, 2006

#some descriptives
tapply(data$In_zone_pct, data$Genotype, summary)
tapply(data$In_zone_pct, data$Genotype, sd)

#model
time_bottom_model = betareg(In_zone_pct ~ Genotype*Dose + timepoint + Day, data=data)
Anova(time_bottom_model)
#Post-hoc test conducted using Tukey's HSD
emmeans(time_bottom_model, pairwise~Genotype*Dose, adjust="tukey")

# ---------------- Analysis of distance moved - Linear regression ----------------

#some descriptives
tapply(data$Distance_total, data$Genotype, summary)
tapply(data$Distance_total, data$Genotype, sd)

#model
Total_distance_model = lmer(Distance_total ~ Genotype*Dose + timepoint + Day + (1|Fish_ID), data=data)
Anova(Total_distance_model)
#Post-hoc test conducted using Tukey's HSD
emmeans(Total_distance_model, pairwise~Genotype*Dose, adjust="tukey")

# ---------------- Analysis of frequency to bottom - Poisson regression ----------------

#some descriptives
tapply(data$In_zone_frequency, data$Genotype, summary)
tapply(data$In_zone_frequency, data$Genotype, sd)

#model
frequency_poisson_model = glmer(In_zone_frequency ~ Genotype*Dose + timepoint + Day + (1|Fish_ID), data=data, family = poisson(link = "log"))
Anova(frequency_poisson_model)
#Post-hoc test conducted using Tukey's HSD
emmeans(frequency_poisson_model, pairwise~Genotype*Dose, adjust="tukey")

