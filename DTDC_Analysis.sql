-- DTDC Courier Insights: A Comprehensive SQL-Based Logistics Analysis

CREATE DATABASE dtdc_logistics;
USE dtdc_logistics;

CREATE TABLE shipments (
  consignment_no VARCHAR(100) PRIMARY KEY,
  pouch_no VARCHAR(100),
  origin VARCHAR(100),
  destination VARCHAR(100),
  mode VARCHAR(50),
  mode_of_payment VARCHAR(50),
  nature_of_consign VARCHAR(20),
  chargeable_wt FLOAT,
  booking_code VARCHAR(50),
  expiry_date DATE);
  
CREATE TABLE senders (
  consignment_no VARCHAR(100),
  sender_name VARCHAR(100),
  sender_phone VARCHAR(20),
  sender_address TEXT,
  sender_city VARCHAR(100),
  sender_state VARCHAR(100),
  sender_pincode VARCHAR(10),
  sender_gstin VARCHAR(20),
  sender_date DATE,
  sender_signature VARCHAR(100),
  FOREIGN KEY (consignment_no) REFERENCES shipments(consignment_no));
  
CREATE TABLE receivers (
  consignment_no VARCHAR(100),
  recipient_name VARCHAR(100),
  receiver_name VARCHAR(100),
  recipient_phone VARCHAR(20),
  recipient_address TEXT,
  recipient_city VARCHAR(100),
  receiver_state VARCHAR(100),
  receiver_pincode VARCHAR(10),
  recipient_gstin VARCHAR(20),
  receive_date DATE,
  relationship VARCHAR(50),
  company_stamp VARCHAR(100),
  receiver_signature VARCHAR(100),
  FOREIGN KEY (consignment_no) REFERENCES shipments(consignment_no));
  
CREATE TABLE shipment_metrics (
  consignment_no VARCHAR(100),
  total_pieces INT,
  actual_wt FLOAT,
  volumetric_wt FLOAT,
  tariff FLOAT,
  vas_charges FLOAT,
  total_amount FLOAT,
  paperwork TEXT,
  value_added_services TEXT,
  description TEXT,
  risk_surcharge VARCHAR(50),
  FOREIGN KEY (consignment_no) REFERENCES shipments(consignment_no));
  
-- 1. What is the average turnaround time and standard deviation per mode of transport?
SELECT 
    sh.mode AS mode_of_transport, 
    ROUND(AVG(DATEDIFF(r.receive_date, s.sender_date)), 2) AS average_turnaround_time,
	ROUND(STDDEV_POP(DATEDIFF(r.receive_date, s.sender_date)),2) AS Standard_deviation
FROM shipments sh
JOIN senders s ON sh.consignment_no = s.consignment_no
JOIN receivers r ON sh.consignment_no = r.consignment_no
GROUP BY sh.mode;

-- 2. How many consignments were handled per day?
SELECT 
    DATE(s.sender_date) AS consignment_date,
	COUNT(s.consignment_no) AS total_consignments
FROM senders s
JOIN receivers r ON s.consignment_no = r.consignment_no
GROUP BY DATE(s.sender_date)
ORDER BY consignment_date, total_consignments DESC;

-- 3. Max and min number of consignments handled per day?
WITH Daily_Consignment_Count AS (
    SELECT
        DATE(s.sender_date) AS consignment_date,
        COUNT(s.consignment_no) AS total_consignments
    FROM senders s
    JOIN receivers r ON s.consignment_no = r.consignment_no
    GROUP BY DATE(s.sender_date)),
MaxMin AS (
    SELECT 
        consignment_date, total_consignments,
        RANK() OVER (ORDER BY total_consignments DESC) AS max_rank,
        RANK() OVER (ORDER BY total_consignments ASC) AS min_rank
    FROM Daily_Consignment_Count)
SELECT 
    MAX(CASE WHEN max_rank = 1 THEN consignment_date END) AS max_consignment_day,
    MAX(CASE WHEN max_rank = 1 THEN total_consignments END) AS max_consignment_count,
    MAX(CASE WHEN min_rank = 1 THEN consignment_date END) AS min_consignment_day,
    MAX(CASE WHEN min_rank = 1 THEN total_consignments END) AS min_consignment_count
FROM MaxMin;

-- 4. Number of days where number of consignments are above average
WITH Daily_consignment AS (
    SELECT
        DATE(s.sender_date) AS consignment_date,
        COUNT(s.consignment_no) AS total_consignments
    FROM senders s
    JOIN receivers r ON s.consignment_no = r.consignment_no
    GROUP BY DATE(s.sender_date)),
Stats AS (
    SELECT AVG(total_consignments) AS avg_consignments FROM Daily_consignment)
SELECT COUNT(*) AS day_count
FROM Daily_consignment, Stats
WHERE Daily_consignment.total_consignments > Stats.avg_consignments;

-- 5. Which top 5 booking codes experience higher delivery times across cities?
SELECT
    sh.booking_code,
    r.recipient_city,
    ROUND(AVG(DATEDIFF(r.receive_date, s.sender_date)),2) AS total_delivery_days,
    COUNT(*) AS total_consignments
