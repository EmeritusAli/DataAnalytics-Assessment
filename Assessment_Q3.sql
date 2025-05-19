WITH last_transactions_per_user AS (
    SELECT
        owner_id,
        MAX(created_on) AS last_transaction_date
    FROM savings_savingsaccount
    GROUP BY owner_id
),
plan_with_last_txn AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,
        ltp.last_transaction_date
    FROM plans_plan p
    LEFT JOIN last_transactions_per_user ltp ON p.owner_id = ltp.owner_id
    WHERE p.is_regular_savings = 1 OR p.is_a_fund = 1
),
inactive_accounts AS (
    SELECT
        plan_id,
        owner_id,
        type,
        last_transaction_date,
        DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
    FROM plan_with_last_txn
    WHERE last_transaction_date IS NOT NULL
      AND DATEDIFF(CURDATE(), last_transaction_date) > 365
)

SELECT *
FROM inactive_accounts
ORDER BY inactivity_days DESC;
