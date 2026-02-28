const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
dotenv.config();

const vehicleRoutes = require("./routes/vehicleRoutes");
const { pool } = require("./db/pool");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get("/health", async (req, res) => {
  try {
    await pool.query("SELECT 1");
    return res.json({ status: "ok", database: "connected" });
  } catch (error) {
    return res.status(500).json({ status: "error", database: "disconnected" });
  }
});

app.use("/api/vehicles", vehicleRoutes);

async function startServer() {
  try {
    await pool.query("SELECT 1");
    app.listen(PORT, () => {
      console.log(`Vehicle API running on port ${PORT}`);
    });
  } catch (error) {
    console.error("Database connection failed:", error.message);
    process.exit(1);
  }
}

startServer();
