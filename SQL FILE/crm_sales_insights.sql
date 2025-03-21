USE crm_sales_db;

#----------------------------------------------------------------------------Basic Data Overview----------------------------------------------------------------------------------------------------
# Total number of accounts
SELECT COUNT(*) AS total_accounts 
FROM accounts_cleaned;

# Total number of products
SELECT COUNT(*) AS total_products 
FROM products_cleaned;

#Total sales agents
SELECT COUNT(DISTINCT sales_agent) AS total_sales_agents 
FROM sales_teams_cleaned;

#-------------------------------------------------------------------------Sales Performance Analysis-----------------------------------------------------------------------------------------------
# Total revenue generated (closed deals)
SELECT SUM(close_value) AS total_revenue 
FROM sales_pipeline_cleaned 
WHERE deal_stage = 'Won';

#Number of deals in each stage
SELECT deal_stage, COUNT(*) AS total_deals 
FROM sales_pipeline_cleaned 
GROUP BY deal_stage 
ORDER BY total_deals DESC;

#-------------------------------------------------------------------------Regional Sales Performance----------------------------------------------------------------------------------------------
# Revenue per regional office
SELECT 
    st.regional_office, SUM(sp.close_value) AS total_revenue
FROM
    sales_pipeline_cleaned sp
        JOIN
    sales_teams_cleaned st ON sp.sales_agent = st.sales_agent
WHERE
    sp.deal_stage = 'Won'
GROUP BY st.regional_office
ORDER BY total_revenue DESC;

#--------------------------------------------------------------------------Sales Performance Analysis----------------------------------------------------------------------------------------------
# Top Performing Sales Agents (Revenue Contribution)
SELECT s.sales_agent, 
       SUM(sp.close_value) AS total_sales_value, 
       COUNT(sp.opportunity_id) AS total_deals
FROM sales_pipeline_cleaned sp
JOIN sales_teams_cleaned s ON sp.sales_agent = s.sales_agent
WHERE sp.deal_stage = 'Won'
GROUP BY s.sales_agent
ORDER BY total_sales_value DESC
LIMIT 10;

#---------------------------------------------------------------------------Time-Based Analysis----------------------------------------------------------------------------------------------
# Monthly Revenue Trends (YoY Growth)
SELECT 
    EXTRACT(YEAR FROM close_date) AS year,
    EXTRACT(MONTH FROM close_date) AS month,
    SUM(close_value) AS monthly_revenue
FROM sales_pipeline_cleaned
WHERE deal_stage = 'Won'
GROUP BY year, month
ORDER BY year DESC, month DESC;

#----------------------------------------------------------------------------Product Insights-------------------------------------------------------------------------------------------------
# Best-Selling Product Series
SELECT p.series, 
       COUNT(sp.opportunity_id) AS total_sales, 
       SUM(sp.close_value) AS revenue_generated
FROM sales_pipeline_cleaned sp
JOIN products_cleaned p ON sp.product = p.product
WHERE sp.deal_stage = 'Won'
GROUP BY p.series
ORDER BY revenue_generated DESC
LIMIT 5;

#--------------------------------------------------------------------Sales Agent Performance with Regional Comparison------------------------------------------------------------------------
# Sales Performance by Regional Office
SELECT st.regional_office, 
       st.manager, 
       COUNT(sp.opportunity_id) AS total_deals_closed,
       SUM(sp.close_value) AS total_revenue
FROM sales_pipeline_cleaned sp
JOIN sales_teams_cleaned st ON sp.sales_agent = st.sales_agent
WHERE sp.deal_stage = 'Won'
GROUP BY st.regional_office, st.manager
ORDER BY total_revenue DESC;

#-------------------------------------------------------------------------Sales Funnel Effectiveness Analysis-----------------------------------------------------------------------------
# Conversion Rates by Deal Stage
SELECT deal_stage, 
       COUNT(opportunity_id) AS total_opportunities,
       SUM(close_value) AS potential_revenue,
       ROUND( (COUNT(opportunity_id) * 100.0) / 
              SUM(COUNT(opportunity_id)) OVER (), 2) AS conversion_percentage
FROM sales_pipeline_cleaned
GROUP BY deal_stage
ORDER BY conversion_percentage DESC;