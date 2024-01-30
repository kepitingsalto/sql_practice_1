SELECT *
FROM website_sessions;

-- case 1: analyzing traffic source
#traffic/session per source
SELECT 
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) count_session
FROM website_sessions
WHERE DATE(created_at) < '2012-04-13'
GROUP BY 1, 2, 3;

#case conversion rate dari session to order
SELECT 
	utm_source,
    utm_campaign,
    http_referer,
    website_session_id,
    order_id,
    COUNT(website_session_id) session,
    COUNT(order_id) orders,
    COUNT(order_id) / COUNT(website_session_id) * 100 conversion_rate
FROM website_sessions
LEFT JOIN orders
	USING(website_session_id)
WHERE 
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand' AND
    http_referer = 'https://www.gsearch.com' AND
    website_sessions.created_at < '2012-04-14'
GROUP BY 1, 2, 3;

#trend volume traffic/session mingguan
SELECT
	WEEK(created_at) minggu,
    DATE(created_at) tanggal,
    COUNT(website_session_id) session
FROM website_sessions
WHERE 
	created_at < '2012-05-11' AND
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand' AND
    http_referer = 'https://www.gsearch.com' 
GROUP BY 1;

#bid optimization for paid traffic
SELECT 
	device_type,
    COUNT(website_session_id) session,
    COUNT(order_id) orders,
    COUNT(order_id) / COUNT(website_session_id) * 100 cvr_by_device
FROM website_sessions AS ws
LEFT JOIN orders
	USING(website_session_id)
WHERE 
	ws.created_at < '2012-05-12' AND
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand' 
GROUP BY 1;

-- case 2: Analyzing website performance
#session per page
SELECT 
	COUNT(website_session_id) session,
    pageview_url
FROM website_pageviews
WHERE created_at < '2012-06-10'
GROUP BY 2;

#first page 
WITH first_page_view AS(
SELECT 
	website_session_id,
	MIN(website_pageview_id) first_view_id
FROM website_pageviews
WHERE created_at < '2012-06-13'
GROUP BY 1)

SELECT 
    pageview_url,
    COUNT(fp.first_view_id) session
FROM first_page_view fp
INNER JOIN website_pageviews wp
	ON fp.first_view_id = wp.website_pageview_id
GROUP BY 1
LIMIT 1;

#Bounce rate analysis
WITH bounce AS(SELECT 
	website_session_id,
    COUNT(website_pageview_id) time_viewed,
    CASE 
		WHEN COUNT(website_pageview_id) = 1 THEN 1 
        ELSE 0 
	END is_bounced
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY 1)

SELECT 
	COUNT(website_session_id) session,
    SUM(is_bounced) total_bounce,
    AVG(is_bounced) * 100 bounce_rate
FROM bounce;
