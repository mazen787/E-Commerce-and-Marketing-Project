select*from Clean_Dim_Campaigns
select*from Clean_Dim_Customers
select*from Clean_Fact_Ad_Spend
select*from Clean_Fact_Orders
select*from Clean_Fact_Sessions
select*from Clean_Fact_Support
-------------------------------------
/* EXECUTIVE SUMMARY 
*/

select Format(SUM(total_amount),'C') as Total_Revenue ,
COUNT(Distinct order_id) as Total_Orders ,
COUNT(Distinct customer_id) as Num_Of_Customers ,
Format((SUM(total_amount) / COUNT(distinct order_id)),'C') as Average_Order_Value ,
Cast(SUM(Case When order_status = 'Cancelled' Then 1 Else 0 End) *100 / COUNT(order_id) As decimal(10,2)) as Cancellation_Rate

from Clean_Fact_Orders




/* DEVICE PERFORMANCE DEEP DIVE
*/

WITH Traffic_Metrics AS (
    SELECT 
        device_type,
        COUNT(DISTINCT session_id) AS Total_Sessions
    FROM Clean_Fact_Sessions
    GROUP BY device_type
),

Sales_Metrics AS (
    SELECT 
        S.device_type,
        COUNT(DISTINCT O.order_id) AS Total_Orders,
        SUM(O.total_amount) AS Total_Revenue
    FROM Clean_Fact_Orders O
    JOIN Clean_Fact_Sessions S ON O.session_id = S.session_id
    WHERE O.order_status != 'Cancelled' -- »‰Õ”» »” «·√Ê—œ—«  «·ÕﬁÌﬁÌ…
    GROUP BY S.device_type
)

SELECT 
    T.device_type,
    T.Total_Sessions,
    ISNULL(S.Total_Orders, 0) AS Total_Orders,  
    
    CAST((ISNULL(S.Total_Orders, 0) * 100.0 / T.Total_Sessions) AS DECIMAL(10,2)) AS Conversion_Rate_Pct,
    
    FORMAT(ISNULL(S.Total_Revenue, 0) / T.Total_Sessions, 'C', 'en-US') AS Rev_Per_Session

FROM Traffic_Metrics T
LEFT JOIN Sales_Metrics S ON T.device_type = S.device_type
ORDER BY Conversion_Rate_Pct DESC;




/* MARKETING CHANNEL PERFORMANCE
*/

SELECT 
    CASE 
        WHEN utm_source IS NULL THEN 'Organic/Direct'
        ELSE utm_source 
    END AS Marketing_Channel,

    
    COUNT(DISTINCT sess.session_id) AS Total_Sessions,
    COUNT(DISTINCT ord.order_id) AS Total_Orders,
    
    FORMAT(SUM(ord.total_amount), 'C', 'en-US') AS Channel_Revenue,
    
    FORMAT(AVG(ord.total_amount), 'C', 'en-US') AS AOV

FROM Clean_Fact_Sessions sess
JOIN Clean_Fact_Orders ord ON sess.session_id = ord.session_id
GROUP BY 
    CASE 
        WHEN utm_source IS NULL THEN 'Organic/Direct'
        ELSE utm_source 
    END
ORDER BY Total_Orders DESC;






/* MARKETING ROI & ROAS ANALYSIS
   ROAS = Revenue / Spend
*/

WITH Spend_Metrics AS (
    SELECT 
        platform,
        SUM(spend_amount) AS Total_Spend
    FROM Clean_Fact_Ad_Spend
    GROUP BY platform
),

Revenue_Metrics AS (
    SELECT 
        utm_source AS platform,
        SUM(O.total_amount) AS Total_Revenue
    FROM Clean_Fact_Sessions S
    JOIN Clean_Fact_Orders O ON S.session_id = O.session_id
    WHERE utm_source IS NOT NULL
    GROUP BY utm_source
)

SELECT 
    R.platform,
    
    FORMAT(S.Total_Spend, 'C', 'en-US') AS Cost,
    FORMAT(R.Total_Revenue, 'C', 'en-US') AS Revenue,
    
    CAST((R.Total_Revenue / NULLIF(S.Total_Spend, 0)) AS DECIMAL(10,2)) AS ROAS

FROM Revenue_Metrics R
JOIN Spend_Metrics S ON R.platform = S.platform -- »‰—»ÿ »«”„ «·„‰’…
ORDER BY ROAS DESC;





SELECT DISTINCT 'From Ad Spend Table' as Source, platform as Name FROM Clean_Fact_Ad_Spend
UNION ALL
SELECT DISTINCT 'From Sessions Table' as Source, utm_source as Name FROM Clean_Fact_Sessions
WHERE utm_source IS NOT NULL;




/* MARKETING ROI & ROAS ANALYSIS (Final Fixed Version)
*/

