-- Vehicle tracking schema (PostgreSQL)

CREATE TYPE vehicle_status AS ENUM ('active', 'inactive');

CREATE TABLE IF NOT EXISTS vehicles (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(120) NOT NULL,
  status vehicle_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vehicles_status ON vehicles(status);

CREATE TABLE IF NOT EXISTS vehicle_locations (
  id BIGSERIAL PRIMARY KEY,
  vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  speed_kmph NUMERIC(6, 2),
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vehicle_locations_vehicle_time
  ON vehicle_locations(vehicle_id, recorded_at DESC);

CREATE TABLE IF NOT EXISTS vehicle_status_history (
  id BIGSERIAL PRIMARY KEY,
  vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  from_status vehicle_status,
  to_status vehicle_status NOT NULL,
  note TEXT,
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vehicle_status_history_vehicle_time
  ON vehicle_status_history(vehicle_id, changed_at DESC);

-- Auto-update updated_at for vehicles table
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_vehicles_updated_at ON vehicles;
CREATE TRIGGER trg_vehicles_updated_at
BEFORE UPDATE ON vehicles
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- Seed data
INSERT INTO vehicles (code, name, status)
VALUES
  ('V001', 'Truck Alpha', 'active'),
  ('V002', 'Bus Bravo', 'inactive')
ON CONFLICT (code) DO NOTHING;

INSERT INTO vehicle_locations (vehicle_id, latitude, longitude, speed_kmph)
SELECT id, 28.6139, 77.2090, 42.5 FROM vehicles WHERE code = 'V001'
UNION ALL
SELECT id, 19.0760, 72.8777, 0.0 FROM vehicles WHERE code = 'V002';

INSERT INTO vehicle_status_history (vehicle_id, from_status, to_status, note)
SELECT id, NULL, status, 'Initial seed status'
FROM vehicles;
