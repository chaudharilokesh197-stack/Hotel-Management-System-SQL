CREATE DATABASE Hotel_Reservation_Analytics;
USE Hotel_Reservation_Analytics;






-- ========================================================
-- 1. HOTELS TABLE
-- ========================================================
CREATE TABLE hotels (
    -- PK: Uniquely identifies each hotel; prevents duplicates
    hotel_id VARCHAR(20) PRIMARY KEY,
    hotel_name VARCHAR(100),
    city VARCHAR(50),
    star_rating INT,
    total_rooms INT,
    opened_date VARCHAR(30)
);

-- ========================================================
-- 2. GUESTS TABLE
-- ========================================================
CREATE TABLE guests (
    -- PK: Uniquely identifies each guest
    guest_id VARCHAR(20) PRIMARY KEY,
    guest_name VARCHAR(100),
    city VARCHAR(50),
    guest_type VARCHAR(20),
    preferred_room_type VARCHAR(20),
    loyalty_tier VARCHAR(20),
    account_since VARCHAR(30)
);

-- ========================================================
-- 3. STAFF TABLE
-- ========================================================
CREATE TABLE staff (
    -- PK: Uniquely identifies each staff member[cite: 1]
    staff_id VARCHAR(20) PRIMARY KEY,
    staff_name VARCHAR(100),
    hire_date VARCHAR(30),
    rating DECIMAL(3, 2),
    department VARCHAR(30),
    is_active VARCHAR(10)
);

-- ========================================================
-- 4. ROOMS TABLE
-- ========================================================
CREATE TABLE rooms (
    -- PK: Uniquely identifies each room[cite: 1]
    room_id VARCHAR(20) PRIMARY KEY,
    -- FK: Links the room to the specific hotel it belongs to[cite: 1]
    hotel_id VARCHAR(20),
    room_type VARCHAR(20),
    floor_number INT,
    max_occupancy INT,
    price_per_night DECIMAL(10, 2),
    is_active VARCHAR(10)
);

-- ========================================================
-- 5. BOOKINGS TABLE
-- ========================================================
CREATE TABLE bookings (
    -- PK: Uniquely identifies each reservation[cite: 1]
    booking_id VARCHAR(20) PRIMARY KEY,
    -- FK: Links the reservation to the guest who booked it[cite: 1]
    guest_id VARCHAR(20),
    -- FK: Links the reservation to the hotel booked[cite: 1]
    hotel_id VARCHAR(20),
    booking_date VARCHAR(30),
    room_type_requested VARCHAR(20),
    booking_channel VARCHAR(30),
    nights_booked INT,
    total_amount DECIMAL(12, 2)
);

-- ========================================================
-- 6. STAYS TABLE
-- ========================================================
CREATE TABLE stays (
    -- PK: Uniquely identifies each actual stay[cite: 1]
    stay_id VARCHAR(20) PRIMARY KEY,
    -- FK: Links the stay to its original booking record[cite: 1]
    booking_id VARCHAR(20),
    -- FK: Links the stay to the actual room assigned[cite: 1]
    room_id VARCHAR(20),
    -- FK: Links the stay to the staff member who handled it[cite: 1]
    staff_id VARCHAR(20),
    check_in_date VARCHAR(30),
    check_out_date VARCHAR(30),
    status VARCHAR(20),
    nights_stayed INT,
    service_requests INT,
    stay_duration_hrs INT
);
    
    
    
    
    
    
    
-- 1. Total number of guests
SELECT COUNT(*) AS total_guests FROM guests;

-- 2. Total number of bookings
SELECT COUNT(*) AS total_bookings FROM bookings;

-- 3. Total number of stays
SELECT COUNT(*) AS total_stays FROM stays;

-- 4. Different room types available
SELECT DISTINCT room_type FROM rooms;

-- 5. Active staff count
SELECT COUNT(*) AS active_staff_count FROM staff WHERE is_active = 'Yes';

-- 6. Different booking channels
SELECT DISTINCT booking_channel FROM bookings;

