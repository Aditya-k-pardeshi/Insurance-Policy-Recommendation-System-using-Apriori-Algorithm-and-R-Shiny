# Insurance-Policy-Recommendation-System-using-Apriori-Algorithm-and-R-Shiny
End-to-end insurance recommendation system built during internship at Bajaj Allianz Life Insurance

# Overview
This project is an intelligent insurance recommendation system developed using R Shiny and the Apriori algorithm. The application analyzes customer demographic and financial information to recommend suitable insurance policy terms.

# Problem Statement
Insurance companies need intelligent systems to recommend suitable policies and estimate customer risk based on demographic and financial factors. Traditional recommendation approaches are often manual and less personalized. This project develops an automated insurance recommendation system using association rule mining and R Shiny to identify relationships between customer characteristics and insurance policy preferences.

# Key Features
Built interactive dashboard using RStudio and Shiny.
Implemented Apriori algorithm for association rule mining.
Generated insurance recommendations based on customer attributes.
Added EDA visualizations and filtering system.
Processed large insurance datasets (300MB support).

# Technologies Used
R
Shiny
arules
dplyr
ggplot2

Dataset

# Synthetic dataset containing:
age
gender
declared_income
premium_term
policy_term
booking_frequency
policy_type
current_status

# How to run
install.packages(c("shiny","dplyr","arules"))
shiny::runApp()

# Recommendation Logic
The system uses association rule mining to discover relationships between:
Premium Term
Policy Term
Policy Type
Customer Demographics

# Sample rules
premium_term=10 => policy_term=20
premium_term=20 => policy_type=Endowment
