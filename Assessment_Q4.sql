WITH user_transaction_summary AS (
    SELECT
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) AS tenure_months,
        COUNT(s.id) AS total_transactions,
        SUM(s.confirmed_amount) / 100.0 AS total_inflow_naira  # convert kobo to naira
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id, name, u.created_on
    HAVING total_transactions > 0 AND tenure_months > 0
),

clv_calc AS (
    SELECT
        customer_id,
        name,
        tenure_months,
        total_transactions,
        ROUND(
            ((total_transactions / tenure_months) * 12) * (0.001 * total_inflow_naira / total_transactions),
            2
        ) AS estimated_clv
    FROM user_transaction_summary
)

SELECT *
FROM clv_calc
ORDER BY estimated_clv DESC;