-- 7. Total booking amount
SELECT SUM(total_amount) AS total_revenue FROM bookings;

-- 8. Average nights booked per booking
SELECT ROUND(AVG(nights_booked), 2) AS avg_nights_booked FROM bookings;








-- ===================================================================================
-- SPRINT 4.1: UNDERSTAND BOOKING DEMAND
-- Business Objective: The Operations team wants to understand where and how bookings are being generated.
-- ===================================================================================

-- -----------------------------------------------------------------------------------
-- # Question 1: How does booking demand and revenue compare across individual hotels and cities?
-- # Answer / Insight:
-- # - Identifies top-performing properties by booking volume and total revenue generation.
-- # - Highlights high-revenue locations driven by strong average booking values.
-- -----------------------------------------------------------------------------------
SELECT 
    h.hotel_id,
    h.hotel_name,
    h.city,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(SUM(b.total_amount), 2) AS total_revenue,
    ROUND(AVG(b.total_amount), 2) AS avg_booking_value
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
GROUP BY h.hotel_id, h.hotel_name, h.city
ORDER BY total_bookings DESC;


-- -----------------------------------------------------------------------------------
-- # Question 2: Which booking channels generate the most bookings, revenue, and longer stays?
-- # Answer / Insight:
-- # - Digital channels (Website and Mobile App) generate the majority of total booking volume.
-- # - Compares customer acquisition channels against revenue yield and average stay duration.
-- -----------------------------------------------------------------------------------
SELECT 
    booking_channel,
    COUNT(booking_id) AS total_bookings,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_booking_value,
    ROUND(AVG(nights_booked), 2) AS avg_nights
FROM bookings
GROUP BY booking_channel
ORDER BY total_bookings DESC;


-- -----------------------------------------------------------------------------------
-- # Question 3: How is demand distributed across requested room types, and which drives higher revenue?
-- # Answer / Insight:
-- # - Standard Rooms capture the highest reservation volume across properties.
-- # - Deluxe Rooms generate top-tier aggregate revenue, while Suites command premium average room rates.
-- -----------------------------------------------------------------------------------
SELECT 
    room_type_requested,
    COUNT(booking_id) AS total_bookings,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_price_per_booking,
    ROUND(AVG(nights_booked), 2) AS avg_nights_booked
FROM bookings
GROUP BY room_type_requested
ORDER BY total_bookings DESC;


-- -----------------------------------------------------------------------------------
-- # Question 4: How has booking demand and revenue changed on a yearly basis?
-- # Answer / Insight:
-- # - Tracks macro business trajectory year-over-year in terms of reservations and total income.
-- # - Evaluates stability in average customer spend per booking across operating periods.
-- -----------------------------------------------------------------------------------
SELECT 
    YEAR(booking_date) AS booking_year,
    COUNT(booking_id) AS total_bookings,
    ROUND(SUM(total_amount), 2) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_booking_amount
FROM bookings
GROUP BY YEAR(booking_date)
ORDER BY booking_year ASC;


-- -----------------------------------------------------------------------------------
-- # Question 5: Which combinations of booking channels and room types produce the most revenue?
-- # Answer / Insight:
-- # - Combines marketing channels with inventory types to pinpoint prime revenue drivers.
-- # - Demonstrates how direct digital channels efficiently convert high-value inventory.
-- -----------------------------------------------------------------------------------
SELECT 
    booking_channel,
    room_type_requested,
    COUNT(booking_id) AS total_bookings,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM bookings
GROUP BY booking_channel, room_type_requested
ORDER BY total_revenue DESC
LIMIT 5;




-- ===================================================================================
-- SPRINT 4.2: UNDERSTAND GUEST BOOKING BEHAVIOUR
-- Business Objective: The Guest Experience team wants to understand how guests use the reservation service.
-- ===================================================================================

