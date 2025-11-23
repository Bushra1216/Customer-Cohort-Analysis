# Non-Store Retail Customer Cohort and Retention Analysis

_Mapping customer behavior through retention patterns, churn identification, and spending trends to help retailers grow sustainable revenue and strengthen customer loyalty_

---

<h2><a class="anchor" id="overview"></a>Introduction</h2>
<p align=justify>
Retail businesses often struggle to understand why customers stop purchasing and which customer groups contribute most to the long-term revenue. Without clear visibility into retention, churn, and returning customer behavior—businesses cannot design effective strategies to sustain growth. Cohort Analysis is the process of analyzing customer behavior that allows us to gain a deeper understanding of customer movement and business performance by grouping individuals based on a shared characteristic—most commonly the month they made their first purchase and tracking their behavior over subsequent periods.

By analyzing Cohorts, businesses can-
- Identify churn and recovery behaviors of customer
- Detect retention patterns
- Understand spending trends across months

Monitoring these Cohorts help businesses pinpoint opportunities to improve customer engagement and revenue generation.
In this project, customers are segmented based on their first purchasing month and their activity is monitored across following months to gain valuable insights, which help measure the effectiveness of retention strategies and identify areas for improvement.<p>


<br>
<h2><a class="anchor" id="set_goal"></a>Aim Of The Project</h2>
<p align=justify>
The purpose of this project is to utilize Cohort Analysis across both customer and revenue dimensions to reveal how customer groups behave after acquisition and how their value changes over time. By observing how each cohort progresses over subsequent months, the analysis uncover insights into retention, churn, and spending behaviors of customer that support the effectiveness of their retention strategies and identify opportunities for improvement.

**🔸Customer-Level Cohort Analysis**<br>
By grouping customers into cohorts based on their initial purchase month, this examines how cohorts evolve over time in terms of customer count focusing on customer retention. Observing how many customers remain active in each cohort, businesses can evaluate the effectiveness of retention strategies, identify when and where customer begin to churn and highlight gaps in customer engagement. and uncover opportunities to re-engage lost customers.<br>

**🔸Revenue-Level Cohort Analysis**<br>
This component analyzes how revenue changes across different cohorts subsequent months. Examining revenue generation across cohorts, this will help businesses to identify cohorts that contribute significantly on revenue growth and detect declining cohorts that may require targeted marketing or retention efforts to enhance their value.<br>

Overall, this extensive analysis provides a clear understanding of customer lifetime value, customer retention behavior, and spending patterns. These insights enable retailers to implement targeted engagement strategies, reduce churn and improve revenue forecasting, that ultimately leading to profit and customer satisfaction.</p><br>

<h2><a class="anchor" id="workflow"></a>Project Workflow</h2>


This project follows a complete analytics workflow — including data preparation, extraction, modelling and visualization:

- **Data Preparation -** Cleaned and preprocessed UK based non-store retail dataset using Pandas, handling missing values, outliers, invalid quantity, and preparing refined data for analysis.

- **Loading Data into MSSQL Server -** Exported cleaned data from Python and imported into Microsoft SQL Server using `BULK INSERT` method

- **Perform Cohort Analysis -** Flag duplicates and filter out necessary records to implement cohort-based at both customer level and revenue level using sql queries.
  The cohort analysis serves as a powerful tool for comprehending customer behavior over time. When observing the table, several observations can be made:

- **Visualization in Power BI -** Imported the refined cohort tables into Power BI, built a calendar table, established relationship, and created DAX measures to calculate retained customers, lost customers and recovered customers. Then visualized customer movement and spending patterns over time to help retailers improve in retention and revenue generation.

<br>
<h2><a class="anchor" id="customerLevel"></a>Cohort Analysis based on Customer Counts</h2>

