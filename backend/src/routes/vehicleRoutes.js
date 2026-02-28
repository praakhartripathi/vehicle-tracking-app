const express = require("express");
const {
  listVehicles,
  getVehicleById,
  createVehicle,
  updateVehicleStatus
} = require("../controllers/vehicleController");

const router = express.Router();

router.get("/", listVehicles);
router.get("/:id", getVehicleById);
router.post("/", createVehicle);
router.patch("/:id/status", updateVehicleStatus);

module.exports = router;
