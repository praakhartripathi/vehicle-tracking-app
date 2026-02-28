const { vehicles } = require("../data/vehicles");

const VALID_STATUS = new Set(["active", "inactive"]);

function listVehicles(req, res) {
  res.json(vehicles);
}

function getVehicleById(req, res) {
  const vehicle = vehicles.find((item) => item.id === req.params.id);
  if (!vehicle) {
    return res.status(404).json({ message: "Vehicle not found" });
  }

  return res.json(vehicle);
}

function createVehicle(req, res) {
  const { id, name, status } = req.body;

  if (!id || !name || !status) {
    return res.status(400).json({ message: "id, name and status are required" });
  }

  if (!VALID_STATUS.has(status)) {
    return res.status(400).json({ message: "status must be active or inactive" });
  }

  const duplicate = vehicles.some((item) => item.id === id);
  if (duplicate) {
    return res.status(409).json({ message: "Vehicle id already exists" });
  }

  const vehicle = { id, name, status };
  vehicles.push(vehicle);
  return res.status(201).json(vehicle);
}

function updateVehicleStatus(req, res) {
  const { status } = req.body;
  if (!VALID_STATUS.has(status)) {
    return res.status(400).json({ message: "status must be active or inactive" });
  }

  const vehicle = vehicles.find((item) => item.id === req.params.id);
  if (!vehicle) {
    return res.status(404).json({ message: "Vehicle not found" });
  }

  vehicle.status = status;
  return res.json(vehicle);
}

module.exports = {
  listVehicles,
  getVehicleById,
  createVehicle,
  updateVehicleStatus
};
