const { pool } = require("../db/pool");

const VALID_STATUS = new Set(["active", "inactive"]);

async function listVehicles(req, res) {
  try {
    const result = await pool.query(
      `SELECT code AS id, name, status
       FROM vehicles
       ORDER BY code ASC`
    );

    return res.json(result.rows);
  } catch (error) {
    return res.status(500).json({ message: "Failed to fetch vehicles" });
  }
}

async function getVehicleById(req, res) {
  try {
    const result = await pool.query(
      `SELECT code AS id, name, status
       FROM vehicles
       WHERE code = $1`,
      [req.params.id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "Vehicle not found" });
    }

    return res.json(result.rows[0]);
  } catch (error) {
    return res.status(500).json({ message: "Failed to fetch vehicle" });
  }
}

async function createVehicle(req, res) {
  const { id, name, status } = req.body;

  if (!id || !name || !status) {
    return res.status(400).json({ message: "id, name and status are required" });
  }

  if (!VALID_STATUS.has(status)) {
    return res.status(400).json({ message: "status must be active or inactive" });
  }

  try {
    const createdResult = await pool.query(
      `INSERT INTO vehicles (code, name, status)
       VALUES ($1, $2, $3)
       RETURNING code AS id, name, status`,
      [id, name, status]
    );

    await pool.query(
      `INSERT INTO vehicle_status_history (vehicle_id, from_status, to_status, note)
       SELECT id, NULL, status, $2
       FROM vehicles
       WHERE code = $1`,
      [id, "Created vehicle"]
    );

    return res.status(201).json(createdResult.rows[0]);
  } catch (error) {
    if (error.code === "23505") {
      return res.status(409).json({ message: "Vehicle id already exists" });
    }

    return res.status(500).json({ message: "Failed to create vehicle" });
  }
}

async function updateVehicleStatus(req, res) {
  const { status } = req.body;

  if (!VALID_STATUS.has(status)) {
    return res.status(400).json({ message: "status must be active or inactive" });
  }

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const existingResult = await client.query(
      `SELECT id, code, name, status
       FROM vehicles
       WHERE code = $1
       FOR UPDATE`,
      [req.params.id]
    );

    if (existingResult.rowCount === 0) {
      await client.query("ROLLBACK");
      return res.status(404).json({ message: "Vehicle not found" });
    }

    const vehicle = existingResult.rows[0];
    const fromStatus = vehicle.status;

    const updatedResult = await client.query(
      `UPDATE vehicles
       SET status = $2
       WHERE code = $1
       RETURNING code AS id, name, status`,
      [req.params.id, status]
    );

    await client.query(
      `INSERT INTO vehicle_status_history (vehicle_id, from_status, to_status, note)
       VALUES ($1, $2, $3, $4)`,
      [vehicle.id, fromStatus, status, "Status changed from API"]
    );

    await client.query("COMMIT");

    return res.json(updatedResult.rows[0]);
  } catch (error) {
    await client.query("ROLLBACK");
    return res.status(500).json({ message: "Failed to update status" });
  } finally {
    client.release();
  }
}

module.exports = {
  listVehicles,
  getVehicleById,
  createVehicle,
  updateVehicleStatus,
};