-- -----------------------------------------------------------------------------------
-- # Question 1: How do Individual and Corporate guests compare in volume, total revenue, and spend patterns?
-- # Answer / Insight:
-- # - Individual travelers constitute the primary share of total reservations and aggregate revenue.
-- # - Corporate profiles supply steady, recurring demand with comparable length of stay and average spend.
-- -----------------------------------------------------------------------------------
SELECT 
    g.guest_type,
    COUNT(DISTINCT g.guest_id) AS unique_guests,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(SUM(b.total_amount), 2) AS total_revenue,
    ROUND(AVG(b.total_amount), 2) AS avg_spend_per_booking,
    ROUND(AVG(b.nights_booked), 2) AS avg_nights_booked
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_type;


-- -----------------------------------------------------------------------------------
-- # Question 2: Who are the top 10 highest-spending guests across the chain?
-- # Answer / Insight:
-- # - Surfaces high-lifetime-value corporate accounts and frequent individual guests.
-- # - Highlights repeat customers who contribute substantial cumulative spend across multiple stays.
-- -----------------------------------------------------------------------------------
SELECT 
    g.guest_id,
    g.guest_name,
    g.guest_type,
    g.city,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(SUM(b.total_amount), 2) AS total_spend,
    ROUND(AVG(b.total_amount), 2) AS avg_spend_per_booking
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_id, g.guest_name, g.guest_type, g.city
ORDER BY total_spend DESC
LIMIT 10;


-- -----------------------------------------------------------------------------------
-- # Question 3: How does booking revenue and engagement vary across different Loyalty Tiers?
-- # Answer / Insight:
-- # - Unenrolled/non-member guests account for the largest proportion of total demand.
-- # - Gold tier members demonstrate the highest average ticket spend among registered loyalty accounts.
-- -----------------------------------------------------------------------------------
SELECT 
    IFNULL(g.loyalty_tier, 'Non-Member') AS loyalty_tier,
    COUNT(DISTINCT g.guest_id) AS total_guests,
    COUNT(b.booking_id) AS total_bookings,
    ROUND(SUM(b.total_amount), 2) AS total_spend,
    ROUND(AVG(b.total_amount), 2) AS avg_spend_per_booking
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.loyalty_tier
ORDER BY total_spend DESC;


-- -----------------------------------------------------------------------------------
-- # Question 4: Which repeat guests visit multiple hotel locations across the brand network?
-- # Answer / Insight:
-- # - Identifies cross-city brand loyalty where guests stay across several portfolio locations.
-- # - Demonstrates brand adoption across multiple regional properties by key accounts.
-- -----------------------------------------------------------------------------------
SELECT 
    g.guest_id,
    g.guest_name,
    g.guest_type,
    COUNT(b.booking_id) AS total_bookings,
    COUNT(DISTINCT b.hotel_id) AS unique_hotels_visited,
    ROUND(SUM(b.total_amount), 2) AS total_spend
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_id, g.guest_name, g.guest_type
HAVING unique_hotels_visited >= 10
ORDER BY unique_hotels_visited DESC, total_spend DESC
LIMIT 10;


-- -----------------------------------------------------------------------------------
-- # Question 5: Which guests book the longest stays, and what is their total commitment?
-- # Answer / Insight:
-- # - Details maximum extended-stay commitments that drive high revenue per transaction.
-- # - Informs front-office and housekeeping capacity allocation for extended room blocks.
-- -----------------------------------------------------------------------------------
SELECT 
    g.guest_id,
    g.guest_name,
    g.guest_type,
    b.nights_booked,
    b.total_amount,
    b.booking_channel
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
ORDER BY b.nights_booked DESC
LIMIT 10;




-- ===================================================================================
-- SPRINT 4.3: EVALUATE STAY PERFORMANCE
-- Business Objective: The Operations team wants to understand how well stays are being completed.
-- ===================================================================================

-- -----------------------------------------------------------------------------------
-- # Question 1: What is the overall distribution of stay outcomes (Checked-out, Cancelled, No-show, In-progress)?
-- # Answer / Insight:
-- # - Measures portfolio-wide realization by calculating completed check-outs versus capacity leakage.
-- # - Establishes operational baseline metrics for cancellations and unfulfilled reservations.
-- -----------------------------------------------------------------------------------
SELECT 
    s.status AS stay_status,
    COUNT(s.stay_id) AS total_stays,
    ROUND(COUNT(s.stay_id) * 100.0 / (SELECT COUNT(*) FROM stays), 2) AS percentage_share
