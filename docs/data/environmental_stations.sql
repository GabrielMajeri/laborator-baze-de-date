-- Definirea structurii bazei de date (folosind DDL - Data Definition Language)
-- și popularea cu date (folosind DML - Data Manipulation Language)

-- Tabel pentru mărimile fizice (variabilele de mediu) măsurate:
-- presiune, temperatură, viteza vântului etc.
CREATE TABLE variables (
    -- Identificator unic pentru fiecare variabilă, generat automat de PostgreSQL
    id SERIAL PRIMARY KEY,
    -- Denumirea unică a variabilei (ex. 'temperature', 'pressure', 'wind speed').
    name VARCHAR(64) UNIQUE NOT NULL,
    -- Unitatea de măsură (de exemplu: 'deg C', 'Pa', 'm/s').
    unit VARCHAR(16) NOT NULL
);

-- Tabel pentru stațiile de cercetare / monitorizare
CREATE TABLE stations (
    id SERIAL PRIMARY KEY,
    -- Denumirea unică a stației (ex. 'Brașov', 'București')
    name VARCHAR(128) UNIQUE NOT NULL,
    -- Locația stației (ex. adresa sau coordonatele GPS)
    location TEXT NOT NULL,
    -- Data și ora la care stația a fost instalată (cu tot cu fusul orar)
    installed_at TIMESTAMPTZ NOT NULL
);

-- Tabel pentru senzorii fizici instalați pe stații
CREATE TABLE sensors (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    -- Brand-ul senzorului (ex. 'Brand A', 'Brand B').
    -- Poate fi NULL dacă brand-ul nu este cunoscut.
    brand TEXT,
    -- Numărul de serie al fiecărui senzor
    serial_number TEXT UNIQUE NOT NULL
);

-- Tabel asociativ (de legătură) între stații și senzori,
-- care reține ce senzori sunt instalați în fiecare stație.
CREATE TABLE station_sensors (
    -- REFERENCES stations(id) definește o CHEIE STRĂINĂ (FOREIGN KEY)
    station_id INTEGER REFERENCES stations(id) ON DELETE CASCADE,
    sensor_id INTEGER REFERENCES sensors(id) ON DELETE CASCADE,
    -- CHEIE PRIMARĂ COMPUSĂ (composite primary key):
    PRIMARY KEY (station_id, sensor_id)
);

-- Tabel asociativ (relație many-to-many) între senzori și variabile.
-- Un senzor poate măsura mai multe variabile (ex. un senzor meteo integrat),
-- iar o variabilă poate fi măsurată de mai mulți senzori.
CREATE TABLE sensor_variables (
    sensor_id INTEGER REFERENCES sensors(id) ON DELETE CASCADE,
    variable_id INTEGER REFERENCES variables(id) ON DELETE CASCADE,
    -- Perechea (sensor_id, variable_id) formează cheia primară compusă.
    -- care identifică în mod unic această asociere.
    PRIMARY KEY (sensor_id, variable_id)
);

-- Tabel pentru măsurătorile propriu-zise înregistrate de senzori.
CREATE TABLE measurements (
    sensor_id INTEGER REFERENCES sensors(id) ON DELETE CASCADE,
    variable_id INTEGER REFERENCES variables(id) ON DELETE CASCADE,
    timestamp TIMESTAMP NOT NULL,
    -- FLOAT (echivalent cu DOUBLE PRECISION) stochează numere reale
    -- în virgulă mobilă cu precizie dublă (8 bytes).
    value FLOAT NOT NULL,
    -- Calitatea sau precizia măsurătorii, raportată de senzor:
    -- 0 = slabă (bad), 1 = acceptabilă (acceptable), 2 = excelentă (excellent)
    quality INTEGER CHECK (quality IN (0, 1, 2)),
    -- Cheie primară compusă: un senzor poate înregistra mai multe variabile,
    -- aceeași variabilă poate fi înregistrată de același senzor la momente diferite,
    -- dar nu putem avea două măsurători diferite pentru aceeași variabilă,
    -- de la același senzor, la același moment de timp.
    PRIMARY KEY (sensor_id, variable_id, timestamp)
);


