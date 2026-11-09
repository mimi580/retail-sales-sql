# Retail Sales & Customer Intelligence Using PostgreSQL

SQL analysis of sales and customer data for **Duka Smart Electronics**, a (fictional) Kenyan electronics
retailer trading in ten towns since January 2025. The project sets up a PostgreSQL database, answers 46
business questions in SQL, and turns the results into recommendations for management.

**Author:** Nesta Munene · LuxDev HQ Data Science, Cohort 9, Week 10

---

## Project contents

| File | What it is |
|---|---|
| `schema.sql` | `CREATE TABLE` statements for `customers` and `orders`, with keys, constraints and indexes |
| `queries.sql` | All 46 answers, numbered `-- Q1` … `-- Q46`, in six sections |
| `insights.md` | Seven business insights: finding, why it matters, recommendation |
| `screenshots/` | Output of `05_verify_data.sql` and selected query results |

## The data

| Table | Rows | Description |
|---|---|---|
| `customers` | 150 | Customer name, gender, city, registration date, segment (Retail / Corporate / VIP) |
| `orders` | 800 | One row per order: product, category, quantity, prices, discount %, payment method, status |

One customer can have many orders (`orders.customer_id` → `customers.customer_id`). Orders run from
**1 January 2025 to 30 September 2026**.

## Business rules used throughout

| Measure | Formula |
|---|---|
| Revenue | `quantity * unit_price * (1 - discount / 100)` |
| Cost | `quantity * cost_price` |
| Profit | `revenue - cost` |
| Profit margin % | `profit / NULLIF(revenue, 0) * 100` |

- Revenue, cost, profit and spending use **Completed orders only**. Order counts include every status.
- "Today" is the latest `order_date` in the data (2026-09-30), so results do not depend on when you run them.
- Months mean year + month (`DATE_TRUNC('month', order_date)`).
- Where a question could be read more than one way, the choice is explained in a comment above the query.

## How to set it up

Requirements: PostgreSQL 14 or newer, plus psql, DBeaver or pgAdmin.

1. Create the database (connected to the default `postgres` database):
   ```sql
   CREATE DATABASE retail_analytics;
   ```
2. Connect to `retail_analytics` and create the tables:
   ```bash
   psql -U postgres -d retail_analytics -f schema.sql
   ```
3. Load the data with the course's insert scripts, customers first:
   ```bash
   psql -U postgres -d retail_analytics -f 03_insert_customers.sql
   psql -U postgres -d retail_analytics -f 04_insert_orders.sql
   ```
4. Check it loaded with `05_verify_data.sql`. You should see 150 customers, 800 orders, 0 orders without a
   customer, and dates from 2025-01-01 to 2026-09-30.

**DBeaver users:** to create a new database, tick *Show all databases* in the connection settings
(Edit Connection → PostgreSQL tab). Then make sure the editor toolbar shows `public@retail_analytics`
before running scripts.

## How to run the queries

```bash
psql -U postgres -d retail_analytics -f queries.sql
```

Or open `queries.sql` in DBeaver/pgAdmin, put the cursor inside a query and press **Ctrl+Enter** to run just
that one. The file is safe to run more than once: the view (Q43) and the function (Q44) use
`CREATE OR REPLACE`.

| Section | Questions | Concepts |
|---|---|---|
| A — SQL fundamentals | Q1–Q10 | `SELECT`, `WHERE`, `DISTINCT`, `ORDER BY`, `LIMIT`, `LIKE`, `BETWEEN` |
| B — Aggregation | Q11–Q20 | `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING`, `FILTER` |
| C — Joins | Q21–Q28 | `INNER JOIN`, `LEFT JOIN`, customer analytics |
| D — Subqueries & CTEs | Q29–Q34 | subqueries, `WITH`, profit margins, lapsed customers |
| E — Window functions | Q35–Q42 | `RANK`, `ROW_NUMBER`, `DENSE_RANK`, `LAG`, `NTILE`, running totals |
| F — Business intelligence | Q43–Q46 | view `monthly_sales_summary`, function `customer_completed_revenue()`, value bands, management report |

## Key results

- Completed revenue **KSh 24,155,371.70**, profit **KSh 2,890,921.70** (about 12% margin).
- Accessories: 4.5% of revenue but a **42% margin**. Every other category earns 10–11%.
- **62 orders were discounted below cost**, losing KSh 141,978.70.
- 28 customers (about a fifth of buyers) bring in **64% of revenue**.
- 47 buying customers have not ordered in over 90 days.
- Jan–Sep 2026 revenue is up about **86%** on Jan–Sep 2025.

The full discussion and recommendations are in [`insights.md`](insights.md).
