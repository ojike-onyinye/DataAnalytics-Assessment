-- CTE to get total confirmed deposits per user
WITH ConfirmedDeposits AS (
    SELECT 
        owner_id, 
        SUM(confirmed_amount) AS total_deposits
    FROM 
        savings_savingsaccount
    WHERE 
        transaction_status IN ('monnify_success', 'success', 'successful') -- Filter for only successful transactions
    GROUP BY 
        owner_id
),

-- Main aggregation CTE to summarize user savings and investment plans
UserPlanSummary AS (
    SELECT 
        p.owner_id,
        SUM(p.is_regular_savings) AS savings_count,    -- Total number of regular savings plans per user
        SUM(p.is_a_fund) AS investment_count            -- Total number of investment plans per user
    FROM 
        plans_plan p
    GROUP BY 
        p.owner_id
)

-- Final query to join with users and confirmed deposits, and filter based on plan types
SELECT 
    ups.owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS full_name,         -- Full name of the user
    ups.savings_count,
    ups.investment_count,
    COALESCE(cd.total_deposits, 0) AS total_deposits             -- Default to 0 if no deposits found
FROM 
    UserPlanSummary ups
JOIN 
    users_customuser u ON ups.owner_id = u.id
LEFT JOIN 
    ConfirmedDeposits cd ON ups.owner_id = cd.owner_id
WHERE 
    ups.savings_count > 0                                        -- Include only users with at least one savings plan
    AND ups.investment_count > 0                                 -- And at least one investment plan
ORDER BY 
	total_deposits desc;										 -- Sorted by total deposits