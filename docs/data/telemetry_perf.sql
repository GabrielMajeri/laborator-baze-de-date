-- Set de date de dimensiune medie (~500.000 de rânduri) pentru testarea
-- indecșilor și a planurilor de execuție în Laboratorul 6.
-- Scriptul rulează de obicei în 1–3 secunde.

CREATE TABLE robots (
    id SERIAL PRIMARY KEY,
    code VARCHAR(16) UNIQUE NOT NULL,
    model TEXT NOT NULL,
    fleet VARCHAR(32) NOT NULL
);

CREATE TABLE operators (
    id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE telemetry_logs (
    id BIGSERIAL PRIMARY KEY,
    robot_id INTEGER NOT NULL REFERENCES robots(id),
    sensor_type VARCHAR(16) NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    status VARCHAR(16) NOT NULL,
    notes TEXT NOT NULL
);

-- Inserăm 200 de roboți
INSERT INTO robots (code, model, fleet)
SELECT
    'ROB-' || LPAD(i::text, 4, '0'),
    (ARRAY['Rover-X1', 'Quad-A4', 'Sub-M2', 'Arm-K6'])[1 + (i % 4)],
    (ARRAY['ground', 'aerial', 'marine', 'lab'])[1 + (i % 4)]
FROM generate_series(1, 200) AS s(i);

-- Inserăm câțiva operatori (fără constrângere UNIQUE pe email inițial)
INSERT INTO operators (full_name, email, is_active)
VALUES
    ('Andrei Exemplu', 'andrei.exemplu@s.unibuc.ro', TRUE),
    ('Maria Exemplu', 'maria.exemplu@s.unibuc.ro', TRUE),
    ('Vlad Exemplu', 'vlad.exemplu@s.unibuc.ro', FALSE),
    ('Ioana Exemplu', 'ioana.exemplu@s.unibuc.ro', TRUE);

-- Generăm 500.000 de înregistrări de telemetrie pe ultimele ~30 de zile
-- Distribuția statusului este intenționat neuniformă: ~95% 'ok', ~4% 'warn', ~1% 'error'
INSERT INTO telemetry_logs (robot_id, sensor_type, recorded_at, value, status, notes)
SELECT
    1 + (i % 200) AS robot_id,
    (ARRAY['lidar', 'imu', 'thermal', 'gps', 'battery'])[1 + (i % 5)] AS sensor_type,
    TIMESTAMPTZ '2026-10-01 00:00:00+03' + (i * INTERVAL '5 seconds') AS recorded_at,
    ROUND(((SIN(i / 100.0) * 50 + 50)::numeric), 3)::double precision AS value,
    CASE
        WHEN i % 100 = 0 THEN 'error'
        WHEN i % 25 = 0 THEN 'warn'
        ELSE 'ok'
    END AS status,
    'Telemetry packet #' || i || ' checksum verified' AS notes
FROM generate_series(1, 500000) AS s(i);

-- Actualizăm statisticile folosite de query planner
ANALYZE robots;
ANALYZE operators;
ANALYZE telemetry_logs;