FROM shipments sh 
JOIN senders s ON s.consignment_no = sh.consignment_no
JOIN receivers r ON r.consignment_no = sh.consignment_no
WHERE s.sender_date IS NOT NULL AND r.receive_date IS NOT NULL
GROUP BY sh.booking_code, r.recipient_city
ORDER BY total_delivery_days DESC;

-- 6. Identify count of shipments where the delivery gap (receive_date - sender_date) is unusually high compared to similar routes.
WITH route_avg AS (
  SELECT 
    s.sender_city,
    r.recipient_city,
    ROUND(AVG(DATEDIFF(r.receive_date, s.sender_date)),2) AS avg_delivery_days,
    ROUND(STDDEV_POP(DATEDIFF(r.receive_date, s.sender_date)),2) AS stddev_delivery_days
  FROM senders s
  JOIN receivers r ON s.consignment_no = r.consignment_no
  WHERE r.receive_date IS NOT NULL
  GROUP BY s.sender_city, r.recipient_city),
consignment_gap AS (
  SELECT 
    s.consignment_no,
    s.sender_city,
    r.recipient_city,
    DATEDIFF(r.receive_date, s.sender_date) AS delivery_days
  FROM senders s
  JOIN receivers r ON s.consignment_no = r.consignment_no
  WHERE r.receive_date IS NOT NULL),
flagged_consignments AS (
  SELECT 
    sg.consignment_no,
    sg.sender_city,
    sg.recipient_city,
    sg.delivery_days,
    ra.avg_delivery_days,
    ra.stddev_delivery_days,
    (sg.delivery_days - ra.avg_delivery_days) AS deviation_from_avg
  FROM consignment_gap sg
  JOIN route_avg ra ON sg.sender_city = ra.sender_city AND sg.recipient_city = ra.recipient_city),
total as (
SELECT * FROM flagged_consignments
WHERE deviation_from_avg > 2 
ORDER BY deviation_from_avg DESC)
SELECT COUNT(consignment_no) AS cosignment_count FROM total;

-- 7. Segment by mode of transport and routes, which route suffers most delays in terms of delivery gap and volume of consignments
SELECT 
    s.sender_city,
    r.recipient_city,
    ROUND(AVG(DATEDIFF(r.receive_date, s.sender_date)), 2) AS avg_delivery_days,
    ROUND(STDDEV_POP(DATEDIFF(r.receive_date, s.sender_date)), 2) AS stddev_delivery_days,
    COUNT(CASE WHEN sh.mode = 'Air_cargo' THEN sh.consignment_no END) AS air_cargo_count,
    COUNT(CASE WHEN sh.mode = 'Surface' THEN sh.consignment_no END) AS surface_count,
    COUNT(CASE WHEN sh.mode = 'Express' THEN sh.consignment_no END) AS express_count,
    COUNT(sh.consignment_no) AS total_consignments
FROM senders s
JOIN receivers r ON s.consignment_no = r.consignment_no
JOIN shipments sh ON s.consignment_no = sh.consignment_no
WHERE r.receive_date IS NOT NULL
GROUP BY s.sender_city, r.recipient_city
ORDER BY avg_delivery_days DESC LIMIT 5;

-- 8. Which top 5 routes operate with the lowest cost-per-kg (high efficiency)?
SELECT 
sh.origin,
sh.destination,
ROUND(SUM(shm.total_amount)/SUM(shm.actual_wt),2) AS cost_per_kg
FROM shipments sh
JOIN shipment_metrics shm ON sh.consignment_no = shm.consignment_no
GROUP BY sh.origin, sh.destination
ORDER BY cost_per_kg ASC LIMIT 5;

-- 9. Which top 5 routes operate with the highest cost-per-kg (Low efficiency)
SELECT 
sh.origin,
sh.destination,
ROUND(SUM(shm.total_amount)/SUM(shm.actual_wt),2) AS cost_per_kg
FROM shipments sh
JOIN shipment_metrics shm ON sh.consignment_no = shm.consignment_no
GROUP BY sh.origin, sh.destination
ORDER BY cost_per_kg DESC LIMIT 5;

-- 10. Which routes have the highest consignment volume and weight?
SELECT 
    sh.origin,
    r.recipient_city,
    COUNT(*) AS consignment_volume,
    ROUND(SUM(sm.actual_wt),2) AS total_weight,
    ROUND(SUM(sm.total_amount),2) as Revenue
FROM senders s
JOIN receivers r ON s.consignment_no = r.consignment_no
JOIN shipments sh ON s.consignment_no = sh.consignment_no
JOIN shipment_metrics sm ON s.consignment_no = sm.consignment_no
GROUP BY sh.origin, r.recipient_city
ORDER BY consignment_volume DESC, total_weight DESC LIMIT 5;

-- 11. What is the average cost per kg by mode?
SELECT 
	sh.mode AS mode_of_transport,
    ROUND(AVG(shm.total_amount/sh.chargeable_wt),2) AS average_cost_per_kg