WITH Spend_Metrics AS (
    SELECT 
        CASE 
            WHEN platform LIKE '%Facebook%' THEN 'facebook'   
            WHEN platform LIKE '%Instagram%' THEN 'instagram' 
            WHEN platform LIKE '%Google%' THEN 'google'      
            WHEN platform LIKE '%TikTok%' THEN 'tiktok'      
            ELSE LOWER(platform)                             
        END AS clean_platform,
        
        SUM(spend_amount) AS Total_Spend
    FROM Clean_Fact_Ad_Spend
    GROUP BY 
        CASE 
            WHEN platform LIKE '%Facebook%' THEN 'facebook'
            WHEN platform LIKE '%Instagram%' THEN 'instagram'
            WHEN platform LIKE '%Google%' THEN 'google'
            WHEN platform LIKE '%TikTok%' THEN 'tiktok'
            ELSE LOWER(platform)
        END
),

Revenue_Metrics AS (
    SELECT 
        LOWER(utm_source) AS platform,
        SUM(O.total_amount) AS Total_Revenue
    FROM Clean_Fact_Sessions S
    JOIN Clean_Fact_Orders O ON S.session_id = O.session_id
    WHERE utm_source IS NOT NULL
    GROUP BY LOWER(utm_source)
)

SELECT 
    ISNULL(R.platform, S.clean_platform) AS Platform,
    
    FORMAT(ISNULL(S.Total_Spend, 0), 'C', 'en-US') AS Cost,
    FORMAT(ISNULL(R.Total_Revenue, 0), 'C', 'en-US') AS Revenue,
    
    CASE 
        WHEN S.Total_Spend = 0 OR S.Total_Spend IS NULL THEN 0 
        ELSE CAST((R.Total_Revenue / S.Total_Spend) AS DECIMAL(10,2)) 
    END AS ROAS

FROM Revenue_Metrics R
FULL OUTER JOIN Spend_Metrics S ON R.platform = S.clean_platform
ORDER BY ROAS DESC;





/* CUSTOMER LOYALTY ANALYSIS
*/

WITH Customer_Frequency AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS Order_Count
    FROM Clean_Fact_Orders
    WHERE order_status != 'Cancelled' 
    GROUP BY customer_id
)

SELECT 
    CASE 
        WHEN Order_Count = 1 THEN 'One-Time Buyer'
        WHEN Order_Count = 2 THEN 'Returning Customer'
        WHEN Order_Count BETWEEN 3 AND 5 THEN 'Loyal Customer'
        ELSE 'VIP Customer (6+)'
    END AS Loyalty_Segment,
    
    COUNT(customer_id) AS Customer_Count,
    
    CAST(COUNT(customer_id) * 100.0 / (SELECT COUNT(*) FROM Customer_Frequency) AS DECIMAL(10,2)) AS Percentage

FROM Customer_Frequency
GROUP BY 
    CASE 
        WHEN Order_Count = 1 THEN 'One-Time Buyer'
        WHEN Order_Count = 2 THEN 'Returning Customer'
        WHEN Order_Count BETWEEN 3 AND 5 THEN 'Loyal Customer'
        ELSE 'VIP Customer (6+)'
    END
ORDER BY Customer_Count DESC;







/* PRODUCT CATEGORY PERFORMANCE
*/

SELECT 
    product_category,
    
    COUNT(order_id) AS Total_Orders,
    
    FORMAT(SUM(total_amount), 'C', 'en-US') AS Total_Revenue,
    
    CAST(SUM(total_amount) * 100.0 / (SELECT SUM(total_amount) FROM Clean_Fact_Orders) AS DECIMAL(10,2)) AS Revenue_Share_Pct,

    CAST(
        SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(order_id) 
    AS DECIMAL(10,2)) AS Cancellation_Rate_Pct

FROM Clean_Fact_Orders
GROUP BY product_category
ORDER BY Revenue_Share_Pct DESC;




/*  MONTHLY SALES TREND
*/

SELECT 
    FORMAT(order_date, 'yyyy-MM') AS Sales_Month,
    
    COUNT(order_id) AS Orders_Count,
    
    FORMAT(SUM(total_amount), 'C', 'en-US') AS Revenue

FROM Clean_Fact_Orders
WHERE order_status != 'Cancelled' 
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY Sales_Month;




/* TOP CITIES BY REVENUE
*/

SELECT TOP 10
    C.city,
    COUNT(O.order_id) AS Total_Orders,
    FORMAT(SUM(O.total_amount), 'C', 'en-US') AS Total_Revenue

FROM Clean_Fact_Orders O
JOIN Clean_Dim_Customers C ON O.customer_id = C.customer_id
WHERE O.order_status != 'Cancelled'
GROUP BY C.city
ORDER BY SUM(O.total_amount) DESC;







/*  MONTH-OVER-MONTH GROWTH ANALYSIS
*/

WITH Monthly_Sales AS (
    -- 1.  Ã„Ì⁄ «·„»Ì⁄«  »«·‘ÂÊ—
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS Sales_Month,
        SUM(total_amount) AS Current_Revenue
    FROM Clean_Fact_Orders
    WHERE order_status != 'Cancelled'
    GROUP BY FORMAT(order_date, 'yyyy-MM')
)

