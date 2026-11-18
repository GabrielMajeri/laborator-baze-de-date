-- Exemplu de tabel DENORMALIZAT (proiectat deficitar), folosit pentru exercițiile
-- de normalizare din Laboratorul 5.

-- Toate informațiile despre rezervările de echipamente
-- din laboratoarele de robotică și electronică sunt stocate într-un singur tabel plat,
-- fără chei externe sau separare pe entități.

CREATE TABLE lab_reservations_raw (
    reservation_code VARCHAR(16) NOT NULL,
    team_code VARCHAR(16) NOT NULL,
    team_name TEXT NOT NULL,
    -- Încălcare 1NF: listă de studenți separată prin virgulă într-o singură celulă
    team_members TEXT NOT NULL,
    coordinator_name TEXT NOT NULL,
    coordinator_email TEXT NOT NULL,
    equipment_code VARCHAR(16) NOT NULL,
    equipment_name TEXT NOT NULL,
    equipment_category TEXT NOT NULL,
    lab_room VARCHAR(32) NOT NULL,
    borrowed_at DATE NOT NULL,
    returned_at DATE,
    notes TEXT
);

INSERT INTO lab_reservations_raw (
    reservation_code,
    team_code,
    team_name,
    team_members,
    coordinator_name,
    coordinator_email,
    equipment_code,
    equipment_name,
    equipment_category,
    lab_room,
    borrowed_at,
    returned_at,
    notes
)
VALUES
    (
        'RES-001',
        'TEAM-ALPHA',
        'RoboExplorers',
        'Andrei Popa, Maria Stan',
        'Gabriel Majeri',
        'gabriel.majeri@unibuc.ro',
        'LIDAR-01',
        'RPLIDAR A2M8',
        'Senzori',
        'Lab Robotică 102',
        '2026-10-10',
        '2026-10-17',
        'Proiect navigație autonomă'
    ),
    (
        'RES-001',
        'TEAM-ALPHA',
        'RoboExplorers',
        'Andrei Popa, Maria Stan',
        'Gabriel Majeri',
        'gabriel.majeri@unibuc.ro',
        'MCU-STM32',
        'STM32F4 Discovery',
        'Microcontrollere',
        'Lab Robotică 102',
        '2026-10-10',
        '2026-10-17',
        'Proiect navigație autonomă'
    ),
    (
        'RES-002',
        'TEAM-BETA',
        'AeroDrones',
        'Vlad Ionescu, Ioana Marin, Radu Dinu',
        'Petre Boboc',
        'petre-constantin.boboc@unibuc.ro',
        'DRONE-F450',
        'Quadcopter Frame F450',
        'Platforme mobile',
        'Lab Robotică 102',
        '2026-10-12',
        '2026-10-19',
        'Testare stabilizare PID'
    ),
    (
        'RES-002',
        'TEAM-BETA',
        'AeroDrones',
        'Vlad Ionescu, Ioana Marin, Radu Dinu',
        'Petre Boboc',
        'petre-constantin.boboc@unibuc.ro',
        'CAM-STEREO',
        'Intel RealSense D435',
        'Camere',
        'Lab Electronică 204',
        '2026-10-12',
        '2026-10-19',
        'Testare stabilizare PID'
    ),
    (
        'RES-003',
        'TEAM-ALPHA',
        'RoboExplorers',
        'Andrei Popa, Maria Stan',
        'Gabriel Majeri',
        'gabriel.majeri@unibuc.ro',
        'CAM-STEREO',
        'Intel RealSense D435',
        'Camere',
        'Lab Electronică 204',
        '2026-10-20',
        NULL,
        'Calibrare stereoviziune'
    ),
    (
        'RES-004',
        'TEAM-BETA',
        'AeroDrones',
        'Vlad Ionescu, Ioana Marin, Radu Dinu',
        'Petre Boboc',
        'petre-constantin.boboc@unibuc.ro',
        'LIDAR-01',
        'RPLIDAR A2M8',
        'Senzori',
        'Lab Robotică 102',
        '2026-10-22',
        NULL,
        NULL
    ),
    (
        'RES-005',
        'TEAM-GAMMA',
        'QuantumBots',
        'Elena Vasilescu, Cristian Neagu',
        'Gabriel Majeri',
        'gabriel.majeri@unibuc.ro',
        'OSCILLO-02',
        'Osciloscop Digital 100MHz',
        'Aparatură măsură',
        'Lab Electronică 204',
        '2026-10-25',
        '2026-10-26',
        'Analiză semnal PWM motoare'
    );
