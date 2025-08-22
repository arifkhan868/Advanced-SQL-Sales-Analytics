# Advanced-SQL-Sales-Analytics
End-to-end PostgreSQL project analyzing sales, products, and customers with advanced SQL (CTEs, window functions, segmentation, KPIs, and reporting views) for BI-ready insights.
---
## 🚀 Advanced Sales & Customer Analytics SQL Project🚀
---
## 🔎 Project Overview

This project demonstrates end-to-end advanced SQL analytics on sales, products, and customer data using PostgreSQL.

It covers:

Sales performance analysis over time (monthly/yearly)

Product performance & growth insights

Category contribution & cost segmentation

Customer segmentation, KPIs, and reporting views

Goal: Build a BI-ready dataset and generate insights for business decision-making.
Audience: Data Analysts, BI Engineers, Data Science aspirants, SQL enthusiasts.

---
## 🏗️ Database Model

Tables:

gold.sales → Order-level transactions (order_date, sales_amount, quantity, price, product_key, customer_key)

gold.products → Product info (product_name, category, cost, price)

gold.customers → Customer info (customer_number, first_name, last_name, birthdate)

Relationships:

sales.product_key → products.product_key

sales.customer_key → customers.customer_key

View Created:

gold.report_customer → Aggregated customer-level dataset for BI reporting

---
## 📈 Analysis Performed
1️⃣ Sales Performance

- Total sales by year & month

- Running totals with SUM() OVER(ORDER BY ...)

- Moving average of prices (1-month, 3-month)

- Identifies trends and seasonality in sales

2️⃣ Product Insights

- Yearly sales per product compared to average product performance

- Year-over-year (YoY) growth using LAG()

- Product category contribution to total sales

- Cost-based segmentation (<100, 100–500, 500–1000, >1000)

3️⃣ Customer Analytics

- Segmentation based on spending & activity history:

- VIP → ≥ 12 months active & spending > €5000

- Regular → ≥ 12 months active & spending ≤ €5000

- New → < 12 months active

- Age group segmentation (<20, 20–29, 30–39, 40–49, 50+)

Key KPIs:

- Recency (months since last purchase)

- Lifespan (months active)

- Average Order Value (AOV)

- Average Monthly Spend

- Total Orders, Products, Quantity

4️⃣ Reporting View

- gold.report_customer consolidates:

- Customer demographics, segment, KPIs, and transactional metrics

- Ready-to-use for BI dashboards (Power BI, Tableau, Looker, etc.)

---
## ⚙️ Tech Stack

- Database: PostgreSQL

- Tooling: DBeaver (SQL IDE)

- Language: SQL

















