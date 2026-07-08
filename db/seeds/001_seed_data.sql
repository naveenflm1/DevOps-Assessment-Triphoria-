BEGIN;

TRUNCATE TABLE booking_events, hotel_bookings RESTART IDENTITY CASCADE;

WITH generated_bookings AS (
  SELECT
    concat('00000000-0000-4000-8000-', lpad(gs::text, 12, '0'))::uuid AS id,
    (ARRAY[
      '11111111-1111-4111-8111-111111111111'::uuid,
      '22222222-2222-4222-8222-222222222222'::uuid,
      '33333333-3333-4333-8333-333333333333'::uuid,
      '44444444-4444-4444-8444-444444444444'::uuid
    ])[(gs % 4) + 1] AS org_id,
    concat('hotel-', lpad(((gs % 25) + 1)::text, 3, '0')) AS hotel_id,
    (ARRAY['delhi', 'mumbai', 'bengaluru', 'chennai', 'hyderabad', 'kolkata'])[(gs % 6) + 1] AS city,
    (CURRENT_DATE + ((gs % 60) - 10))::date AS checkin_date,
    (CURRENT_DATE + ((gs % 60) - 10) + ((gs % 5) + 1))::date AS checkout_date,
    round((2500 + ((gs * 137) % 12000) + ((gs % 9) * 0.75))::numeric, 2) AS amount,
    (ARRAY['confirmed', 'cancelled', 'pending', 'checked_out'])[(gs % 4) + 1] AS status,
    (NOW() - ((gs % 90) || ' days')::interval - ((gs % 24) || ' hours')::interval)::timestamp AS created_at
  FROM generate_series(1, 150) AS gs
)
INSERT INTO hotel_bookings (
  id,
  org_id,
  hotel_id,
  city,
  checkin_date,
  checkout_date,
  amount,
  status,
  created_at
)
SELECT
  id,
  org_id,
  hotel_id,
  city,
  checkin_date,
  checkout_date,
  amount,
  status,
  created_at
FROM generated_bookings;

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT
  id,
  'booking_created',
  jsonb_build_object(
    'source', 'seed',
    'city', city,
    'status', status
  ),
  created_at
FROM hotel_bookings;

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT
  id,
  'payment_captured',
  jsonb_build_object(
    'amount', amount,
    'currency', 'INR'
  ),
  created_at + INTERVAL '2 hours'
FROM hotel_bookings
WHERE status IN ('confirmed', 'checked_out');

INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT
  id,
  'booking_cancelled',
  jsonb_build_object(
    'reason', 'guest_request',
    'refund_status', 'initiated'
  ),
  created_at + INTERVAL '4 hours'
FROM hotel_bookings
WHERE status = 'cancelled';

ANALYZE hotel_bookings;
ANALYZE booking_events;

COMMIT;
