const express = require("express");
const cors = require("cors");
const vehicleRoutes = require("./routes/vehicleRoutes");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.use("/api/vehicles", vehicleRoutes);

app.listen(PORT, () => {
  console.log(`Vehicle API running on port ${PORT}`);
});
