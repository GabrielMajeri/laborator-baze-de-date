-- Sensors list
CREATE TABLE sensors (
    sensor_id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,          -- e.g., 'LIDAR-01', 'THERM-CHAMBER-A'
    sensor_type VARCHAR(30) NOT NULL,          -- e.g., 'LiDAR', 'Thermocouple', 'IMU', 'Geiger'
    unit VARCHAR(15) NOT NULL,                 -- e.g., 'm', 'K', 'rad/s', 'CPM'
    sampling_rate_hz NUMERIC(6, 2) CHECK (sampling_rate_hz > 0),
    installed_at DATE NOT NULL DEFAULT CURRENT_DATE,
    is_calibrated BOOLEAN NOT NULL DEFAULT TRUE
);

-- Expermental measurements, as recorded by the sensors
CREATE TABLE measurements (
    measurement_id BIGSERIAL PRIMARY KEY,
    sensor_id INT NOT NULL REFERENCES sensors(sensor_id) ON DELETE CASCADE,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    raw_value DOUBLE PRECISION,                -- NULL allowed if sensor dropped a packet!
    uncertainty DOUBLE PRECISION CHECK (uncertainty >= 0),
    experiment_run VARCHAR(20) NOT NULL        -- e.g., 'RUN-2026-ALPHA'
);

INSERT INTO sensors (code, sensor_type, unit, sampling_rate_hz, installed_at, is_calibrated)
VALUES
    ('LIDAR-FRONT', 'LiDAR', 'm', 50.00, '2026-09-01', TRUE),
    ('IMU-CHASSIS', 'IMU', 'rad/s', 200.00, '2026-09-01', TRUE),
    ('THERM-CRYO', 'Thermocouple', 'K', 10.00, '2026-09-15', FALSE),
    ('RAD-DET-01', 'Scintillator', 'CPM', 1.00, '2026-10-01', TRUE),
    ('ULTRA-REAR', 'Ultrasonic', 'm', 25.00, '2026-10-10', FALSE);

INSERT INTO measurements (sensor_id, recorded_at, raw_value, uncertainty, experiment_run)
VALUES
    (1, '2026-10-15 08:00:01+03', 4.52, 0.02, 'RUN-01'),
    (1, '2026-10-15 08:00:02+03', 4.48, 0.02, 'RUN-01'),
    (1, '2026-10-15 08:00:03+03', NULL, NULL, 'RUN-01'),      -- Packet loss!
    (2, '2026-10-15 08:00:01+03', 0.15, 0.005, 'RUN-01'),
    (3, '2026-10-15 08:05:00+03', 77.4, 1.2, 'RUN-CRYO-A'),
    (3, '2026-10-15 08:05:01+03', -5.0, 15.0, 'RUN-CRYO-A'),  -- Unphysical negative Kelvin reading!
    (4, '2026-10-15 08:10:00+03', 142.0, 11.9, 'RUN-RAD-B');
