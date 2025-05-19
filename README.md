# DataAnalytics-Assessment

This repository contains SQL solutions for the Cowrywise Data Analyst assessment. The task involved answering four business-critical questions using data from savings and investment tables. Each solution demonstrates practical SQL techniques tailored to real-world analytical needs.

---

## Question 1: High-Value Customers with Multiple Products

**Objective:**  
Identify customers who have both a funded savings plan and a funded investment plan — a clear opportunity for cross-sell or loyalty programs.

**Approach:**  
I first filtered savings and investment users separately based on whether their plans were active and funded. Then I identified users who had both types by performing an inner join between the two filtered groups. To ensure only active savers were included, I cross-referenced savings plans with actual inflows from the `savings_savingsaccount` table. The final result returns users with both products, along with how many of each plan they own and their total deposit volume.

**Why this approach?**  
Rather than relying solely on plan existence, I validated savings engagement using real deposit records. This ensures the result reflects financially active users, not just plan sign-ups.

**Challenges:**  
Initially, I considered using a flat join between users, plans, and savings, but this inflated counts due to multiple joins. I resolved this by modularizing the logic with CTEs and `DISTINCT` counts.

---

## Question 2: Transaction Frequency Analysis

**Objective:**  
Segment customers based on how often they transact per month: High (≥10), Medium (3–9), Low (≤2).

**Approach:**  
I grouped transactions by user and calculated their total transaction count and active tenure in months (using first and last transaction dates). Then I derived their average transactions per month and categorized each user accordingly.

**Why this approach?**  
I chose to include all months between a user's first and most recent transaction, even if some were inactive. This reflects a more accurate picture of long-term engagement rather than cherry-picking months with activity.

**Challenges:**  
A simpler alternative was to calculate the average only over months with transactions. However, I found this could inflate the perceived engagement of users with sporadic activity. I stuck with the more conservative, business-aligned calculation using full tenure.

---

## Question 3: Account Inactivity Alert

**Objective:**  
Find savings or investment accounts with no inflow in the past year.

**Approach:**  
I computed the most recent transaction date per user and joined this with their plans. For each plan, I flagged it as inactive if no inflow had occurred in the last 365 days.

**Why this approach?**  
Rather than joining raw transaction data directly with plans — which could result in excessive row duplication — I pre-aggregated the last transaction per user first. This significantly improved performance and reduced memory overhead.

**Challenges:**  
The initial query timed out due to a many-to-many join explosion. I resolved this by aggregating transactions before joining with plans and using a `LEFT JOIN` to catch plans with no activity.

---

## Question 4: Customer Lifetime Value (CLV) Estimation

**Objective:**  
Estimate CLV based on transaction volume and account tenure using a simplified formula.

**Approach:**  
I calculated each customer's tenure since signup and counted their total number of transactions. Using the formula  
`CLV = (transactions / tenure_months) × 12 × avg_profit_per_transaction`,  
where `profit_per_transaction = 0.1% of transaction value`, I derived each user's CLV.

**Why this approach?**  
I excluded users with zero transactions or zero tenure to avoid meaningless CLV calculations and division errors. The final list is clean and focused on financially active users.

**Challenges:**  
An alternative version included all users, assigning `0` to inactive accounts. While that may be useful for exploratory analysis, it distorts the true value distribution. I opted for clarity and business relevance.

---

## Folder Contents
├── Assessment_Q1.sql   
├── Assessment_Q2.sql   
├── Assessment_Q3.sql   
├── Assessment_Q4.sql   
└── README.md

---

## Notes

- Currency values in the dataset are stored in **kobo**, and were converted to **naira** (₦) where applicable.
- All queries were written and tested in **MySQL**.
- CTEs were used extensively to break down logic into manageable steps and improve readability.