<p align=justify>
This analysis examines customer retention by counting distinct customers in each cohort across subsequent months. Cohorts are defined based on each customer's first purchase month, allowing us to track how long customers remain active after initial purchase. By observing changes in customer counts across different cohorts or months, this reveals key retention patterns such as when engagement drops or how different customer groups behave over time. This insight help retailers understand customer behavior trends, identify drop-off points and make targeted improvements to increase retention for long-term customer value. </p>

The normalized transaction data includes `InvoiceNo`, `StockCode`, `Description`, `Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country`, `Revenue` key fields and in this analysis we mainly focused on `InvoiceDate` and `CustomerID` attributes.

| InvoiceNo | StockCode |                         Description | Quantity | InvoiceDate | UnitPrice | CustomerID |        Country | Revenue |
|----------:|----------:|------------------------------------:|---------:|------------:|----------:|-----------:|---------------:|--------:|
| 536365    | 85123A    | WHITE HANGING HEART T-LIGHT HOLDER  | 6        | 2010-12-01  | 2.55      | 17850      | United Kingdom | 15.30   |
| 536365    | 71053     | WHITE METAL LANTERN                 | 6        | 2010-12-01  | 3.39      | 17850      | United Kingdom | 20.34   |
| 536365    | 84406B    | CREAM CUPID HEARTS COAT HANGER      | 8        | 2010-12-01  | 2.75      | 17850      | United Kingdom | 22.00   |
| 536365    | 84029G    | KNITTED UNION FLAG HOT WATER BOTTLE | 6        | 2010-12-01  | 3.39      | 17850      | United Kingdom | 20.34   |
| 536365    | 84029E    | RED WOOLLY HOTTIE WHITE HEART.      | 6        | 2010-12-01  | 3.39      | 17850      | United Kingdom | 20.34   |
| 536365    | 22752     | SET 7 BABUSHKA NESTING BOXES        | 2        | 2010-12-01  | 7.65      | 17850      | United Kingdom | 15.30   |
| 536365    | 21730     | GLASS STAR FROSTED T-LIGHT HOLDER   | 6        | 2010-12-01  | 4.25      | 17850      | United Kingdom | 25.50   |
| 536366    | 22633     | HAND WARMER UNION JACK              | 6        | 2010-12-01  | 1.85      | 17850      | United Kingdom | 11.10   |
| 536366    | 22632     | HAND WARMER RED POLKA DOT           | 6        | 2010-12-01  | 1.85      | 17850      | United Kingdom | 11.10   |
| 536367    | 84879     | ASSORTED COLOUR BIRD ORNAMENT       | 32       | 2010-12-01  | 1.69      | 13047      | United Kingdom | 54.08   |


**Query Breakdown:**
```sql
--In CTE1 we defined customer's purchasing date and first purchasing date as cohorts by customer id
WITH CTE AS(
     SELECT CustomerID, 
	        DATEFROMPARTS(YEAR(InvoiceDate),MONTH(InvoiceDate),1) AS Purchase_Date,
            MIN(DATEFROMPARTS(YEAR(InvoiceDate),MONTH(InvoiceDate),1)) 
			OVER(PARTITION BY CustomerID ORDER BY InvoiceDate) AS Cohort_Month
     FROM ##RETAIL_UNIQUE_DATA
),
--In CTE2 we find how far the purchase is from the cohort start-how many months since the first purchase.
CTE2 AS(
SELECT CustomerID, Purchase_Date, Cohort_Month,
       DATEDIFF(MONTH,Cohort_Month, Purchase_Date) AS Cohort_Index
FROM CTE
)
--Now count how many unique customers stayed active in each cohort month.
SELECT Cohort_Month, 
       Cohort_Index, 
	   COUNT(DISTINCT CustomerID) AS Active_Customers
INTO #CohortTable
FROM CTE2
GROUP BY Cohort_Month, Cohort_Index
ORDER BY Cohort_Month, Cohort_Index ASC;


  ```


