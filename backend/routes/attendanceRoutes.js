const express = require("express");
const router = express.Router();

const upload = require("../middleware/upload");

const {
  markAttendance,
  getAllAttendance,
  getStudentAttendance,
  deleteAttendance,
  recognizeAndMarkAttendance,
  recognizeLiveAttendance,
  getReport,
  getAttendanceSummary,
  getAttendanceAnalytics,
  getRecentAttendance,
  getAttendanceByDate,
  getMonthlyReport,
} = require("../controllers/attendanceController");

// MARK ATTENDANCE
router.post("/mark", markAttendance);

// OLD JSON-BASED RECOGNITION
router.post("/recognize", recognizeAndMarkAttendance);

// CAMERA / FLUTTER RECOGNITION
router.post("/recognize-live", upload.single("image"), recognizeLiveAttendance);

// GET ALL ATTENDANCE
router.get("/", getAllAttendance);

// GET STUDENT ATTENDANCE
router.get("/student/:id", getStudentAttendance);

// DELETE ATTENDANCE
router.delete("/:id", deleteAttendance);

// GET ATTENDANCE REPORT
router.get("/report", getReport);

router.get("/summary", getAttendanceSummary);
router.get("/analytics", getAttendanceAnalytics);
router.get("/recent", getRecentAttendance);
router.get("/date/:date", getAttendanceByDate);
router.get("/monthly-report", getMonthlyReport);
module.exports = router;