FROM shipments sh
JOIN shipment_metrics shm ON sh.consignment_no = shm.consignment_no
GROUP BY mode_of_transport;

-- 12. Which cities (origin/destination) consistently incur higher VAS charges?
SELECT 
  s.sender_city,
  r.recipient_city,
  ROUND(AVG(shm.vas_charges),2) AS avg_vas_charges,
  COUNT(*) AS consignment_count
FROM senders s
JOIN receivers r ON s.consignment_no = r.consignment_no
JOIN shipment_metrics shm ON shm.consignment_no = r.consignment_no
GROUP BY s.sender_city, r.recipient_city
ORDER BY avg_vas_charges DESC
LIMIT 10;

-- 13. Find % of total revenue spent on VAS:
WITH total as (
SELECT 
SUM(vas_charges) AS total_vas_charges,
SUM(total_amount) AS total_amount
FROM shipment_metrics)
SELECT
ROUND(((total_vas_charges*100)/total_amount),2) AS percent_revenue_spent_on_vas
FROM total;

-- 14. What is the total % revenue generated from each sender state and mode combination?
WITH total AS(
SELECT 
    s.sender_state,
    ROUND(SUM(shm.total_amount),2) AS total_revenue,
    ROUND(SUM(CASE WHEN sh.mode = 'Air Cargo' THEN shm.total_amount ELSE 0 END),2) AS air_cargo_revenue,
    ROUND(SUM(CASE WHEN sh.mode = 'Express' THEN shm.total_amount ELSE 0 END),2) AS express_revenue,
    ROUND(SUM(CASE WHEN sh.mode = 'Surface' THEN shm.total_amount ELSE 0 END),2) AS surface_revenue
FROM senders s
JOIN shipment_metrics shm ON s.consignment_no = shm.consignment_no
JOIN shipments sh ON s.consignment_no = sh.consignment_no
GROUP BY s.sender_state)
SELECT
	sender_state,
	ROUND((air_cargo_revenue*100/total_revenue),2) AS percent_air_cargo_revenue,
	ROUND((express_revenue*100/total_revenue),2) AS percent_express_revenue,
	ROUND((surface_revenue*100/total_revenue),2) AS percent_surface_revenue
FROM total;

-- 15. Total revenue, VAS charge margin and profitability index of each mode of transport and correlation with volume of consignments
SELECT 
	sh.mode,
	ROUND(SUM(shm.total_amount),2) AS total_revenue,
	ROUND(SUM(vas_charges*100)/SUM(shm.total_amount),2) AS percent_vas_charge,
	COUNT(shm.consignment_no) AS volume,
	ROUND((SUM(shm.total_amount))/(COUNT(shm.consignment_no)),2)AS profitability_index
FROM shipments sh
JOIN shipment_metrics shm ON sh.consignment_no = shm.consignment_no
GROUP BY sh.mode;

-- 16. Identify top 5 senders state contributing highest total revenue across all consignments, their vas charge margin and profitability index
SELECT 
s.sender_state,
ROUND(SUM(shm.total_amount),2) AS total_revenue,
COUNT(s.consignment_no) AS consignment_count,
ROUND(((SUM(shm.vas_charges)*100)/SUM(shm.total_amount)),2) AS percent_vas_charge_margin,
ROUND((SUM(shm.total_amount))/(COUNT(shm.consignment_no)),2)AS profitability_index
FROM senders s
JOIN shipment_metrics shm ON s.consignment_no = shm.consignment_no
JOIN shipments sh ON s.consignment_no = sh.consignment_no
GROUP BY s.sender_state
ORDER BY total_revenue DESC LIMIT 5;

-- 17. Count Consignments where chargeable_wt deviates significantly > 2kg from actual_wt.
WITH total AS (
SELECT 
	shm.consignment_no,
    Round((sh.chargeable_wt - shm.actual_wt),2) AS deviation
FROM shipment_metrics shm
JOIN shipments sh ON sh.consignment_no = shm.consignment_no
WHERE Round((sh.chargeable_wt - shm.actual_wt),2) > 2
ORDER BY deviation DESC)
SELECT COUNT(consignment_no) AS major_deviation 
FROM total;

-- 18. Which routes + mode combinations generate high revenue but have low consignment volume?
SELECT
sh.origin,
sh.destination,
sh.mode,
ROUND(SUM(shm.total_amount),2) AS revenue,
COUNT(sh.consignment_no) AS consignment_volume
FROM shipments sh
JOIN shipment_metrics shm ON sh.consignment_no = shm.consignment_no
GROUP BY sh.origin, sh.destination, sh.mode
ORDER BY revenue DESC LIMIT 5;

-- 19. Top 10 clients by revenue or volume
SELECT 
s.sender_name,
ROUND(SUM(shm.total_amount),2) AS revenue,
COUNT(shm.consignment_no) AS volume
FROM senders s 
JOIN shipment_metrics shm ON shm.consignment_no = s.consignment_no
GROUP BY s.sender_name
ORDER BY revenue DESC LIMIT 10;








  
  














    



    
    




    
    






    





	







