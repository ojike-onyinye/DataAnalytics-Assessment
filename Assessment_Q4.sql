SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,

    -- If total_transactions = 0, then estimated_clv = 0
    ROUND(
        IF(total_transactions = 0, 
           0, 
           (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
        ), 2
    ) AS estimated_clv

FROM (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,

        -- Tenure in months 
        TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) AS tenure_months,

        -- Successful transactions count
        COUNT(s.id) AS total_transactions,

        -- Total confirmed amount 
        SUM(s.confirmed_amount) AS total_value,

        -- Total profit from transactions
        SUM(s.confirmed_amount) * 0.001 AS profit,

        -- Average profit per transaction (handle divide-by-zero with NULLIF)
        IFNULL(SUM(s.confirmed_amount) * 0.001 / NULLIF(COUNT(s.id), 0), 0) AS avg_profit_per_transaction

    FROM 
        users_customuser u
    LEFT JOIN 
        savings_savingsaccount s 
        ON u.id = s.owner_id 
        AND s.transaction_status IN ('monnify_success','success','successful')

    GROUP BY 
        u.id, u.first_name, u.last_name, u.created_on
) AS a
ORDER BY 
    estimated_clv DESC;
