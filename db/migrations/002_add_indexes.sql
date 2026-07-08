BEGIN;

-- Optimizes:
-- SELECT org_id, status, COUNT(*), SUM(amount)
-- FROM hotel_bookings
-- WHERE city = 'delhi'
--   AND created_at >= NOW() - INTERVAL '30 days'
-- GROUP BY org_id, status;
CREATE INDEX IF NOT EXISTS idx_hotel_bookings_city_created_org_status
ON hotel_bookings (city, created_at DESC, org_id, status)
INCLUDE (amount);

CREATE INDEX IF NOT EXISTS idx_booking_events_booking_id_created_at
ON booking_events (booking_id, created_at DESC);

COMMIT;
