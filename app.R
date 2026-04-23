# install.packages(c("shiny","survival","survminer","ggplot2","dplyr"))

library(shiny)
library(survival)
library(survminer)
library(ggplot2)
library(dplyr)

# -----------------------------
# Simulated Dataset
# -----------------------------
set.seed(101)

n <- 200

data <- data.frame(
  patient_id = paste0("P", 1:n),
  age = sample(40:75, n, replace = TRUE),
  stage = sample(c("Stage II", "Stage III"), n, replace = TRUE),
  treatment = sample(c("Standard", "New Drug"), n, replace = TRUE)
)

# Force imbalance (to create difference)
data$stage[data$treatment == "New Drug"] <- sample(c("Stage III","Stage II"), 
                                                   sum(data$treatment=="New Drug"),
                                                   replace=TRUE, prob=c(0.7,0.3))

# Time + Event
data$time <- ifelse(data$treatment == "New Drug",
                    rexp(n, 0.06), rexp(n, 0.08))
data$time <- round(data$time * 12,1)

data$event <- ifelse(data$treatment == "New Drug",
                     rbinom(n,1,0.35),
                     rbinom(n,1,0.5))

# FIX reference level
data$treatment <- factor(data$treatment, levels = c("Standard","New Drug"))

# -----------------------------
# UI
# -----------------------------
ui <- fluidPage(
  titlePanel("KM vs Cox Survival Analysis Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("stage","Filter Stage",
                  choices=c("All","Stage II","Stage III"))
    ),
    
    mainPanel(
      tabsetPanel(
        
        tabPanel("KM vs Cox Comparison",
                 
                 fluidRow(
                   column(6, plotOutput("kmPlot")),
                   column(6, verbatimTextOutput("coxResults"))
                 )
        ),
        
        tabPanel("PH Assumption",
                 verbatimTextOutput("phTest")
        ),
        
        tabPanel("Interpretation",
                 verbatimTextOutput("explanation")
        )
      )
    )
  )
)

# -----------------------------
# SERVER
# -----------------------------
server <- function(input, output){
  
  filtered_data <- reactive({
    df <- data
    if(input$stage!="All"){
      df <- df %>% filter(stage==input$stage)
    }
    df
  })
  
  # KM Plot
  output$kmPlot <- renderPlot({
    df <- filtered_data()
    
    fit <- survfit(Surv(time,event) ~ treatment, data=df)
    
    ggsurvplot(
      fit,
      data=df,
      pval=TRUE,
      risk.table=TRUE,
      title="Kaplan-Meier (Unadjusted)"
    )$plot
  })
  
  # Cox Results
  output$coxResults <- renderPrint({
    df <- filtered_data()
    
    cox_adj <- coxph(Surv(time,event) ~ treatment + age + stage, data=df)
    summary(cox_adj)
  })
  
  # PH Test
  output$phTest <- renderPrint({
    df <- filtered_data()
    model <- coxph(Surv(time,event) ~ treatment + age + stage, data=df)
    cox.zph(model)
  })
  
  # Explanation Logic
  output$explanation <- renderText({
    
    df <- filtered_data()
    
    # KM (log-rank approx via survdiff)
    km_test <- survdiff(Surv(time,event) ~ treatment, data=df)
    km_p <- 1 - pchisq(km_test$chisq, df=1)
    
    # Cox
    cox_model <- coxph(Surv(time,event) ~ treatment + age + stage, data=df)
    hr <- exp(coef(cox_model))[1]
    pval <- summary(cox_model)$coefficients[,"Pr(>|z|)"][1]
    
    result <- ""
    
    if (km_p < 0.05 & pval < 0.05) {
      result <- "Both Kaplan-Meier and Cox model agree: Treatment effect is significant."
    } else if (km_p < 0.05 & pval >= 0.05) {
      result <- "KM shows significance but Cox does not. Possible confounding variables (age/stage) influence results."
    } else if (km_p >= 0.05 & pval < 0.05) {
      result <- "Cox shows significance but KM does not. Adjustment reveals hidden treatment effect."
    } else {
      result <- "No significant difference detected by either method."
    }
    
    paste(
      "KM p-value:", round(km_p,4), "\n",
      "Cox HR:", round(hr,2), "\n",
      "Cox p-value:", round(pval,4), "\n\n",
      "Interpretation:\n", result, "\n\n",
      "Explanation:\n",
      "- Kaplan-Meier is unadjusted\n",
      "- Cox model adjusts for age and stage\n",
      "- Differences indicate confounding or model assumptions"
    )
  })
}

# Run
shinyApp(ui, server)