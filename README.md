# Vehicle Tracking Feature (Flutter + Node.js)

This repository contains a small full-stack vehicle tracking feature with:

- Node.js + Express backend API
- PostgreSQL database
- Flutter frontend with 2 simple screens:
  - Vehicle list
  - Vehicle details with status toggle (active/inactive)

## Backend

Path: `backend`

### Endpoints

- `GET /health`
- `GET /api/vehicles`
- `GET /api/vehicles/:id`
- `POST /api/vehicles`
- `PATCH /api/vehicles/:id/status`

### Setup

1. Create a PostgreSQL database (example: `vehicle_tracking`)
2. Run migration:

```bash
psql -U <user> -d vehicle_tracking -f database/schema.sql
```

3. Configure backend env:

```bash
cd backend
cp .env.example .env
# update DATABASE_URL if needed
```

4. Install and run:

```bash
npm install
npm start
```

Backend runs at `http://localhost:3000`.

## Flutter App

Path: `flutter_app`

### Run

```bash
cd flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Notes:

- Android emulator: use `http://10.0.2.2:3000`
- iOS simulator: use `http://localhost:3000`
- Physical device: use your machine LAN IP, e.g. `http://192.168.1.50:3000`

## Database Design

Path: `database/schema.sql`

Designed for PostgreSQL. It supports current needs (vehicle master + active/inactive) and basic tracking expansion.

### Tables

1. `vehicles`
- Stores core vehicle details.
- Important fields: `id`, `code`, `name`, `status`, `created_at`, `updated_at`.

2. `vehicle_locations`
- Stores location pings for each vehicle.
- Important fields: `vehicle_id`, `latitude`, `longitude`, `recorded_at`.

3. `vehicle_status_history`
- Audit table for every status change.
- Important fields: `vehicle_id`, `from_status`, `to_status`, `changed_at`, `note`.

### Why this design

- Keeps `vehicles` lean for fast list/detail screens.
- Uses append-only history tables for traceability.
- Allows easy extension to alerts, trips, and driver assignment later.

## API-DB Mapping

- API `id` maps to DB `vehicles.code` (example `V001`).
- Internal numeric DB key is `vehicles.id`.

Example API response:

```json
{
  "id": "V001",
  "name": "Truck Alpha",
  "status": "active"
}
```
