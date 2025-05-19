WITH savings_counts AS (
    SELECT
        p.owner_id,
        COUNT(DISTINCT p.id) AS savings_count
    FROM plans_plan p
    JOIN savings_savingsaccount s ON p.owner_id = s.owner_id
    WHERE p.is_regular_savings = 1
      AND s.confirmed_amount > 0
    GROUP BY p.owner_id
),

investment_counts AS (
    SELECT
        owner_id,
        COUNT(DISTINCT id) AS investment_count
    FROM plans_plan
    WHERE is_a_fund = 1
    GROUP BY owner_id
),

deposits AS (
    SELECT
        owner_id,
        SUM(confirmed_amount) / 100.0 AS total_deposits #kobo to naira
    FROM savings_savingsaccount
    GROUP BY owner_id
),

users_with_both AS (
    SELECT
        s.owner_id
    FROM savings_counts s
    INNER JOIN investment_counts i ON s.owner_id = i.owner_id
)

SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    sc.savings_count,
    ic.investment_count,
    ROUND(d.total_deposits, 2) AS total_deposits
FROM users_with_both b
JOIN users_customuser u ON b.owner_id = u.id
JOIN savings_counts sc ON u.id = sc.owner_id
JOIN investment_counts ic ON u.id = ic.owner_id
JOIN deposits d ON u.id = d.owner_id
ORDER BY total_deposits DESC;


