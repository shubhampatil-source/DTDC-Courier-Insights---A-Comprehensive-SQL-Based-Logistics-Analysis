DTDC Courier Insights: A Comprehensive SQL-Based Logistics Analysis

Welcome to DTDC Courier Insights, a data-driven project that dives deep into the logistics and operational efficiency of DTDC Courier services using MySQL as the core analytical tool.
This project simulates a real-world scenario of a logistics company handling thousands of daily shipments across India. Using raw shipment data across sender/receiver locations, weights, delivery times, VAS charges, and modes of transport, we analyze trends, inefficiencies, and performance metrics.

Project Objective:
To perform in-depth consignment analysis using MySQL by leveraging a courier service dataset and focusing on:

•	Operational efficiency

•	Consignment cost structure

•	Financial metrics

•	Geo-Logistics Optimization

•	Exception & Risk Management

•	Client behavior


Dataset Source: Dataset used for this project is available publicly on kaggle.

 Link: DTDC Courier Dataset

Tools: 

•	MySQL

•	Kaggle DTDC Courier Dataset



Database Schema:
•	TABLE – 1  : shipments (
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

•	TABLE-2 : senders (
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

•	TABLE-3 : receivers (
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

•	TABLE- 4 : shipment_metrics (
consignment_no VARCHAR(100),
 total_pieces INT, actual_wt FLOAT, 
volumetric_wt FLOAT,
 tariff FLOAT, 
vas_charges FLOAT, 
total_amount FLOAT, 
paperwork TEXT,
 value_added_services TEXT,
description TEXT, 
risk_surcharge VARCHAR(50),  
FOREIGN KEY (consignment_no) REFERENCES shipments(consignment_no));

Questions:

•	What is the average turnaround time and standard deviation per mode of transport?

•	How many consignments were handled per day?

•	Max and min number of consignments handled per day

•	Number of days where number of consignments are above average

•	Which top 5 booking codes experience higher delivery times across cities?

•	Identify count of shipments where the delivery gap is unusually high compared to similar routes.

•	Segment by mode of transport and routes, which route suffers most delays in terms of delivery gap and volume of consignments

•	Which top 5 routes operate with the lowest cost-per-kg (high efficiency)?

•	Which top 5 routes operate with the highest cost-per-kg (Low efficiency)?

•	Which routes have the highest consignment volume and weight?

•	What is the average cost per kg by mode?

•	Which cities (origin/destination) consistently incur higher VAS charges?

•	Find % of total revenue spent on VAS

•	What is the total % revenue generated from each sender state and mode combination?

•	Total revenue, VAS charge margin and profitability index of each mode of transport and correlation with volume of consignments

•	Identify top 5 senders state contributing highest total revenue across all consignments, their vas charge margin and profitability index

•	Count Consignments where chargeable_wt deviates significantly > 2kg from actual_wt.

•	Which route + mode combinations generate high revenue but have low consignment volume?

•	Top 10 clients by revenue or volume



Key Insights and Findings:
1. Operational Efficiency:

• Average turnaround time: Between all mode of transports average turnaround time is consistent to approx 3 days. Air Cargo, expected to be the fastest, leads marginally — but not significantly. Express and Surface are performing on par with air cargo.  Low Standard Deviation across all three modes (1.4–1.42) suggests that: Turnaround times are consistent and there is no major variance between best- and worst-case delivery times.

• High standard deviation areas: Every Route has standard deviation between 1.4-1.6. Volume of consignments at high standard deviation 1.6 is around 35-45. At every routes volume of consignments is at least in range of 30-50. Need to review how to increase volume by implementing competitive prices or improving delivery time by understanding overall data of competitors.

• Consignments handled per day: Consistent Volume is observed where consignment volumes hover tightly around 1,650–1,700 per day. This indicates a stable operational workload.

• Maximum and Minimum consignments handled per day: The gap of 171 consignments shows an approx 10% fluctuation between the busiest and lightest days. This is moderate — not extreme, but should still be factored into planning.

• Count of days where numbers of consignments are above average: Average consignment volume is only exceeded on approx 23% of the days. This suggests that consignment load is concentrated on a few high-volume days, while the rest of the period sees relatively lower or below-average activity. Ops team can plan resources based on consignment spikes and lulls.

• Booking codes experience higher delivery times across cities: Inefficient Codes like BR926 should be kept under review in future. And also review reason behind delays happened in past even volume they have is minimum. 

• Idle count detection: Count of consignments out of 49629 consignments 3799 consignments where the delivery gap is unusually high compared to similar routes.


2. Geo-Logistics Optimization:

• Routes with high delivery gap:  Higher delivery gap is observed in mode of transport 80% in surface and 20% in express. Routes which observe higher delivery gaps are Nagpur - Kochi, Chennai - Patna, Ranchi - Chandigarh, Agra - Jamshedpur, Kolkata - Bhubaneswar. Volume of consignments on each route ranges around 25-40.

• Top 5 routes operate with high efficiency and low efficiency: High efficiency routes observed in this are Dehradun - Agra, Bhopal - Jaipur, Guwahati - Raipur, Mumbai - Coimbatore, Guwahati - Varanasi. Low efficiency Routes observed are Delhi - Agra, Thiruvananthapuram -Shimla, Meerut - Vijayawada, Guwahati - Vizag, Amritsar - Ahmedabad. High-efficiency lanes worth expanding and revise pricing for low-efficiency routes.

• Routes with the highest consignment volume and weight: Routes with high consignment volume like Srinagar – Kochi and Jamshedpur-Hyderabad also show high total weight, implying predominantly bulk consignments rather than lightweight or document parcels.


3. Consignment Cost Structure:

• Average cost per kg by mode: Express is the most expensive mode per kg Likely due to faster delivery expectations. Air Cargo is mid-tier in cost which is usually used for faster but moderately priced consignments. Surface is most cost efficient may be because per-unit transport cost is lower despite longer delivery time

• High VAS charges routes: Routes involving Tier 2 and 3 cities (e.g., Jamshedpur, Indore, Coimbatore, and Dehradun) are frequently on this list. Possible reasons may be infrastructure gaps requiring extra services.

• Margin of total revenue spent on VAS charges: 13.23% of total revenue is used for vas charges. 


4. Financial metrics:

• State level revenue by each mode of transportation in percentage: Surface contributes approx 50% of revenue in each state operationally, possibly due to cost efficiency and nature of consignments which is high volume and non-urgent.

• Total revenue, VAS charge margin and profitability index of each mode of transport and correlation with volume of consignments: Major contribution to revenue is done by surface mode of transport with highest observed volume of consignments and also percent Vas charge margin from revenue is highest in Surface which is 16%. But Profitability index is highest in express mode 727 of transport mainly due to premium prices for fast delivery.

• Top 5 senders state contributing highest total revenue across all consignments, their vas charge margin and profitability index: Major volumes of high revenue orders are received from Maharashtra and Uttar Pradesh. Profitability index is consistent through all top 5 states in range 500-510.


5. Exception & Risk Management:

• Deviation of actual weight and chargeable weight: 34.28% of consignments have a significant weight deviation. Data inconsistencies observed which shows incorrect weight capture during booking. Packaging factors can be one of the reasons where Bulky items with low actual weight.


6. Route & Mode Profitability Matrix:

• Routes and mode of transport combinations generate high revenue but have low shipment volume: Mostly in surface mode of transportation high revenue at low consignment volume is observed. Vijayawada –Delhi, Thiruvananthapuram – Varanasi, Aurangabad – Vijayawada, Jaipur – Aurangabad, Ludhiana-Chandigarh are routes where we observed consistent revenue of Rs.16,000.


7. Client Behavior:

• Top Clients: Most consistent consignments are received from Keer PLC and Kala Group.



Conclusion: 


•	Operational workflows are stable, to add more efficiency in operations route-level optimization, booking code auditing, and volume balancing should be done.

•	In mode of transportations surface dominates in volume and revenue. But express mode yields superior per-unit profitability. This creates an opportunity to up sell value-driven consignments.

•	Cost and delay hotspots in Tier-2 routes show underlying infrastructure issues.

•	A significant portion of revenue is driven by a limited number of high-performing origin-destination routes and key clients. Need to focus on improving routes and customers with average performance to make the business more stable and grow faster.

•	Exception handling needs a stronger data governance framework, especially around weight misreporting and unusual delivery gaps.


How to Use This Project:

• Clone or download this repository.

•	Load the dataset into your MySQL environment.

•	Run the queries from the `DTDC_Analysis.sql` file.

•	Interpret the results to generate business insights.


Author Profile:

Shubham Patil

Currently working as Data Research intern in Findem.ai |EX-RnD Technical Officer in Kansai Nerolac Paints LTD |B.tech Pass out From Institute of chemical technology in 2020 | Career transitioning to Data Analytics. | Open to join full time role.

Mail-id: shubhampatil066@gmail.com 
