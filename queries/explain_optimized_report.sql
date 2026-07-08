EXPLAIN (ANALYZE, BUFFERS)
SELECT
  org_id,
  status,
  COUNT(*) AS booking_count,
  SUM(amount) AS total_amount
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status
ORDER BY org_id, status;
