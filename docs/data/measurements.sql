-- Create some tables in PostgreSQL

-- Sensors which record measurements
CREATE TABLE IF NOT EXISTS sensors (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT NOT NULL
);

-- Measurements recorded by the sensors
CREATE TABLE IF NOT EXISTS measurements (
    id INTEGER PRIMARY KEY,
    sensor_id INT NOT NULL REFERENCES sensors(id) ON DELETE RESTRICT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    value FLOAT NOT NULL
);

-- Some sample data for the sensors
INSERT INTO sensors (id, name, location) VALUES
    (1, 'Senzor de temperatură', 'Facultatea de Fizică'),
    (2, 'Senzor de umiditate', 'IFIN-HH'),
    (3, 'Senzor de presiune', 'INCDFM');

-- Some sample data for the measurements
INSERT INTO measurements (id, sensor_id, value, timestamp) VALUES
    (1, 1, 22.5, '2026-09-15 13:00:00'),
    (2, 1, 23.0, '2026-09-15 14:00:00'),
    (3, 1, 21.8, '2026-09-20 13:00:00'),
    (4, 1, 22.0, '2026-09-20 14:00:00'),
    (5, 2, 40.0, '2026-09-15 13:00:00'),
    (6, 2, 45.0, '2026-09-15 14:00:00'),
    (7, 2, 50.0, '2026-09-15 15:00:00'),
    (8, 3, 1013.0, '2026-09-15 13:00:00'),
    (9, 3, 1012.5, '2026-09-15 14:00:00');