FROM stays s
GROUP BY s.status
ORDER BY total_stays DESC;


-- -----------------------------------------------------------------------------------
-- # Question 2: How does the average stay duration (nights) vary across different stay outcomes?
-- # Answer / Insight:
-- # - Compares duration across outcomes using check-in and check-out dates.
-- # - Identifies whether longer duration reservations show elevated vulnerability to cancellations.
-- -----------------------------------------------------------------------------------
SELECT 
    s.status AS stay_status,
    COUNT(s.stay_id) AS total_stays,
    ROUND(AVG(DATEDIFF(s.check_out_date, s.check_in_date)), 2) AS avg_duration_nights,
    MIN(DATEDIFF(s.check_out_date, s.check_in_date)) AS min_nights,
    MAX(DATEDIFF(s.check_out_date, s.check_in_date)) AS max_nights
FROM stays s
WHERE s.check_out_date >= s.check_in_date
GROUP BY s.status
ORDER BY avg_duration_nights DESC;


-- -----------------------------------------------------------------------------------
-- # Question 3: How do stay outcomes compare across individual hotels?
-- # Answer / Insight:
-- # - Connects bookings and stays to evaluate operational execution property by property.
-- # - Contrasts hotels maintaining high fulfillment rates against those with higher attrition.
-- -----------------------------------------------------------------------------------
SELECT 
    b.hotel_id,
    COUNT(s.stay_id) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS checked_out_count,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_show_count,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN s.status = 'In-progress' THEN 1 ELSE 0 END) AS in_progress_count,
    ROUND(SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.stay_id), 2) AS completion_rate_pct
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY b.hotel_id
ORDER BY total_stays DESC;


-- -----------------------------------------------------------------------------------
-- # Question 4: Which hotels experience the highest operational leakage (No-shows & Cancellations)?
-- # Answer / Insight:
-- # - Flags locations experiencing elevated rates of unfulfilled reservations.
-- # - Targets operational intervention points for deposit verification and guest communication.
-- -----------------------------------------------------------------------------------
SELECT 
    b.hotel_id,
    COUNT(s.stay_id) AS total_stays,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS total_no_shows,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS total_cancellations,
    ROUND((SUM(CASE WHEN s.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) * 100.0 / COUNT(s.stay_id)), 2) AS failure_rate_pct
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY b.hotel_id
HAVING total_stays >= 50
ORDER BY failure_rate_pct DESC
LIMIT 10;


-- -----------------------------------------------------------------------------------
-- # Question 5: How has stay performance and completion rate trended over time?
-- # Answer / Insight:
-- # - Monitors monthly fulfillment trends to reveal seasonal fluctuations in guest attrition.
-- # - Tracks operational consistency and check-out ratios across successive booking months.
-- -----------------------------------------------------------------------------------
SELECT 
    DATE_FORMAT(b.booking_date, '%Y-%m') AS booking_month,
    COUNT(s.stay_id) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed_stays,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_shows,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.stay_id), 2) AS completion_rate_pct
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY DATE_FORMAT(b.booking_date, '%Y-%m')
ORDER BY booking_month ASC;




-- ===================================================================================
-- SPRINT 4.4: UNDERSTAND STAFF AND ROOM PERFORMANCE
-- Business Objective: The Operations team wants to understand how its hotel resources are being utilized and how they are performing.
-- ===================================================================================

-- -----------------------------------------------------------------------------------
-- # Question 1: How many stays has each staff member handled, and what is their average rating?
-- # Answer / Insight:
-- # - Identifies workload distribution among front-desk/hotel staff.
-- # - Highlights top-performing staff members maintaining high service ratings across handled stays.
-- -----------------------------------------------------------------------------------
SELECT 
    st.staff_id,
    st.staff_name,
    st.role,
    COUNT(s.stay_id) AS total_stays_handled,
    ROUND(AVG(s.rating), 2) AS avg_guest_rating
