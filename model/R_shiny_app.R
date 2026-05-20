library(shiny)
library(arules)
library(dplyr)
library(ggplot2)

# =================
# UI
# =================
ui <- fluidPage(
  
  titlePanel("Insurance Policy Recommendation System"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      fileInput("file", "Upload Insurance Dataset (CSV)",
                accept = ".csv"),
      
      hr(),
      
      h4("Customer Inputs"),
      
      selectInput("premium_term", "Premium Term",
                  choices = c("5", "10", "15", "20")),
      
      selectInput("gender", "Gender",
                  choices = c("Male", "Female")),
      
      selectInput("income_group", "Income Group",
                  choices = c("0-3L", "3-6L", "6-10L", "10L+")),
      
      selectInput("policy_type", "Policy Type",
                  choices = c("Term", "Endowment", "ULIP")),
      
      actionButton("recommend", "Get Recommendation",
                   class = "btn-primary")
    ),
    
    mainPanel(
      
      tabsetPanel(
        
        # ------------------
        # TAB 1: EDA
        # ------------------
        tabPanel("EDA",
                 
                 plotOutput("premium_plot"),
                 textOutput("premium_text"),
                 
                 hr(),
                 
                 plotOutput("policy_plot"),
                 textOutput("policy_text"),
                 
                 hr(),
                 
                 plotOutput("benefit_plot"),
                 textOutput("benefit_text")
        ),
        
        # ------------------
        # TAB 2: Recommendation
        # ------------------
        tabPanel("Recommendation",
                 
                 h4("Recommended Benefit Term"),
                 verbatimTextOutput("recommendation"),
                 
                 hr(),
                 
                 h4("Top Association Rules"),
                 tableOutput("rules_table"),
                 
                 hr(),
                 
                 h4("Confidence vs Lift"),
                 plotOutput("rule_plot")
        )
      )
    )
  )
)

# =================
# SERVER
# =================
server <- function(input, output) {
  
  data <- reactive({
    req(input$file)
    
    df <- read.csv(input$file$datapath)
    df <- na.omit(df)
    
    required_cols <- c("PremiumTerm", "PolicyTerm", "BenefitTerm",
                       "Gender", "IncomeGroup", "PolicyType")
    
    if (!all(required_cols %in% colnames(df))) {
      stop("Uploaded file does not contain required columns")
    }
    
    df$PremiumTerm <- as.factor(df$PremiumTerm)
    df$PolicyTerm  <- as.factor(df$PolicyTerm)
    df$BenefitTerm <- as.factor(df$BenefitTerm)
    df$Gender      <- as.factor(df$Gender)
    df$IncomeGroup <- as.factor(df$IncomeGroup)
    df$PolicyType  <- as.factor(df$PolicyType)
    
    df
  })
  
  # ------------------
  # EDA
  # ------------------
  output$premium_plot <- renderPlot({
    ggplot(data(), aes(PremiumTerm)) +
      geom_bar() +
      labs(x = "Premium Term", y = "Count",col="blue")
  })
  
  output$premium_text <- renderText({
    pt <- data() %>% count(PremiumTerm, sort = TRUE) %>% slice(1)
    paste("Most common Premium Term:", pt$PremiumTerm)
  })
  
  output$policy_plot <- renderPlot({
    ggplot(data(), aes(PolicyType)) +
      geom_bar() +
      labs(x = "Policy Type", y = "Count", col='green')
  })
  
  output$policy_text <- renderText({
    p <- data() %>% count(PolicyType, sort = TRUE) %>% slice(1)
    paste("Most preferred Policy Type:", p$PolicyType)
  })
  
  output$benefit_plot <- renderPlot({
    ggplot(data(), aes(BenefitTerm)) +
      geom_bar() +
      labs(x = "Benefit Term", y = "Count")
  })
  
  output$benefit_text <- renderText({
    b <- data() %>% count(BenefitTerm, sort = TRUE) %>% slice(1)
    paste("Most frequent Benefit Term:", b$BenefitTerm)
  })
  
  # ------------------
  # Recommendation
  # ------------------
  observeEvent(input$recommend, {
    
    filtered_data <- data() %>%
      filter(
        PremiumTerm == input$premium_term,
        Gender == input$gender,
        IncomeGroup == input$income_group,
        PolicyType == input$policy_type
      )
    
    if (nrow(filtered_data) < 10) {
      output$recommendation <- renderText("Not enough data for recommendation")
      return()
    }
    
    # Create list of items per transaction
    trans_list <- filtered_data %>%
      select(PremiumTerm, PolicyTerm, BenefitTerm) %>%
      apply(1, as.character) %>%
      split(seq_len(nrow(filtered_data)))
    
    # Convert to transactions
    transactions <- as(trans_list, "transactions")
    
    
    rules <- apriori(
      transactions,
      parameter = list(
        support = 0.05,
        confidence = 0.6,
        minlen = 2
      )
    )
    
    target_rules <- subset(
      rules,
      lhs %pin% paste0("PremiumTerm=", input$premium_term) &
        rhs %pin% "BenefitTerm"
    )
    
    rules_df <- as(target_rules, "data.frame")
    
    if (nrow(rules_df) > 0) {
      
      rules_df$score <- rules_df$confidence * rules_df$lift
      rules_df <- rules_df %>% arrange(desc(score))
      
      output$recommendation <- renderText(rules_df$rules[1])
      output$rules_table <- renderTable(head(rules_df, 5))
      
      output$rule_plot <- renderPlot({
        ggplot(rules_df, aes(confidence, lift)) +
          geom_point() +
          labs(x = "Confidence", y = "Lift")
      })
      
    } else {
      
      fallback <- filtered_data %>%
        count(BenefitTerm, sort = TRUE) %>%
        slice(1)
      
      output$recommendation <- renderText(
        paste("Fallback Recommendation:", fallback$BenefitTerm)
      )
      
      output$rules_table <- renderTable(NULL)
      output$rule_plot <- renderPlot(NULL)
    }
  })
}

shinyApp(ui = ui, server = server)
