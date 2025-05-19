WITH user_transaction_stats AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,
        TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1 AS months_active
    FROM savings_savingsaccount
    GROUP BY owner_id
    HAVING COUNT(*) > 0
),

user_avg_freq AS (
    SELECT
        owner_id,
        total_transactions,
        months_active,
        ROUND(total_transactions / months_active, 2) AS avg_transactions_per_month
    FROM user_transaction_stats
),

user_categories AS (
    SELECT
        owner_id,
        avg_transactions_per_month,
        CASE 
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM user_avg_freq
)

SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM user_categories
GROUP BY frequency_category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
    
    


