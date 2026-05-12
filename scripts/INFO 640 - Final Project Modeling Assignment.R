#Poisson Regression Model- Veteran Status Geographic Predictors

#initializing libraries
library(ipumsr)   
library(dplyr)
library(broom)
library(ggplot2)
library(scales)


## set API key from IPUMS
my_key <- "your API key here"
set_ipums_api_key(my_key)


## see list of data
sample_list <- get_sample_info("usa")

## define an extract
extract <- define_extract_micro(
  collection = "usa",
  description = "ACS PUMS Data, 2024",   
  samples = c("us2024a"),                 
  variables = c("STATEFIP", "COUNTYFIP", "MET2023","VETSTAT", 
                "METPOP20", "FARM", "GQTYPE", "GQ", "TRANTIME"), 
  data_quality_flags = TRUE              
)

## submit the API and download results
extract <- submit_extract(extract)    
filepath <- download_extract(extract) 

## read data
ddi <- read_ipums_ddi(filepath)       
data <- read_ipums_micro(ddi)          
ls(data)
table(data$VETSTAT)

#identify variables (these variables relate to geographic characteristics such as living quarters, near a metropolitan area or farm, etc)
variables <- c("STATEFIP", "COUNTYFIP","MET2023", "METPOP20", "GQ", "GQTYPE","FARM", "VETSTAT", "TRANTIME")

#filter for just Texas 
data_texas <- data %>%
  select(all_of(variables)) %>%
  filter(STATEFIP == 48)
  
  
#visualize vet stat variable --------
ggplot(data = data_texas, aes(x = VETSTAT, fill = VETSTAT)) +  
  geom_bar(fill = "red", color = "red") +  
  labs(title = "Count of Veterans by County",
       subtitle = "Texas, 2024",
       y = "Count",
       x = "Veteran Status",
       caption = "Source: ACS 5 Year Estimates") + 
  theme_minimal()





#Poisson Regression----------------------------------


## fit a basic model with raw data
poisson_model <- glm(formula = VETSTAT ~ COUNTYFIP + MET2023 + METPOP20 + GQ + GQTYPE + FARM + TRANTIME, data = data_texas, family = "poisson")
summary(poisson_model)


## convert coefficients to incident ratios
poisson_model2 <- tidy(x = poisson_model, conf.int = TRUE, exponentiate = TRUE)

## Interpret analysis of deviance table
anova(poisson_model, "Chisquare")

#visualize the incident rate ratios by predictor 
ggplot(poisson_model2, aes(x = estimate, y = reorder(term, estimate))) +
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  geom_point(size = 3, color = "firebrick") +
  geom_vline(xintercept = 1, linetype = "dashed", color = "black") +
  scale_x_log10() + 
  labs(title = "Incident Rate Ratios by Predictor",
       subtitle = "Texas County Data, 2024",
       x = "Incident Rate Ratio (Log Scale)",
       y = "Predictor Variable",
       caption = "Horizontal bars represent 95% Confidence Intervals") +
  theme_minimal()
