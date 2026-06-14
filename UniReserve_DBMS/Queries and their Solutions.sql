---------------- 1. MOST ACTIVE USER ----------------
-- Topic: Aggregation + ORDER BY + LIMIT
SELECT u.user_name, COUNT(r.room_booking_request_id) AS total_requests
FROM USER_TABLE u
JOIN ROOM_BOOKING_REQUEST r 
ON u.user_id = r.requester_user_id
GROUP BY u.user_name
ORDER BY total_requests DESC
LIMIT 1;


---------------- 2. ROOM WITH MAX EVENTS ----------------
-- Topic: GROUP BY + MAX logic
SELECT r.room_name, COUNT(e.event_id) AS total_events
FROM ROOM r
JOIN EVENT e ON r.room_id = e.room_id
GROUP BY r.room_name
ORDER BY total_events DESC
LIMIT 1;


---------------- 3. USERS WHO NEVER BOOKED ANY ROOM ----------------
-- Topic: LEFT JOIN + NULL
SELECT u.user_name
FROM USER_TABLE u
LEFT JOIN ROOM_BOOKING_REQUEST r 
ON u.user_id = r.requester_user_id
WHERE r.room_booking_request_id IS NULL;


---------------- 4. EVENTS WITH LONG DURATION (> 2 DAYS) ----------------
-- Topic: Date Arithmetic
SELECT event_name,
(end_datetime - start_datetime) AS duration
FROM EVENT
WHERE (end_datetime - start_datetime) > INTERVAL '2 days';


---------------- 5. GROUPS WITH MORE THAN 2 MEMBERS ----------------
-- Topic: GROUP BY + HAVING
SELECT g.group_name, COUNT(m.user_id) AS total_members
FROM GROUP_TABLE g
JOIN GROUP_MEMBER m ON g.group_id = m.group_id
GROUP BY g.group_name
HAVING COUNT(m.user_id) > 2;


---------------- 6. COMMON USERS IN MULTIPLE GROUPS ----------------
-- Topic: Self Join / Aggregation
SELECT user_id, COUNT(group_id) AS group_count
FROM GROUP_MEMBER
GROUP BY user_id
HAVING COUNT(group_id) > 1;


---------------- 7. EVENTS WITHOUT ANY GROUP ASSOCIATION ----------------
-- Topic: LEFT JOIN + NULL
SELECT e.event_name
FROM EVENT e
LEFT JOIN GROUP_EVENT ge ON e.event_id = ge.event_id
WHERE ge.group_id IS NULL;


---------------- 8. OVERLAPPING ROOM BOOKINGS ----------------
-- Topic: Self Join + Time Conflict
SELECT r1.room_booking_request_id, r2.room_booking_request_id
FROM ROOM_BOOKING_REQUEST r1
JOIN ROOM_BOOKING_REQUEST r2
ON r1.requestee_room_id = r2.requestee_room_id
AND r1.room_booking_request_id <> r2.room_booking_request_id
AND r1.start_datetime < r2.end_datetime
AND r1.end_datetime > r2.start_datetime;


---------------- 9. USERS WHO CREATED EVENTS BUT NEVER BOOKED ROOM ----------------
-- Topic: NOT IN / Subquery
SELECT DISTINCT u.user_name
FROM USER_TABLE u
JOIN EVENT e ON u.user_id = e.creator_id
WHERE u.user_id NOT IN (
    SELECT requester_user_id FROM ROOM_BOOKING_REQUEST
);


---------------- 10. MOST POPULAR GROUP (MAX MEMBERS) ----------------
-- Topic: Subquery + MAX
SELECT g.group_name
FROM GROUP_TABLE g
JOIN GROUP_MEMBER m ON g.group_id = m.group_id
GROUP BY g.group_name
HAVING COUNT(m.user_id) = (
    SELECT MAX(member_count)
    FROM (
        SELECT COUNT(user_id) AS member_count
        FROM GROUP_MEMBER
        GROUP BY group_id
    ) AS temp
);


---------------- 11. USERS WHO ARE BOTH REPRESENTATIVE AND MEMBER ----------------
-- Topic: INTERSECTION
SELECT gm.user_id
FROM GROUP_MEMBER gm
INTERSECT
SELECT gr.user_id
FROM GROUP_REPRESENTATIVE gr;


---------------- 12. AVERAGE ROOM CAPACITY ----------------
-- Topic: AVG
SELECT AVG(capacity) AS avg_capacity
FROM ROOM;


---------------- 13. EVENTS PER MONTH ----------------
-- Topic: Date Function + GROUP BY
SELECT DATE_TRUNC('month', start_datetime) AS month,
COUNT(*) AS total_events
FROM EVENT
GROUP BY month
ORDER BY month;


---------------- 14. USERS WITH MAX BOOKINGS (TIES INCLUDED) ----------------
-- Topic: Window Function
SELECT user_name, total_requests
FROM (
    SELECT u.user_name,
           COUNT(r.room_booking_request_id) AS total_requests,
           RANK() OVER (ORDER BY COUNT(r.room_booking_request_id) DESC) AS rnk
    FROM USER_TABLE u
    JOIN ROOM_BOOKING_REQUEST r 
    ON u.user_id = r.requester_user_id
    GROUP BY u.user_name
) t
WHERE rnk = 1;


---------------- 15. TOP 3 ROOMS BY BOOKING COUNT ----------------
-- Topic: Window Function
SELECT room_name, total_bookings
FROM (
    SELECT rm.room_name,
           COUNT(r.room_booking_request_id) AS total_bookings,
           DENSE_RANK() OVER (ORDER BY COUNT(r.room_booking_request_id) DESC) AS rnk
    FROM ROOM rm
    JOIN ROOM_BOOKING_REQUEST r 
    ON rm.room_id = r.requestee_room_id
    GROUP BY rm.room_name
) t
WHERE rnk <= 3;


---------------- 16. FIND GAPS BETWEEN EVENTS ----------------
-- Topic: Window Function (LEAD)
SELECT event_name,
start_datetime,
LEAD(start_datetime) OVER (ORDER BY start_datetime) AS next_event_start
FROM EVENT;


---------------- 17. CASCADE LOGIC CHECK (ORPHAN DATA) ----------------
-- Topic: Data Integrity
SELECT *
FROM GROUP_MEMBER gm
WHERE NOT EXISTS (
    SELECT 1 FROM USER_TABLE u WHERE u.user_id = gm.user_id
);


---------------- 18. USERS WHO HAVE BOTH INDIVIDUAL AND GROUP BOOKINGS ----------------
-- Topic: INTERSECTION (via JOIN)
SELECT DISTINCT i.requester_user_id
FROM INDIVIDUAL_BOOKING_REQUEST i
JOIN GROUP_BOOKING_REQUEST g
ON i.requester_user_id = g.requester_user_id;


---------------- 19. PEAK BOOKING HOURS ----------------
-- Topic: Extract + GROUP BY
SELECT EXTRACT(HOUR FROM start_datetime) AS hour,
COUNT(*) AS total_bookings
FROM ROOM_BOOKING_REQUEST
GROUP BY hour
ORDER BY total_bookings DESC;


---------------- 20. COMPLEX REAL SCENARIO ----------------
-- Topic: Multi Join + Aggregation
SELECT g.group_name, COUNT(e.event_id) AS total_events
FROM GROUP_TABLE g
JOIN GROUP_EVENT ge ON g.group_id = ge.group_id
JOIN EVENT e ON ge.event_id = e.event_id
GROUP BY g.group_name
ORDER BY total_events DESC;