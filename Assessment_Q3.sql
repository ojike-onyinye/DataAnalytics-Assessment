-- CTE: Get latest transaction date for each plan, along with plan type flags
WITH plan_activity AS (
    SELECT 
        a.id AS plan_id,
        a.owner_id,
        a.is_regular_savings,
        a.is_a_fund,
        MAX(DATE(b.transaction_date)) AS raw_last_transaction_date -- Latest transaction date for the plan
    FROM 
        plans_plan a
    LEFT JOIN 
        savings_savingsaccount b ON a.id = b.plan_id -- Include all plans, even those with no transactions
    WHERE 
        a.is_regular_savings = 1 OR a.is_a_fund = 1 -- Filter only for relevant plan types
    GROUP BY 
        a.id, a.owner_id, a.is_regular_savings, a.is_a_fund
),

-- CTE: Calculate inactivity details per plan
inactivity AS (
    SELECT
        plan_id,
        owner_id,
        is_regular_savings,
        is_a_fund,
        -- Format last transaction date or return a custom message if none
        COALESCE(DATE_FORMAT(raw_last_transaction_date, '%Y-%m-%d'), 'No transaction at all') AS last_transaction_date,
        
        -- Calculate days since last transaction; default to 366 if no transaction found
        COALESCE(DATEDIFF(CURDATE(), raw_last_transaction_date), 366) AS inactivity_days
    FROM 
        plan_activity
)

-- Final output: Separate result sets for inactive savings and investment plans
SELECT 
    plan_id,
    owner_id,
    'Savings' AS Type,
    last_transaction_date,
    inactivity_days
FROM 
    inactivity
WHERE 
    is_regular_savings = 1 
    AND inactivity_days > 365 -- Mark as inactive if no activity in over a year

UNION ALL

SELECT 
    plan_id,
    owner_id,
    'Investment' AS Type,
    last_transaction_date,
    inactivity_days
FROM 
    inactivity
WHERE 
    is_a_fund = 1 
    AND inactivity_days > 365; -- Same check for inactive investment plans
