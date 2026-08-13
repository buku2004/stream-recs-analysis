# 🎬 Netflix Customer Churn Analysis

An end-to-end **customer churn analytics project** based on a synthetic Netflix-style streaming dataset. The project combines **Python, PostgreSQL, Power BI, and Machine Learning** to understand customer behaviour, identify factors associated with churn, and predict customers who are at higher risk of leaving.

---

## 📌 Project Overview

Customer churn is a major challenge for subscription-based streaming platforms. Understanding **who is churning, why they are churning, and which customers are most likely to leave** can help businesses improve retention and reduce revenue loss.

This project analyzes a **240K+ record Netflix-style streaming dataset across 6 relational tables**, covering customer profiles, content, viewing behaviour, searches, recommendations, and reviews.

The project follows an end-to-end analytics workflow:

```text
Raw Data
   ↓
EDA & Data Cleaning with Python
   ↓
PostgreSQL Business Analysis
   ↓
Power BI Dashboards
   ↓
Machine Learning Churn Prediction
   ↓
Customer Risk Segmentation
```

---

## 🗂️ Dataset

The synthetic dataset contains **240K+ records across 6 interconnected tables** and covers streaming activity in the USA and Canada during 2024–2025.

| Table                 | Approx. Records | Description                                              |
| --------------------- | --------------: | -------------------------------------------------------- |
| `users`               |            10K+ | Customer demographics, subscriptions and spending        |
| `movies`              |             1K+ | Content metadata, genres, ratings and production details |
| `watch_history`       |           105K+ | Viewing sessions, duration, completion and device data   |
| `recommendation_logs` |            52K+ | Recommendation impressions, clicks and algorithm data    |
| `search_logs`         |            26K+ | Search queries and user search behaviour                 |
| `reviews`             |            15K+ | Ratings, reviews and sentiment information               |

### Data Quality Issues

The dataset contains realistic data-quality problems such as:

* Missing values
* Duplicate records
* Invalid/outlier values
* Missing viewing and engagement metrics
* Incomplete demographic information

These issues were handled during the data-cleaning stage before analysis and modelling.

---

# 🧹 1. Data Cleaning & EDA — Python

**Tools:** Python, Pandas, NumPy, Matplotlib, Seaborn

The first stage focused on understanding and preparing the raw data.

### Data Cleaning

Key steps included:

* Identifying and removing duplicate records
* Handling missing demographic and behavioural values
* Imputing numerical values using appropriate strategies
* Handling invalid age values
* Converting date and numerical columns to appropriate data types
* Checking consistency across related tables
* Validating the cleaned datasets before analysis

### Exploratory Data Analysis

EDA was performed to understand:

* Customer demographics
* Subscription distribution
* Spending patterns
* Viewing behaviour
* Content preferences
* Search activity
* Recommendation engagement
* Review ratings and sentiment
* Differences between active and churned customers

---

# 🗄️ 2. Business Analysis — PostgreSQL

**Tools:** PostgreSQL, SQL

The cleaned data was analyzed using SQL to answer business-focused questions.

### Key Analysis Areas

#### Customer & Churn Analysis

* Churn rate by subscription plan
* Churn by country and state/province
* Customer distribution by plan
* Active vs churned customers
* Revenue associated with different customer segments

#### Customer Behaviour

* Average watch time
* Viewing sessions per user
* Completion rates
* Device usage
* Search activity
* Recommendation engagement

#### Content Analysis

* Most watched content
* Popular genres
* Content completion rates
* Ratings and sentiment by genre
* Original vs non-original content performance

#### Recommendation Analysis

* Recommendation click-through rate
* CTR by recommendation type
* CTR by algorithm version
* Recommendation position vs CTR
* Recommendation performance across devices

---

# 📊 3. Power BI Dashboard

**Tools:** Power BI, DAX

An interactive multi-page dashboard was created to present the analysis in a business-friendly format.

## Dashboard Pages

### 1. Executive Churn Overview

Focuses on the overall health of customer retention.

**Key KPIs:**

* Total Users
* Active Users
* Churn Rate
* Revenue at Risk
* Average Watch Time
* Average Completion Rate

**Visuals include:**

* Monthly churn trend
* Churn by subscription plan
* Churn by customer segment
* Engagement vs churn
* Revenue impact of churn

---

### 2. Customer Behaviour

Analyzes how customers interact with the platform.

**Key metrics:**

* Total Sessions
* Total Watch Hours
* Average Watch Time
* Average Completion Rate
* Average Searches per User
* Recommendation CTR

**Visuals include:**

* Watch-time trends
* Completion-rate distribution
* Device usage
* Watch time by subscription plan
* Active vs churned behaviour
* Recommendation CTR by type
* Recommendation performance by algorithm version

---

