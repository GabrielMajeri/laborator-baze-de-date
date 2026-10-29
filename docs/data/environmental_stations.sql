-- Environmental variables: pressure, temperature, wind speed etc.
CREATE TABLE variables (
    id SERIAL PRIMARY KEY,
    name VARCHAR(64) UNIQUE NOT NULL,
    unit VARCHAR(16) NOT NULL
);

-- Research stations
CREATE TABLE stations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) UNIQUE NOT NULL,
    location TEXT NOT NULL,
    installed_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE sensors (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    brand TEXT,
    serial_number TEXT UNIQUE NOT NULL
);

CREATE TABLE station_sensors (
    station_id INTEGER REFERENCES stations(id) ON DELETE CASCADE,
    sensor_id INTEGER REFERENCES sensors(id) ON DELETE CASCADE,
    PRIMARY KEY (station_id, sensor_id)
);

CREATE TABLE sensor_variables (
    sensor_id INTEGER REFERENCES sensors(id) ON DELETE CASCADE,
    variable_id INTEGER REFERENCES variables(id) ON DELETE CASCADE,
    PRIMARY KEY (sensor_id, variable_id)
);

CREATE TABLE measurements (
    sensor_id INTEGER REFERENCES sensors(id) ON DELETE CASCADE,
    variable_id INTEGER REFERENCES variables(id) ON DELETE CASCADE,
    timestamp TIMESTAMP NOT NULL,
    value FLOAT NOT NULL,
    -- Measurement quality or precision, as reported by the sensor
    -- 0 = bad, 1 = acceptable, 2 = excellent
    quality INTEGER CHECK (quality IN (0, 1, 2)),
    PRIMARY KEY (sensor_id, variable_id, timestamp)
);

INSERT INTO variables (name, unit)
VALUES
    ('temperature', 'deg C'),
    ('pressure', 'Pa'),
    ('wind speed', 'm/s'),
    ('wind direction', 'rad'),
    ('humidity', '%'),
    ('solar radiation', 'W/m^2');

INSERT INTO stations (name, location, installed_at)
VALUES
    ('Brașov', 'Calea Brașovului', '2025-09-15 10:00:00+03'),
    ('Brăila', 'Strada Dunării', '2025-10-20 09:30:00+03'),
    ('București', 'Bulevardul Unirii', '2025-11-05 14:15:00+02'),
    ('Cluj-Napoca', 'Piața Unirii', '2025-12-12 08:45:00+02'),
    ('Constanța', 'Strada Tomis', '2026-01-10 13:20:00+02'),
    ('Sibiu', 'Strada Turnului', '2026-02-01 11:00:00+02');

INSERT INTO sensors (name, brand, serial_number)
VALUES
    ('Senzor de temperatură', 'Brand A', 'TS-1001'),
    ('Senzor de temperatură', 'Brand B', '2501150001TS'),
    ('Senzor de presiune', 'Brand A', 'PS-1001XZ'),
    ('Senzor de vânt', 'Brand B', 'B-WS-3001'),
    ('Senzor meteo integrat', 'Brand C', 'MET-5000'),
    ('Senzor de temperatură', 'Brand A', 'TS-1002'),
    ('Senzor de umiditate', NULL, 'HUM-01');

INSERT INTO station_sensors (station_id, sensor_id)
VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (3, 4),
    (4, 5),
    (5, 6);

INSERT INTO sensor_variables (sensor_id, variable_id)
VALUES
    (1, 1),
    (2, 1),
    (3, 2),
    (4, 3),
    (4, 4),
    (5, 1),
    (5, 2),
    (5, 5),
    (6, 1),
    (7, 5);

INSERT INTO measurements (sensor_id, variable_id, timestamp, value, quality)
VALUES
    (1, 1, '2026-03-01 08:00:00', 12.4, 2),
    (1, 1, '2026-03-01 09:00:00', 13.1, 2),
    (1, 1, '2026-03-01 10:00:00', 14.5, 1),
    (2, 1, '2026-03-01 08:00:00', 12.6, 2),
    (2, 1, '2026-03-01 09:00:00', 18.9, 0),
    (3, 2, '2026-03-01 08:00:00', 101325.0, 2),
    (3, 2, '2026-03-01 09:00:00', 101280.0, 2),
    (4, 3, '2026-03-01 08:00:00', 5.2, 2),
    (4, 3, '2026-03-01 09:00:00', 6.8, 1),
    (4, 4, '2026-03-01 08:00:00', 1.57, 2),
    (4, 4, '2026-03-01 09:00:00', 1.72, 1),
    (5, 1, '2026-03-01 08:00:00', 9.8, 2),
    (5, 2, '2026-03-01 08:00:00', 98400.0, 2),
    (5, 5, '2026-03-01 08:00:00', 74.0, 1),
    (6, 1, '2026-03-01 08:00:00', 15.2, 2),
    (6, 1, '2026-03-01 09:00:00', 16.0, NULL);