FROM staff st
JOIN stays s ON st.staff_id = s.staff_id
GROUP BY st.staff_id, st.staff_name, st.role
ORDER BY total_stays_handled DESC;


-- -----------------------------------------------------------------------------------
-- # Question 2: How do stay outcomes (Checked-out vs Cancelled/No-show) distribute across staff members?
-- # Answer / Insight:
-- # - Tracks how effectively each staff member guides reservations to successful check-out.
-- # - Spots whether certain staff members face higher guest fallout or handle predominantly cancelled stays.
-- -----------------------------------------------------------------------------------
SELECT 
    st.staff_id,
    st.staff_name,
    COUNT(s.stay_id) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS checked_out_count,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_show_count,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    ROUND(SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.stay_id), 2) AS completion_rate_pct
FROM staff st
JOIN stays s ON st.staff_id = s.staff_id
GROUP BY st.staff_id, st.staff_name
ORDER BY total_stays DESC;


-- -----------------------------------------------------------------------------------
-- # Question 3: What is the average stay duration managed by each staff member?
-- # Answer / Insight:
-- # - Shows which staff members regularly handle extended stays requiring continuous operational attention.
-- # - Assists management in balancing workload between short-stay turnovers and long-term guests.
-- -----------------------------------------------------------------------------------
SELECT 
    st.staff_id,
    st.staff_name,
    COUNT(s.stay_id) AS total_stays,
    ROUND(AVG(DATEDIFF(s.check_out_date, s.check_in_date)), 2) AS avg_stay_duration_nights
FROM staff st
JOIN stays s ON st.staff_id = s.staff_id
WHERE s.check_out_date >= s.check_in_date
GROUP BY st.staff_id, st.staff_name
ORDER BY avg_stay_duration_nights DESC;


-- -----------------------------------------------------------------------------------
-- # Question 4: How is room usage and stay completion distributed across different room types?
-- # Answer / Insight:
-- # - Compares room inventory utilization across Standard, Deluxe, and Suite categories.
-- # - Measures which room categories achieve the highest completion rates versus operational drop-offs.
-- -----------------------------------------------------------------------------------
SELECT 
    r.room_type,
    COUNT(s.stay_id) AS total_stays_assigned,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed_stays,
    ROUND(SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.stay_id), 2) AS completion_rate_pct,
    ROUND(AVG(DATEDIFF(s.check_out_date, s.check_in_date)), 2) AS avg_duration_nights
FROM rooms r
JOIN stays s ON r.room_id = s.room_id
WHERE s.check_out_date >= s.check_in_date
GROUP BY r.room_type
ORDER BY total_stays_assigned DESC;


-- -----------------------------------------------------------------------------------
-- # Question 5: Which specific rooms experience the highest turnover and lowest completion rates?
-- # Answer / Insight:
-- # - Identifies high-traffic rooms requiring frequent maintenance and housekeeping attention.
-- # - Highlights specific rooms that suffer from recurring cancellations or guest drop-offs.
-- -----------------------------------------------------------------------------------
SELECT 
    r.room_id,
    r.room_number,
    r.room_type,
    COUNT(s.stay_id) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS successful_stays,
    ROUND(SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.stay_id), 2) AS room_success_rate_pct
FROM rooms r
JOIN stays s ON r.room_id = s.room_id
GROUP BY r.room_id, r.room_number, r.room_type
HAVING total_stays >= 5
ORDER BY total_stays DESC, room_success_rate_pct ASC
LIMIT 10;



-- ===================================================================================
-- SPRINT 4.5: IDENTIFY BOOKING AND STAY PROBLEMS
-- Business Objective: The Operations team wants to understand why some bookings require additional effort or fail to result in a completed stay.
-- ===================================================================================