-- ============================================================================
-- POPULAREA CU DATE (DML - Data Manipulation Language)
-- ============================================================================

-- Inserăm variabilele de mediu. Nu specificăm coloana „id” deoarece este de
-- tip SERIAL și primește automat valorile 1, 2, ..., 6.
INSERT INTO variables (name, unit)
VALUES
    ('temperature', 'deg C'),       -- id = 1
    ('pressure', 'Pa'),             -- id = 2
    ('wind speed', 'm/s'),          -- id = 3
    ('wind direction', 'rad'),      -- id = 4
    ('humidity', '%'),              -- id = 5
    ('solar radiation', 'W/m^2');   -- id = 6 (nu este încă măsurată de niciun senzor)

-- Inserăm stațiile de monitorizare (vor primi id-urile 1..6)
-- și notăm ora la care au fost instalate (cu fusul orar corespunzător).
INSERT INTO stations (name, location, installed_at)
VALUES
    ('Brașov', 'Calea Brașovului', '2025-09-15 10:00:00+03'),     -- id = 1
    ('Brăila', 'Strada Dunării', '2025-10-20 09:30:00+03'),       -- id = 2 (fără senzori instalați)
    ('București', 'Bulevardul Unirii', '2025-11-05 14:15:00+02'), -- id = 3
    ('Cluj-Napoca', 'Piața Unirii', '2025-12-12 08:45:00+02'),    -- id = 4
    ('Constanța', 'Strada Tomis', '2026-01-10 13:20:00+02'),      -- id = 5
    ('Sibiu', 'Strada Turnului', '2026-02-01 11:00:00+02');       -- id = 6 (fără senzori instalați)

-- Inserăm senzorii (vor primi id-urile 1..7).
-- Ultimul senzor are brand-ul NULL (necunoscut) și nu este încă instalat în nicio stație.
INSERT INTO sensors (name, brand, serial_number)
VALUES
    ('Senzor de temperatură', 'Brand A', 'TS-1001'),      -- id = 1
    ('Senzor de temperatură', 'Brand B', '2501150001TS'), -- id = 2
    ('Senzor de presiune', 'Brand A', 'PS-1001XZ'),       -- id = 3
    ('Senzor de vânt', 'Brand B', 'B-WS-3001'),           -- id = 4
    ('Senzor meteo integrat', 'Brand C', 'MET-5000'),     -- id = 5
    ('Senzor de temperatură', 'Brand A', 'TS-1002'),      -- id = 6
    ('Senzor de umiditate', NULL, 'HUM-01');              -- id = 7

-- Asociem senzorii cu stațiile în care sunt instalați
INSERT INTO station_sensors (station_id, sensor_id)
VALUES
    (1, 1), -- Brașov -> TS-1001
    (1, 2), -- Brașov -> 2501150001TS
    (1, 3), -- Brașov -> PS-1001XZ
    (3, 4), -- București -> B-WS-3001
    (4, 5), -- Cluj-Napoca -> MET-5000
    (5, 6); -- Constanța -> TS-1002

-- Definim ce variabile măsoară fiecare senzor
INSERT INTO sensor_variables (sensor_id, variable_id)
VALUES
    (1, 1), -- TS-1001 -> temperature
    (2, 1), -- 2501150001TS -> temperature
    (3, 2), -- PS-1001XZ -> pressure
    (4, 3), -- B-WS-3001 -> wind speed
    (4, 4), -- B-WS-3001 -> wind direction
    (5, 1), -- MET-5000 -> temperature
    (5, 2), -- MET-5000 -> pressure
    (5, 5), -- MET-5000 -> humidity
    (6, 1), -- TS-1002 -> temperature
    (7, 5); -- HUM-01 -> humidity (nu are încă măsurători înregistrate)

-- Inserăm câteva măsurători înregistrate de senzori
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
