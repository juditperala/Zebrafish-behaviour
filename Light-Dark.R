
##################---- Analysis of Light-dark test ----################## 

#### Author: Judit Garcia Gonzalez

##Load packages
library(plyr)
library(dplyr)
library(lme4)
library(ggplot2)
library(car)
library(emmeans)

##read in the data

data = read.csv(file="file.csv", h=T)

# Add fish_ID as a new variable with a number per fish
ID_vector = c(1:(nrow(data)/50))  # Calculate number of fish. I divide between 50 (number of minutes of the test)
data$fish_ID = as.factor(rep(ID_vector, each=50)) 

# Add timepoint as a new variable with a number per minute
minute = c(1:50)
data$minute = rep(minute, times=length(ID_vector))

str(data)
data$Trial = as.factor(data$Trial)

####----  Plot distance travelled ----

ggplot (data, 
        aes(x=minute, 
            y=Total_distance/100, #Divide /100 if you want data in cm  
            group=Genotype, 
            colour=Genotype)) + 
  stat_summary(fun.y="mean", geom="line") + 
  stat_summary(fun.data = "mean_cl_normal", 
               fun.args = list(mult = 1)) + 
  xlab("Time (min)") + ylab("Distances travelled (cm)") + 
  ggtitle("") +
  theme(text = element_text(size=15), 
        panel.background = element_blank(), 
        panel.grid.minor = element_blank(), 
        panel.border = element_rect(colour = "grey", fill=NA, size=0.5),
        axis.line = element_line(colour = "grey")) +
  theme(axis.title.y = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold"),
        axis.text.x = element_text(angle = 55, size = 10, vjust=1, hjust=1)) +
  annotate("rect",xmin=0,xmax=10,ymin=-Inf,ymax=Inf, alpha=0.1, fill="black") +
  annotate("rect",xmin=20,xmax=30,ymin=-Inf,ymax=Inf, alpha=0.1, fill="black") +
  annotate("rect",xmin=40,xmax=50,ymin=-Inf,ymax=Inf, alpha=0.1, fill="black") +
  annotate(geom="text", x=5, y=0, label="Baseline", color="black") +
  annotate(geom="text", x=15, y=0, label="Light1", color="black") +
  annotate(geom="text", x=25, y=0, label="Dark1", color="black") +
  annotate(geom="text", x=35, y=0, label="Light2", color="black") +
  annotate(geom="text", x=45, y=0, label="Dark2", color="black") +
  scale_color_manual(values = c("#00AFBB", "#E7B800", "#FC4E07")) 

# ------------- 1. Overall analysis for distance moved  

Overallmer_int <- lmer(Total_distance/100 ~ minute * Genotype + Trial + (1|fish_ID), data=data)
Anova(Overallmer_int)
#Post-hoc test conducted using Tukey's HSD
emmeans(Overallmer_int, pairwise~Genotype, adjust="tukey")

# ------------- 2. Analysis for baseline (10 first minutes) 

## 10 min of baseline
baseline <- subset(data, minute < 11)

# Some descriptives
tapply(baseline$Total_distance/100, baseline$Genotype, summary)
tapply(baseline$Total_distance/100, baseline$Genotype, sd)

# Model
lmerbaseline <- lmer(Total_distance/100 ~ minute * Genotype + Trial + (1|fish_ID), data=baseline)
Anova(lmerbaseline) 
emmeans(lmerbaseline, pairwise~Genotype, adjust="tukey")

# ------------- 3. Analysis for light periods (Following Riva Riley's scripts)

##subset L/D
Light1 <- subset(data, 12 < minute & minute < 21)
Light1$light.number <- 1 # CREATE NEW VARIABLE: light event number

Light2 <- subset(data, 32 < minute & 41 > minute)
Light2$light.number <- 2


###### --- Light period 1 --- ######

Light1_slopes <- ddply(Light1, "fish_ID", function(Light1) {
  Light1lm <- lm(Total_distance~minute, data=Light1)
  coef(Light1lm)
})
Light1_slopes$light.number <- 1

# Create dataframe with Genotype and Fish_ID for stratified dark/light analysis

Trial1IDcompile<- data.frame(distinct(Light1, fish_ID, .keep_all = T))
Trial1ID.cond <- data.frame(Trial1IDcompile$fish_ID, Trial1IDcompile$Genotype)

