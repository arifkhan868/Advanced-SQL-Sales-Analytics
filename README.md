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
## 📂 Repository Structure
 queries/
- 01_sales_analysis.sql          - Sales by year/month, running totals, moving averages
- 02_product_performance.sql     - Product sales vs avg, YoY change
- 03_category_contribution.sql   - Category contribution %, cost segmentation
- 04_customer_segmentation.sql   - Customer VIP/Regular/New, age groups, KPIs
- 05_report_customer_view.sql    - Consolidated customer reporting view
- README.md

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
