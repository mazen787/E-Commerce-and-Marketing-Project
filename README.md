# 📊 E-Commerce Performance & Crisis Investigation

![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge) ![Tools](https://img.shields.io/badge/Tools-Python%20|%20SQL%20|%20PowerBI-blue?style=for-the-badge)

## 📌 Project Overview
This project is not just a dashboard; it is a **full-scale data investigation** into a critical business anomaly.
> **The Problem:** The company achieved record-breaking revenue (**$389M**) in Q3, yet profitability plummeted, and Customer Satisfaction (CSAT) scores dropped to a critical low of **2.7/5**.

As a **Data Analyst**, I simulated a real-world scenario: taking raw, messy data, cleaning it programmatically, performing root cause analysis to find the "bleeding" points, and delivering strategic recommendations to the C-Suite.

---

## 🧪 Data Cleaning & Engineering Pipeline
*Standard Excel was insufficient for the volume of raw data. I utilized **Python (Pandas)** to implement a robust cleaning strategy:*

* **Handling Missing Data:** Deployed a hybrid strategy; **Imputed** critical fields (e.g., `utm_source`, `gender`) to preserve analytical value, while **Dropping** columns with 100% nulls or garbage data.
* **Entity Standardization:** Unified inconsistent naming conventions by mapping variations (e.g., `fb`, `Meta` → **`facebook`** / `cod` → **`cash on delivery`**) and normalizing text cases.
* **Logic & Integrity Checks:** Sanitized invalid records, including **negative session durations**, illogical campaign dates, and "time-travel" timestamps to ensure metric accuracy.
* **Financial Audit:** Detected system calculation errors in ~1% of orders. Re-engineered the `Total_Amount` column using the formula `(Subtotal + Shipping + Tax) - Discount` to ensure **100% revenue accuracy**.

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
