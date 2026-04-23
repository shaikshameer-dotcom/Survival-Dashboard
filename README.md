# Survival-Dashboard
Rshinny dashboard shows the Survival Vs Cox analysis
#  KM vs Cox Survival Analysis Dashboard

##  Project Overview

This project presents an interactive **clinical survival analysis dashboard** built using R Shiny. It compares **Kaplan–Meier survival analysis** and **Cox proportional hazards modeling** to evaluate treatment effectiveness in an oncology-like dataset.

The dashboard is designed to highlight the **difference between unadjusted and adjusted survival analysis**, a critical concept in clinical research and biostatistics.

 **Objective**

To analyze whether a **new treatment improves survival outcomes** compared to standard therapy using:

* Kaplan–Meier survival curves (unadjusted)
* Cox regression (adjusted for covariates)
* Proportional Hazards (PH) assumption testing
##  Features

###  1. KM vs Cox Comparison

* Kaplan–Meier survival curves
* Log-rank test (p-value)
* Cox model summary (Hazard Ratio, p-value)

###  2. PH Assumption Testing

* Validates Cox model assumptions using Schoenfeld residuals

###  3. Intelligent Interpretation

* Automatically explains:

  * When KM and Cox agree
  * When results differ
  * Impact of confounding variables

##  Key Concepts Demonstrated

* Survival Analysis
* Time-to-Event Modeling
* Kaplan–Meier Estimation
* Cox Proportional Hazards Model
* Confounding Adjustment
* Model Assumption Testing
##  Dataset Description

The dataset is **synthetically generated** and includes:

* `patient_id` – Unique identifier
* `age` – Patient age
* `stage` – Cancer stage (II / III)
* `treatment` – Standard vs New Drug
* `time` – Survival time (months)
* `event` – Outcome (1 = event occurred, 0 = censored)

 The dataset intentionally introduces **imbalance in cancer stage** to demonstrate confounding effects.

---

## Packages Used

* R
* Shiny
* survival
* survminer
* ggplot2
* dplyr