-- -----------------------------------------------------------------------------------
-- # Question 1: What proportion of bookings fail to result in a completed stay, and what are the primary failure modes?
-- # Answer / Insight:
-- # - Quantifies total operational fallout by grouping stays into unfulfilled statuses (Cancelled, No-show).
-- # - Shows the baseline rate of wasted inventory and lost booking revenue across the chain.
-- -----------------------------------------------------------------------------------
SELECT 
    s.status AS problem_status,
    COUNT(s.stay_id) AS total_affected_stays,
    ROUND(COUNT(s.stay_id) * 100.0 / (SELECT COUNT(*) FROM stays), 2) AS percentage_of_all_stays,
    ROUND(SUM(b.total_amount), 2) AS potential_revenue_impact
FROM stays s
JOIN bookings b ON s.booking_id = b.booking_id
WHERE s.status IN ('Cancelled', 'No-show')
GROUP BY s.status
ORDER BY total_affected_stays DESC;


-- -----------------------------------------------------------------------------------
-- # Question 2: Which booking channels experience the highest cancellation and no-show rates?
-- # Answer / Insight:
-- # - Analyzes failure rates across booking sources (Website, Mobile App, Walk-in, Phone).
-- # - Detects if low-friction channels (e.g., website or app without upfront deposits) create disproportionate drop-offs.
-- -----------------------------------------------------------------------------------
SELECT 
    b.booking_channel,
    COUNT(s.stay_id) AS total_stays,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_show_count,
    ROUND(SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(s.stay_id), 2) AS problem_rate_pct
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY b.booking_channel
ORDER BY problem_rate_pct DESC;


-- -----------------------------------------------------------------------------------
-- # Question 3: How do service request volumes impact stay completion and guest satisfaction ratings?
-- # Answer / Insight:
-- # - Evaluates whether high service requests signal ongoing property defects or guest dissatisfaction.
-- # - Compares average ratings and completion outcomes for low versus high operational effort stays.
-- -----------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN s.service_requests = 0 THEN '0 Requests (Smooth)'
        WHEN s.service_requests BETWEEN 1 AND 2 THEN '1-2 Requests (Moderate)'
        ELSE '3+ Requests (High Effort)'
    END AS effort_category,
    COUNT(s.stay_id) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed_stays,
    ROUND(AVG(s.rating), 2) AS avg_guest_rating,
    ROUND(SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.stay_id), 2) AS cancellation_rate_pct
FROM stays s
GROUP BY 
    CASE 
        WHEN s.service_requests = 0 THEN '0 Requests (Smooth)'
        WHEN s.service_requests BETWEEN 1 AND 2 THEN '1-2 Requests (Moderate)'
        ELSE '3+ Requests (High Effort)'
    END
ORDER BY total_stays DESC;


-- -----------------------------------------------------------------------------------
-- # Question 4: Which specific hotels suffer from the highest volume of operational problems (High Failures & High Service Requests)?
-- # Answer / Insight:
-- # - Pinpoints problem-heavy locations that demand immediate operational review.
-- # - Combines failed outcomes with total operational load (service request volume) per property.
-- -----------------------------------------------------------------------------------
SELECT 
    h.hotel_id,
    h.hotel_name,
    h.city,
    COUNT(s.stay_id) AS total_stays,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) AS total_failed_stays,
    SUM(s.service_requests) AS total_service_requests,
    ROUND(SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(s.stay_id), 2) AS failure_rate_pct
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY h.hotel_id, h.hotel_name, h.city
HAVING total_stays >= 30
ORDER BY failure_rate_pct DESC, total_service_requests DESC
LIMIT 10;


-- -----------------------------------------------------------------------------------
-- # Question 5: Does requested room type correlate with higher cancellation or service issue rates?
-- # Answer / Insight:
-- # - Investigates if premium inventory (Suites) or budget inventory (Standard) drives more friction.
-- # - Helps room allocation and housekeeping teams identify inventory types prone to guest issues.
-- -----------------------------------------------------------------------------------
SELECT 
    b.room_type_requested,
    COUNT(s.stay_id) AS total_stays,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(AVG(s.service_requests), 2) AS avg_service_requests_per_stay,
    ROUND(AVG(s.rating), 2) AS avg_rating
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY b.room_type_requested
ORDER BY total_stays DESC;


