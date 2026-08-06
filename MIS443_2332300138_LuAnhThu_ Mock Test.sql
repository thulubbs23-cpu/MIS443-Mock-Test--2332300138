/*
===============================================================================
MIS 443 - FINANCE ANALYSIS - SQL SKELETON
PostgreSQL | Duration: 90 minutes | Total: 100 marks

STUDENT ID : Lu Anh Thu
FULL NAME  : 2332300138
GITHUB URL : https://github.com/thulubbs23-cpu/MIS443-Mock-Test--2332300138
===============================================================================
*/

/*
BUSINESS SCENARIO AND DATASET

The database represents a retail bank that manages customers, branches,
accounts, and account transactions. Managers use it to monitor customer value,
account balances, branch performance, and transaction activity.

- customers: one row per customer;
- branches: one row per bank branch;
- accounts: each account belongs to one customer and one branch;
- transactions: each transaction belongs to one account.

Positive account balances represent funds held by customers. Negative Credit
Card balances represent amounts owed. Positive transaction amounts are credits
and negative transaction amounts are debits.

SUBMISSION REMINDER
Submit the completed SQL file, Word report, and ERD screenshot on Moodle, and
upload the same files to your accessible personal GitHub repository.
*/

/*
QUESTION 1 - DATABASE SETUP (10 marks)

Create a PostgreSQL database using your full name in lowercase, without spaces
or Vietnamese diacritics. Connect to it and execute
MIS443_Finance_PostgreSQL.sql. Confirm that customers, branches, accounts, and
transactions are available in the public schema. (10 marks)
*/

-- Expected result after loading the supplied data:
-- accounts     | 15
-- branches     | 15
-- customers    | 6
-- transactions | 15


/*
QUESTION 2 - CUSTOMER AND ACCOUNT OVERVIEW (10 marks)

(a) The Customer Service Manager needs a contact list of customers living in
New York. Display customer_id, full_name, and city, sorted by customer_id.
(5 marks)
*/

SELECT
customer_id,
first_name || ' ' || last_name as full_name,
city
FROM customers
WHERE city = 'New York'
ORDER BY customer_id;


-- Expected result:
-- 1 | John Doe | New York
-- 2 | Jane Doe | New York


/*
(b) Management needs to confirm the size of the account portfolio. Calculate
the total number of accounts and name the result total_accounts. (5 marks)
*/

SELECT COUNT(*) as total_accounts
FROM accounts;

-- Expected result: 15


/*
QUESTION 3 - ACCOUNT BALANCE ANALYSIS (20 marks)

(a) The Finance Manager wants to monitor funds held in checking accounts.
Calculate their total balance and name the result total_checking_balance.
(10 marks)
*/

SELECT
    SUM(balance) AS total_checking_balance
FROM accounts
WHERE account_type = 'Checking';

-- Expected result: 31000.00


/*
(b) The Los Angeles Regional Manager wants to compare customer portfolios.
For each customer living in Los Angeles, display customer_id, full_name, and
total_balance across all account types. Sort by total_balance descending.
(10 marks)
*/

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
WHERE c.city = 'Los Angeles'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_balance DESC;

-- Expected result:
-- 5 | Michael Lee   | 60000.00
-- 6 | Jennifer Wang | 15000.00


/*
QUESTION 4 - BRANCH AND CUSTOMER PORTFOLIO ANALYSIS (20 marks)

(a) Senior management wants to identify the branch with the highest average
account balance. Display branch_id, branch_name, city, and average_balance.
Return all branches tied for the highest average and round to two decimals.
(10 marks)
*/

SELECT 
	b.branch_id,
	b.branch_name,
	b.city,
	ROUND(AVG(a.balance), 2) AS average_balance
FROM public.branches AS b
JOIN public.accounts AS a
ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY average_balance DESC
FETCH FIRST 1 ROW WITH TIES;

-- Expected result:
-- 14 | North Beach | San Francisco | 30000.00


/*
(b) A relationship manager wants to identify the customer who owns the single
account with the highest current balance. Display customer_id, full_name,
account_id, account_type, and balance. Include ties if any. (10 marks)
*/

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name as full_name,
    a.account_id,
    a.account_type,
    a.balance
FROM customers c
JOIN accounts a
ON c.customer_id = a.customer_id
ORDER BY a.balance DESC
FETCH FIRST 1 ROW WITH TIES;

-- Expected result:
-- 5 | Michael Lee | 10 | Savings | 50000.00


/*
QUESTION 5 - CUSTOMER VALUE AND ACTIVITY (20 marks)

(a) The Customer Relationship Manager wants to identify the most active
customer based on the total number of transactions across all their accounts.
Display customer_id, full_name, and total_transactions. Include ties.
(10 marks)
*/

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    COUNT(t.transaction_id) AS total_transactions
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_transactions DESC
FETCH FIRST 1 ROW WITH TIES;
-- Expected result:
-- 2 | Jane Doe      | 4
-- 4 | Alice Johnson | 4


/*
(b) The Deposit Manager wants to identify the customer with the highest total
balance across Checking and Savings accounts only. Display customer_id,
full_name, and total_deposit_balance. Include ties. (10 marks)
*/

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
	SUM(a.balance) AS total_deposit_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE a.account_type IN ('Checking', 'Savings')
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_deposit_balance DESC
FETCH FIRST 1 ROW WITH TIES;

-- Expected result:
-- 5 | Michael Lee | 60000.00


/*
QUESTION 6 - ADVANCED FINANCE ANALYSIS (20 marks)

(a) Management wants to identify the branch with the highest total balance
across all account types. Display branch_id, branch_name, and total_balance.
Include ties. (10 marks)
*/

SELECT
    b.branch_id,
    b.branch_name,
    SUM(a.balance) AS total_balance
FROM branches b
JOIN accounts a ON b.branch_id = a.branch_id
GROUP BY
    b.branch_id,
    b.branch_name
ORDER BY total_balance DESC
FETCH FIRST 1 ROW WITH TIES;

-- Expected result:
-- 14 | North Beach | 60000.00


/*
(b) Rank all customers by total balance across all account types. Equal totals
must receive the same rank without gaps. Display customer_id, full_name,
total_balance, and balance_rank. Do not use a CTE. (5 marks)
*/

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    SUM(a.balance) AS total_balance,
    DENSE_RANK() OVER (ORDER BY SUM(a.balance) DESC) as balance_rank
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY balance_rank;

-- Expected result:
-- 5 | Michael Lee   | 60000.00 | 1
-- 4 | Alice Johnson | 25000.00 | 2
-- 3 | Bob Smith     | 20500.00 | 3
-- 6 | Jennifer Wang | 15000.00 | 4
-- 2 | Jane Doe      | 11500.00 | 5
-- 1 | John Doe      |  5500.00 | 6


/*
(c) Use a CTE to calculate the total number of transactions for every branch,
including branches with no transactions. Return the branch or branches with
the highest total. Display branch_id, branch_name, and total_transactions.
(5 marks)
*/

WITH branch_transactions as ( SELECT b.branch_id, b.branch_name,
        COUNT(t.transaction_id) as total_transactions
    FROM branches b
    LEFT JOIN accounts a ON b.branch_id = a.branch_id
    LEFT JOIN transactions t ON a.account_id = t.account_id
    GROUP BY
	b.branch_id,
	b.branch_name)
SELECT
    branch_id,
    branch_name,
    total_transactions
FROM branch_transactions
ORDER BY total_transactions DESC
FETCH FIRST 1 ROW WITH TIES;

-- Expected result:
-- 1 | Main      | 4
-- 8 | South Bay | 4


-- END OF EXAM
