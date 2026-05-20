set.seed(123)

n <- 100000

# Generate base variables
age <- sample(18:60, n, replace = TRUE)

gender <- sample(
  c("male", "female"),
  n,
  replace = TRUE,
  prob = c(0.55, 0.45)
)

declared_income <- sample(
  seq(200000, 1500000, by = 50000),
  n,
  replace = TRUE
)

location <- sample(
  c("urban", "semi-urban", "rural"),
  n,
  replace = TRUE,
  prob = c(0.45, 0.30, 0.25)
)

current_status <- sample(
  c("married", "unmarried", "widow"),
  n,
  replace = TRUE,
  prob = c(0.60, 0.35, 0.05)
)

booking_frequency <- sample(
  c("Monthly", "Quarterly", "Half_yearly", "Yearly"),
  n,
  replace = TRUE,
  prob = c(0.45, 0.25, 0.15, 0.15)
)

# Age groups
age_group <- cut(
  age,
  breaks = c(17,30,40,50,60),
  labels = c("18-30","31-40","41-50","51-60")
)

# Income groups
income_group <- cut(
  declared_income,
  breaks = c(0,300000,600000,1000000,Inf),
  labels = c("0-3L","3-6L","6-10L","10L+")
)

# Strong Rule Patterns
premium_term <- ifelse(
  age <= 30,
  sample(c(5,10), n, replace = TRUE),
  ifelse(
    age <= 40,
    sample(c(10,15,20), n, replace = TRUE),
    sample(c(20,25,30), n, replace = TRUE)
  )
)

policy_term <- ifelse(
  premium_term == 5, 15,
  ifelse(
    premium_term == 10, 20,
    ifelse(
      premium_term == 15, 25,
      ifelse(
        premium_term == 20, 30,
        ifelse(
          premium_term == 25, 35,
          40
        )
      )
    )
  )
)

# Policy Type Patterns
policy_type <- ifelse(
  declared_income > 1000000,
  "ULIP",
  ifelse(
    age > 45,
    "Endowment",
    "Term"
  )
)

# Premium Amount Formula
premium_amount <- round(
  3000 +
    age * 120 +
    declared_income * 0.01 +
    ifelse(policy_type == "ULIP", 8000, 0) +
    ifelse(policy_type == "Endowment", 4000, 0) +
    ifelse(location == "urban", 2000, 0) +
    rnorm(n, 0, 1500)
)

# Final Dataset
insurance_data <- data.frame(
  age,
  gender,
  declared_income,
  premium_term,
  policy_term,
  premium_amount,
  booking_frequency,
  location,
  policy_type,
  current_status
)

# Save CSV
write.csv(
  insurance_data,
  "insurance_100000.csv",
  row.names = FALSE
)

# Preview
head(insurance_data)

cat("Dataset Generated Successfully!")