SELECT 
    Sales_Month,
    FORMAT(Current_Revenue, 'C', 'en-US') AS Revenue,
    
    FORMAT(
        LAG(Current_Revenue) OVER (ORDER BY Sales_Month), 
    'C', 'en-US') AS Previous_Month_Revenue,
    
    FORMAT(
        (Current_Revenue - LAG(Current_Revenue) OVER (ORDER BY Sales_Month)) 
        / NULLIF(LAG(Current_Revenue) OVER (ORDER BY Sales_Month), 0),
    'P') AS Growth_Rate 

FROM Monthly_Sales;







/* CUSTOMER PURCHASE FREQUENCY (Time Between Orders)
   Technique: LAG + DATEDIFF + CTEs
*/

WITH Next_Order_Calc AS (
    SELECT 
        customer_id,
        order_date,
        
        LAG(order_date) OVER (
            PARTITION BY customer_id 
            ORDER BY order_date
        ) AS Previous_Order_Date

    FROM Clean_Fact_Orders
    WHERE order_status != 'Cancelled' 
),

Diff_Calculation AS (
    SELECT 
        customer_id,
        order_date,
        Previous_Order_Date,
        
        DATEDIFF(day, Previous_Order_Date, order_date) AS Days_Gap
    
    FROM Next_Order_Calc
    WHERE Previous_Order_Date IS NOT NULL 
)

SELECT 
    AVG(Days_Gap) AS Avg_Days_To_Return, 
    MIN(Days_Gap) AS Min_Days,           
    MAX(Days_Gap) AS Max_Days            

FROM Diff_Calculation;





/* Query 1: City Performance - Pre vs Post Issue
   Tables Used: Clean_Fact_Orders, Clean_Dim_Customers
*/

WITH Period_Analysis AS (
    SELECT 
        c.city,
        CASE 
            WHEN o.order_date < '2025-08-15' THEN '1. Pre-Issue'
            ELSE '2. Post-Issue' 
        END AS Time_Period,
        COUNT(o.order_id) AS Total_Orders,
        COUNT(DISTINCT o.order_date) AS Days_Count
    FROM Clean_Fact_Orders o
    JOIN Clean_Dim_Customers c ON o.customer_id = c.customer_id
    WHERE o.order_date BETWEEN '2025-07-15' AND '2025-09-15' -- „ﬁ«—‰… ‘Â— ﬁ»· Ê‘Â— »⁄œ
    GROUP BY c.city, 
             CASE 
                WHEN o.order_date < '2025-08-15' THEN '1. Pre-Issue'
                ELSE '2. Post-Issue' 
             END
)

SELECT 
    city,
    Time_Period,
    Total_Orders,
    (Total_Orders * 1.0 / Days_Count) AS Avg_Daily_Orders 
FROM Period_Analysis
WHERE city IN ('Cairo', 'Alexandria', 'Tanta', 'Mansoura', 'Port Said')
ORDER BY city, Time_Period;








/* Query 2: Device Type Breakdown in Affected Regions
   Tables Used: Clean_Fact_Orders, Clean_Fact_Sessions, Clean_Dim_Customers
*/

SELECT 
    s.device_type, -- (Mobile / Desktop)
    CASE 
        WHEN o.order_date < '2025-08-15' THEN 'Pre-Issue'
        ELSE 'Post-Issue' 
    END AS Time_Period,
    COUNT(o.order_id) AS Total_Orders
FROM Clean_Fact_Orders o
JOIN Clean_Fact_Sessions s ON o.session_id = s.session_id 
JOIN Clean_Dim_Customers c ON o.customer_id = c.customer_id
WHERE 
    c.city IN ('Alexandria', 'Tanta', 'Mansoura', 'Port Said') 
    AND o.order_date BETWEEN '2025-07-15' AND '2025-09-15'
GROUP BY s.device_type, 
         CASE 
            WHEN o.order_date < '2025-08-15' THEN 'Pre-Issue'
            ELSE 'Post-Issue' 
         END
ORDER BY s.device_type, Time_Period;







/* Query 3: Payment Method Quality Analysis
   Objective: Identify if Cash (COD) correlates with higher cancellations or lower CSAT.
*/

SELECT 
    o.payment_method,
    COUNT(o.order_id) AS Total_Orders,
    
    SUM(CASE WHEN o.order_status IN ('Cancelled', 'Returned', 'Refunded') THEN 1 ELSE 0 END) AS Canceled_Orders,
    (SUM(CASE WHEN o.order_status IN ('Cancelled', 'Returned', 'Refunded') THEN 1 ELSE 0 END) * 100.0 / COUNT(o.order_id)) AS Cancel_Rate_Pct,

    AVG(t.csat_score) AS Avg_CSAT_Score

FROM Clean_Fact_Orders o
LEFT JOIN Clean_Fact_Support t ON o.order_id = t.order_id
GROUP BY o.payment_method
ORDER BY Cancel_Rate_Pct DESC;