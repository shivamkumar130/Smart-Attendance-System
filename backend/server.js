const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const studentRoutes = require("./routes/studentRoutes");
const attendanceRoutes = require("./routes/attendanceRoutes");

const app = express();

// MIDDLEWARE
app.use(cors());
app.use(express.json());

// DATABASE
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log("MongoDB Connected");
  })
  .catch((error) => {
    console.log(error);
  });

// TEST ROUTE
app.get("/", (req, res) => {
  res.send("API Running");
});

app.use("/api/attendance", attendanceRoutes);
app.use("/uploads", express.static("uploads"));
// STUDENT ROUTES
app.use("/api/students", studentRoutes);

// SERVER
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server Running on Port ${PORT}`);
});
