# DataAnalytics-Assessment
The repository for Cowrywise Data Analyst Technical Assessment.
## Assessment #1: High-Value Customers with Multiple Products

### Approach

1. **Start with `plans_plan`:**  
   This table contains product info per customer. I used it to count how many savings and investment plans each customer has by checking:
   - `is_regular_savings` for savings
   - `is_a_fund` for investments

2. **Join to `users_customuser`:**  
   To get customer names, I joined this table using `owner_id`.

3. **Calculate Total Deposits:**  
   I pulled deposit data from `savings_savingsaccount`, grouped by `owner_id`, and summed `confirmed_amount`.  
   This was joined as a subquery to bring in total deposits.

4. **Filter and Aggregate:**  
   Using `HAVING`, I filtered for users with:
   - At least one funded savings plan
   - At least one funded investment plan  
   Then sorted by total deposits for a high-value customer view.


## Assessment #2: Transaction Frequency Analysis

### Approach

1. **Start with Transactions:**  
   I began with the `savings_savingsaccount` table to count how many transactions each customer made per month. This was grouped by `owner_id` and the transaction month.

2. **Calculate Monthly Averages:**  
   I calculated each customer's average monthly transactions using `AVG()` to understand their activity level over time.

3. **Classify Frequency:**  
   I used a `CASE` statement to categorize customers as:
   - "High Frequency" (≥10/month)
   - "Medium Frequency" (3–9/month)
   - "Low Frequency" (≤2/month)

4. **Final Summary:**  
   The final step grouped customers by frequency category and calculated:
   - Total customers in each group
   - Their average monthly transaction count

---

### Challenges

- **Zero-Transaction Users:**  
  To include users with no transactions, I used a `LEFT JOIN` and `COALESCE()` to treat missing averages as 0.



## Assessment #3: Account Inactivity Alert

### Approach

1. **Start with `plans_plan`:**  
   I used this table to identify all active savings and investment plans by filtering on `is_regular_savings = 1` or `is_a_fund = 1`.

2. **Join with `savings_savingsaccount`:**  
   To check activity, I left joined transactions using `plan_id` to capture the most recent transaction date for each plan. Plans with no transactions still appear due to the left join.

3. **Calculate Inactivity:**  
   In a second CTE, I computed:
   - The **last transaction date**, or a fallback if none exist.
   - The **inactivity_days** by comparing that date to today.  
   If there’s no transaction, I defaulted the inactivity to 366 days to flag it.

4. **Flag Inactive Plans:**  
   I filtered out any plans with over **365 days of inactivity**, and labeled the type as either **Savings** or **Investment** accordingly using `UNION ALL`.

---

### Challenges

- **No Transactions at All:**  
  Some plans may never have had a transaction. I handled this by using `COALESCE()` and a default inactivity of 366 days.

- **Multiple Plan Types:**  
  Since a plan can be either savings or investment, I used two separate SELECTs and combined them with `UNION ALL` for clarity in labeling.




## Assessment #4: Customer Lifetime Value (CLV) Estimation

### Approach

1. **Start with `users_customuser`:**  
   This table gives each customer's signup date, which I used to calculate **account tenure in months** with `TIMESTAMPDIFF()`.

2. **Join with `savings_savingsaccount`:**  
   I joined transactions to get:
   - Total number of transactions
   - Total confirmed amount
   - Profit (0.1% of transaction value)

3. **Calculate Average Profit per Transaction:**  
   I divided total profit by total transaction count, handling divide-by-zero using `NULLIF`.

4. **Estimate CLV:**  
   Applied the formula:  
   `CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction`  
   Rounded the result to 2 decimal places and defaulted to zero if there were no transactions.

5. **Final Touch:**  
   Ordered the results by `estimated_clv` from highest to lowest to surface top customers.

---

### Challenges

- **Zero Transactions or Zero Tenure:**  
  Had to carefully guard against division by zero, especially for new customers or those with no activity, using `IF`, `IFNULL`, and `NULLIF`.



