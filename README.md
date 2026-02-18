# 📊 E-Commerce Performance & Crisis Investigation

![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge) ![Tools](https://img.shields.io/badge/Tools-Python%20|%20SQL%20|%20PowerBI-blue?style=for-the-badge)

## 📌 Project Overview
This project is not just a dashboard; it is a **full-scale data investigation** into a critical business anomaly.
> **The Problem:** The company achieved record-breaking revenue (**$389M**) in Q3, yet profitability plummeted, and Customer Satisfaction (CSAT) scores dropped to a critical low of **2.7/5**.

As a **Data Analyst**, I simulated a real-world scenario: taking raw, messy data, cleaning it programmatically, performing root cause analysis to find the "bleeding" points, and delivering strategic recommendations to the C-Suite.

---

## 🧪 Data Cleaning & Engineering Pipeline
*Standard Excel was insufficient for the volume and complexity of the raw data. I utilized **Python (Pandas)** to build a robust cleaning pipeline:*

### 1️⃣ Missing Values Strategy (Handling Nulls)
Categorized missing data into three specific actions based on business context:
* **Action A: Drop (Remove Data)**
    * Rows with missing `campaign_id` in Ad Spend (<0.5%) were dropped as spend cannot be attributed to a non-existent campaign.
    * Columns with 100% nulls (e.g., `internal_flag`) were removed entirely.
* **Action B: Impute (Fill Data)**
    * `utm_source`: Imputed with **'unknown'** to preserve total session counts for traffic analysis.
    * `gender`: Imputed with **'Unknown'** to keep these customers visible as a demographic segment.
    * `session_id` (Orders): Imputed with **'offline_or_missing'** to retain revenue data from Call Center orders or tracking failures.
* **Action C: Intentional Ignore (Keep as Null)**
    * `end_date`: Kept Null to indicate **Active/Ongoing** campaigns.
    * `customer_id`: Kept Null to represent **Guest/Anonymous Visitors**.

### 2️⃣ Standardization & Entity Mapping
Addressed inconsistent naming conventions to ensure accurate aggregation:
* **Text Normalization:** Converted all categorical text to lowercase (e.g., `MOBILE` → `mobile`) and trimmed "ghost" whitespaces.
* **Entity Mapping:**
    * *Traffic Sources:* Mapped `fb`, `Meta`, `facebook ads` → **`facebook`**.
    * *Payment Methods:* Mapped `cod`, `Cash` → **`cash on delivery`**.

### 3️⃣ Business Logic & Sanity Checks
Fixed data points that were technically valid but logically impossible:
* **Session "Time Travel":** Removed sessions with negative duration (End Time < Start Time) or extreme duration (> 6 hours) to prevent skewing averages.
* **Negative Financials:** Converted negative values in `price` or `shipping_cost` to absolute numbers (fixing data entry sign errors).
* **Logic Conflicts:** Removed campaigns where `end_date` was earlier than `start_date`.

### 4️⃣ Financial Accuracy Audit
* **Calculation Correction:** Discovered ~1% of orders had incorrect totals due to system errors. Overwrote `total_amount` using the formula:
    > $$(Subtotal + Shipping + Tax) - Discount$$
* **Orphan Orders:** Identified orders linked to non-existent `customer_id`. instead of deleting revenue, I set the ID to Null to attribute it to "Unknown Customer".

---

## 🛠️ Analysis Methodology

### 1️⃣ SQL (Root Cause Analysis) 🔍
Used **SQL** to perform hypothesis testing and validate insights found in the dashboard:
* **Geographic Analysis:** Compared sales performance between Cairo (Capital) and Delta regions to isolate the drop.
* **Device & Tech Analysis:** Identified a technical gap between **Mobile App** vs. **Desktop** users.
* **Payment Analysis:** Debunked the myth that "Cash on Delivery" drives cancellations.

### 2️⃣ Power BI (Interactive Dashboard) 📊
Built a dynamic report focused on actionable KPIs using:
* **DAX Measures:** Calculated complex metrics like `Cancellation Rate %`, `ROAS`, and `Attribution Loss`.
* **Data Storytelling:** Designed the layout to guide stakeholders from the "What" (Revenue) to the "Why" (The Bug).

---

## 🔍 Key Findings & "The Smoking Gun"

### 1. The Mobile App Failure (Delta Region) 📱
* **Observation:** Sales in Alexandria and Delta cities dropped by **~21%** post-August 15th.
* **Investigation:** Segmenting data by `Device_Type` revealed that **Desktop orders grew by 4.3%**, while **Mobile orders crashed by 33%**.
* **Conclusion:** The product and pricing are fine. The root cause is a **technical bug** in the Android App affecting checkout in specific regions.

### 2. The $117M Tracking Disaster 📉
* **Issue:** **30% of total revenue ($117M)** was flagged as "Unattributed."
* **Cause:** A Meta Pixel tracking failure occurred on Aug 15th, blinding the marketing team and wasting ad spend on unoptimized campaigns.

### 3. Myth Busting: Cash on Delivery 💵
* **Hypothesis:** Management believed COD customers caused high return rates.
* **Reality:** Data proved that COD actually holds the **lowest cancellation rate (12.9%)** compared to credit cards (13.1%), saving the company from a potentially damaging policy change.

---

## 📸 Dashboard & Evidence Previews

### 1. Executive Summary
*Visualizing the paradox of high revenue vs. low satisfaction.*
<img width="1328" height="630" alt="First_dashboard" src="https://github.com/user-attachments/assets/cf261a3c-4cdb-48d1-a753-1a3c73354a5e" />

---

## 🚀 Strategic Recommendations

Based on the analysis, the following action plan was proposed:
1.  **Technical:** Initiate an immediate **debugging sprint** for the Mobile App (Delta Region) to recover the 33% order loss.
2.  **Marketing:** Shift budget immediately from Google Ads (Low ROAS) to Facebook (High ROAS) and implement **CAPI (Conversion API)** to fix the tracking loss.
3.  **Customer Recovery:** Launch a "We are Sorry" campaign with free shipping vouchers for affected users in Alexandria/Port Said to restore CSAT scores.

---

## 📂 Repository Structure

* `📁 01_SQL_Scripts`: Queries used for investigation and hypothesis testing.
* `📁 02_Dashboard_Visuals`: Screenshots of the Power BI dashboard and key charts.
* `📁 03_Presentation`: The final executive presentation (PDF & HTML).
* `📁 Data_Sample`: A sample of the dataset structure (confidential data excluded).
* `📄 Data_Cleaning_Process.ipynb`: Python notebook documenting the cleaning steps.

---
**Author:** Mazen Ashraf
**Role:** Data Analyst
*(Open to work & Collaboration)*