Explanation:<br>
1. CTE - Determining Purchase Context:<br>
- `Purchase_Date`- Normalizes each transaction date (`InvoiceDate`) to the first day of its month(e.g., 2011-04-01)
- `Cohort_Month` - It defines initial purchase date as `Cohort Month` using a window function `MIN(...) OVER(...)` to assign every customer to their first purchase month, ensuring all later purchases are gouped under the correct cohort.
2. CTE2 - Calculating Cohort Index:<br>
- `Cohort Index` - Measures how many months have elapsed since the customer's first purchase.<br>
     Month_0 = First purchase month<br>
	 Month_1 = One month later<br>
	 Month_2...and so on, that helps to track how customer activity changes over time.
3. Final Query - Generating Cohort Table:<br>
- This will aggregate unique customers in each month since cohort formation.<br>

Now pivoting the result for matrix view

```sql
-- pivot to a matrix for visualization
SELECT Cohort_Month,
       [0] AS Month_0, 
	   [1] AS Month_1, 
	   [2] AS Month_2, 
	   [3] AS Month_3, 
	   [4] AS Month_4, 
	   [5] AS Month_5, 
       [6] AS Month_6, 
	   [7] AS Month_7, 
	   [8] AS Month_8, 
	   [9] AS Month_9,
	   [10] AS Month_10, 
	   [11] AS Month_11, 
	   [12] AS Month_12 INTO #pivoted_table
FROM #CohortTable
PIVOT(
     SUM(Active_Customers) 
	 FOR Cohort_Index IN ([0], [1], [2], [3], [4], [5], [6] , [7], [8], [9], [10], [11], [12])
) AS pivot_tbl;


-- view the result
SELECT * FROM #pivoted_table;

```

This will represent each row as `Cohort_Months` based on their first purchase month, columns will show how many months have passed since the initial purchase month (`Month_0`, `MOnth_1`, `Month_2`,...`Month_12`), and the values will show number of distinct customers count who made at least one purchase during that corresponding month index.<br><br>

**Outcome**

| Cohort_Month | Month_0 | Month_1 | Month_2 | Month_3 | Month_4 | Month_5 | Month_6 | Month_7 | Month_8 | Month_9 | Month_10 | Month_11 | Month_12 |
|--------------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|----------|----------|----------|
| 2010-12-01   | 885     | 324     | 286     | 340     | 321     | 352     | 321     | 309     | 313     | 350     | 331      | 445      | 235      |
| 2011-01-01   | 416     | 92      | 111     | 96      | 134     | 120     | 103     | 101     | 125     | 136     | 152      | 49       |          |
| 2011-02-01   | 380     | 71      | 71      | 108     | 103     | 94      | 96      | 106     | 94      | 116     | 26       |          |          |
| 2011-03-01   | 452     | 68      | 114     | 90      | 101     | 76      | 121     | 104     | 126     | 39      |          |          |          |
| 2011-04-01   | 300     | 64      | 61      | 63      | 59      | 68      | 65      | 78      | 22      |         |          |          |          |
| 2011-05-01   | 284     | 54      | 49      | 49      | 59      | 66      | 75      | 26      |         |         |          |          |          |
| 2011-06-01   | 242     | 42      | 38      | 64      | 56      | 81      | 23      |         |         |         |          |          |          |
| 2011-07-01   | 188     | 34      | 39      | 42      | 51      | 21      |         |         |         |         |          |          |          |
| 2011-08-01   | 169     | 35      | 42      | 41      | 21      |         |         |         |         |         |          |          |          |
| 2011-09-01   | 299     | 70      | 90      | 34      |         |         |         |         |         |         |          |          |          |
| 2011-10-01   | 358     | 86      | 41      |         |         |         |         |         |         |         |          |          |          |
| 2011-11-01   | 323     | 36      |         |         |         |         |         |         |         |         |          |          |          |
| 2011-12-01   | 41      |         |         |         |         |         |         |         |         |         |          |          |          |
