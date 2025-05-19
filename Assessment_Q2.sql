-- CTE to count monthly transactions per user
WITH MonthlyTransactions AS (
    SELECT 
        s.owner_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS transaction_month, -- Format date as YYYY-MM for monthly grouping
        COUNT(s.id) AS monthly_transaction_count
    FROM 
        savings_savingsaccount s
    GROUP BY 
        s.owner_id, DATE_FORMAT(s.transaction_date, '%Y-%m')
),

-- CTE to calculate average monthly transaction count per user
UserMonthlyAverages AS (
    SELECT 
        mt.owner_id,
        ROUND(AVG(mt.monthly_transaction_count), 1) AS avg_per_month
    FROM 
        MonthlyTransactions mt
    GROUP BY 
        mt.owner_id
),

-- Final CTE to classify users by transaction frequency
ClassifiedUsers AS (
    SELECT
        u.id,
        COALESCE(uma.avg_per_month, 0) AS avg_per_month,
        CASE 
            WHEN COALESCE(uma.avg_per_month, 0) >= 10 THEN 'High Frequency'
            WHEN COALESCE(uma.avg_per_month, 0) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS Frequency_Category
    FROM 
        users_customuser u
    LEFT JOIN UserMonthlyAverages uma ON u.id = uma.owner_id
)

-- Final aggregation by frequency category
SELECT 
    Frequency_Category,
    COUNT(id) AS customer_count,
    ROUND(AVG(avg_per_month), 1) AS avg_transactions_per_month
FROM 
    ClassifiedUsers
GROUP BY 
    Frequency_Category;