### 3. Geographical Analysis

Analyzes customer distribution and churn across the USA and Canada.

**Visuals include:**

* Users by country
* Churn rate by state/province
* User distribution by region
* Revenue by region
* Active vs churned users by region

A country → state/province drill-down allows deeper geographical analysis.

---

### 4. Content Analytics

Examines how content performance and customer sentiment vary across the platform.

**Visuals include:**

* Top watched titles
* Most popular genres
* Completion rate by genre
* Average rating by genre
* Sentiment score by genre
* Original vs licensed content
* Recommendation performance

---

### 5. Churn Prediction & Customer Risk

Combines machine-learning predictions with business analytics.

**Key metrics:**

* Predicted high-risk customers
* Average churn probability
* Churn risk distribution
* Model performance

A customer-level table highlights users with high predicted churn probability.

---

# 🤖 4. Machine Learning — Churn Prediction

**Tools:** Python, Scikit-learn, XGBoost

The ML component predicts whether a customer is likely to churn based on their demographic, subscription, and engagement behaviour.

### Target Variable

```text
churn = 1 → Customer churned
churn = 0 → Customer remained active
```

### Feature Engineering

User-level features were created by aggregating activity across the different tables.

Examples include:

**Customer Features**

* Age
* Subscription plan
* Monthly spend
* Household size
* Tenure
* Country

**Viewing Features**

* Total sessions
* Total watch hours
* Average watch duration
* Average completion rate
* Completed sessions

**Search Features**

* Total searches
* Search frequency

**Recommendation Features**

* Recommendations received
* Recommendation clicks
* Recommendation CTR
* Average recommendation score

**Review Features**

* Number of reviews
* Average rating
* Average sentiment score

---

## 🧠 Models

Three classification models are compared:

1. **Logistic Regression** — baseline and interpretable model
2. **Random Forest** — tree-based ensemble model
3. **XGBoost** — gradient-boosting model

### Evaluation Metrics

Models are evaluated using:

* Accuracy
* Precision
* Recall
* F1-score
* ROC-AUC
* Confusion Matrix

Since this is a churn problem, **Recall and F1-score** are given particular importance because failing to identify an actual churner can result in missed retention opportunities.

---

## 🔎 Feature Importance

Feature importance is analyzed to understand which customer behaviours are most strongly associated with predicted churn.

The analysis focuses on factors such as:

* Watch time
* Completion rate
* Subscription plan
* Customer tenure
* Monthly spending
* Recommendation engagement
* Search behaviour
* User ratings

> **Note:** Since the dataset is synthetic, model findings represent patterns within the dataset and should not be interpreted as causal relationships in real Netflix customer behaviour.

---

# 📈 Customer Risk Segmentation

The final model generates a churn probability for each customer.

Example:

| User  | Churn Probability | Risk        |
| ----- | ----------------: | ----------- |
| U1023 |               91% | High Risk   |
| U4821 |               74% | High Risk   |
| U1920 |               46% | Medium Risk |
| U3810 |               12% | Low Risk    |

Customers can then be grouped into:

* 🔴 **High Risk**
* 🟡 **Medium Risk**
* 🟢 **Low Risk**

These predictions can be incorporated into Power BI to create an actionable customer-risk view.

---

# 💡 Key Business Insights

The final analysis is designed to identify insights such as:

* Which subscription plans have the highest churn?
* Whether lower engagement is associated with higher churn
* Which geographical regions have elevated churn
* Which customer segments generate the greatest revenue risk
* Which recommendation strategies generate higher engagement
* Which content genres receive stronger user sentiment
* Which behavioural features contribute most to predicted churn

The exact findings depend on the cleaned dataset and final model results.

---

# 🛠️ Tech Stack

| Category         | Tools                 |
| ---------------- | --------------------- |
| Programming      | Python                |
| Data Cleaning    | Pandas, NumPy         |
| EDA              | Matplotlib, Seaborn   |
| Database         | PostgreSQL            |
| Analytics        | SQL                   |
| Visualization    | Power BI, DAX         |
| Machine Learning | Scikit-learn, XGBoost |
| Version Control  | Git, GitHub           |

---

```

---

# 🎯 Project Outcome

This project demonstrates an end-to-end approach to solving a customer retention problem using:

* Data cleaning and exploratory analysis
* Relational data analysis with SQL
* Business KPI development
* Interactive dashboard design
* Feature engineering
* Classification modelling
* Model evaluation
* Customer risk prediction

The final objective is to move from simply **describing churn** to identifying **which customers are at risk and what behavioural patterns are associated with that risk**.

---

## 👤 Author

**Subhransu Dalei**

Built as a portfolio project to demonstrate practical skills in **Data Analytics, Business Intelligence, SQL, Python, Power BI, and Machine Learning**.
