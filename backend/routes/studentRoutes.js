const express = require("express");
const router = express.Router();
const upload = require("../middleware/upload");
const {
  registerStudent,
  getAllStudents,
  getStudentById,
  updateStudent,
  deleteStudent,
  uploadFaceImage,
  enrollFace,
  getStudentReport,
} = require("../controllers/studentController");

// CREATE
router.post("/register", registerStudent);

// READ ALL
router.get("/", getAllStudents);
// DELETE
router.delete("/:id", deleteStudent);
// READ ONE
router.get("/:id", getStudentById);

router.get("/report/:id", getStudentReport);

// UPDATE
router.put("/:id", updateStudent);

router.post("/upload-face/:id", upload.single("image"), uploadFaceImage);
router.post("/enroll-face/:id", enrollFace);
module.exports = router;