colnames(Trial1ID.cond)[1] <- "fish_ID" 
colnames(Trial1ID.cond)[2] <- "Genotype" 
table(Trial1ID.cond$Genotype)

# Merge dataframe with genotype info and dataframe with slope info 
Light1_slopes_merged <- merge(Light1_slopes, Trial1ID.cond)
colnames(Light1_slopes_merged)[3] <- "slopes" 

## --- anova for light period1 --- 
slopes_model_light1 <- aov(slopes ~ Genotype, data=Light1_slopes_merged) 
summary(slopes_model_light1)


####### --- Light period 2 --- ######

Light2_slopes <- ddply(Light2, "fish_ID", function(Light2) {
  Light2lm <- lm(Total_distance~minute, data=Light2)
  coef(Light2lm)
})
Light2_slopes$light.number <- 2

# Merge dataframe with genotype info and dataframe with slope info 
Light2_slopes_merged <- merge(Light2_slopes, Trial1ID.cond)
colnames(Light2_slopes_merged)[3] <- "slopes" 

## --- anova for light period2 --- 
slopes_model_light2 <- aov(slopes ~ Genotype, data=Light2_slopes_merged) 
summary(slopes_model_light2)


###### --- Light period 1 and 2 together --- ######

# Stack all the dataframes
Light1_2 <- rbind(Light1_slopes_merged, Light2_slopes_merged)
table(Light1_2$light.number)
summary(Light1_2$slopes)

# Merge dataframe with genotype info and dataframe with slope info 
Light1_dist_merged <- merge(Light1, Trial1ID.cond)
Light2_dist_merged <- merge(Light2, Trial1ID.cond)

Light1_2_dist <- rbind(Light1_dist_merged, Light2_dist_merged)

# Build model for distance travelled
light_dist_model <- lmer(Total_distance/100 ~ Genotype * as.factor(light.number) + Genotype * minute + Trial + (1|fish_ID), data=Light1_2_dist) 
Anova(light_dist_model)
#Post-hoc test conducted using Tukey's HSD
emmeans(light_dist_model, pairwise~Genotype * as.factor(light.number), adjust="tukey")

# Some descriptives
tapply(Light1_slopes_merged$slopes/100, Light1_slopes_merged$Genotype, summary) # /100 if you want to report cm
tapply(Light1_slopes_merged$slopes/100, Light1_slopes_merged$Genotype, sd)
tapply(Light2_slopes_merged$slopes/100, Light2_slopes_merged$Genotype, summary)
tapply(Light2_slopes_merged$slopes/100, Light2_slopes_merged$Genotype, sd)

# Regression model of the slope
slopes_model <- lmer(slopes ~ Genotype * as.factor(light.number) + (1|fish_ID), data=Light1_2) 
Anova(slopes_model)
#Post-hoc test conducted using Tukey's HSD
emmeans(slopes_model, pairwise~light.number, adjust="tukey")


# ------------- 3. Analysis for dark periods

##subset L/D
Dark1 <- subset(data, 21 < minute & minute < 31)
table(Dark1$minute)
Dark1$dark.number <- 1 # CREATE NEW VARIABLE THAT IS THE LIHT DARK EVENT

Dark2 <- subset(data, 41 < minute & 50 > minute)
table(Dark2$minute)
Dark2$dark.number <- 2

# Merge dataframe with genotype info and dataframe with slope info 
Dark1_merged <- merge(Dark1, Trial1ID.cond)
Dark2_merged <- merge(Dark2, Trial1ID.cond)

Dark1_2 <- rbind(Dark1_merged, Dark2_merged)

# Some descriptives
tapply(Dark1$Total_distance/100, Dark1$Genotype, summary)
tapply(Dark1$Total_distance/100, Dark1$Genotype, sd)

# Some descriptives
tapply(Dark2$Total_distance/100, Dark2$Genotype, summary)
tapply(Dark2$Total_distance/100, Dark2$Genotype, sd)

# Build model
dark_model <- lmer(Total_distance/100 ~ Genotype*as.factor(dark.number) + minute + Trial + (1|fish_ID), data=Dark1_2) 
Anova(dark_model)
#Post-hoc test conducted using Tukey's HSD
emmeans(dark_model, pairwise~Genotype*as.factor(dark.number), adjust="tukey")
