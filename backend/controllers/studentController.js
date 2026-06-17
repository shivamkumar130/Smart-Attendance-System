const Student = require("../models/Student");
const axios = require("axios");
const Attendance = require("../models/Attendance");
// REGISTER STUDENT
const registerStudent = async (req, res) => {
  try {
    const { name, rollNo, email, department, semester } = req.body;

    const query = { $or: [{ rollNo }] };
    if (email) {
      query.$or.push({ email });
    }

    const existingStudent = await Student.findOne(query);

    if (existingStudent) {
      return res.status(400).json({
        success: false,
        message: "Student already exists",
      });
    }

    const studentData = {
      name,
      rollNo,
      department,
      semester,
    };
    if (email) {
      studentData.email = email;
    }

    const student = await Student.create(studentData);

    res.status(201).json({
      success: true,
      message: "Student Registered Successfully",
      student,
    });
  } catch (error) {
    console.log(error);

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

// GET ALL STUDENTS
const getAllStudents = async (req, res) => {
  try {
    const students = await Student.find();

    res.status(200).json({
      success: true,
      count: students.length,
      students,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// GET SINGLE STUDENT
const getStudentById = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);

    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student Not Found",
      });
    }

    res.status(200).json({
      success: true,
      student,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// UPDATE STUDENT
const updateStudent = async (req, res) => {
  try {
    const student = await Student.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student Not Found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Student Updated",
      student,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// DELETE STUDENT

const deleteStudent = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);

    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student not found",
      });
    }

    // Delete all attendance records
    await Attendance.deleteMany({
      studentId: student._id,
    });

    await Student.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: "Student and attendance records deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const uploadFaceImage = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);

    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student not found",
      });
    }

    student.registeredImages.push(req.file.path);

    await student.save();

    res.status(200).json({
      success: true,
      message: "Image Uploaded",
      image: req.file.path,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const enrollFace = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);

    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student not found",
      });
    }

    if (!student.registeredImages || student.registeredImages.length === 0) {
      return res.status(400).json({
        success: false,
        message: "No uploaded image found",
      });
    }

    // First uploaded image
    const imagePath =
      "../backend/" + student.registeredImages[0].replace(/\\/g, "/");
    console.log("Sending Image Path:", imagePath);
    const response = await axios.post("http://127.0.0.1:8000/enroll-face", {
      image_path: imagePath,
    });

    if (!response.data.success) {
      return res.status(400).json({
        success: false,
        message: "Face not detected",
      });
    }

    student.faceEmbedding = response.data.embedding;

    await student.save();

    res.status(200).json({
      success: true,
      message: "Face enrolled successfully",
      embeddingLength: response.data.embedding_length,
    });
  } catch (error) {
    console.log(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const getStudentReport = async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);

    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student not found",
      });
    }

    const attendance = await Attendance.find({
      studentId: student._id,
    });

    const present = attendance.filter((a) => a.status === "Present").length;

    const total = attendance.length;

    const records = await Attendance.find({
      studentId: req.params.id,
    }).sort({
      attendanceDate: -1,
    });

    const percentage = total === 0 ? 0 : ((present / total) * 100).toFixed(2);

    res.json({
      success: true,
      student,
      totalAttendance: total,
      present,
      absent: total - present,
      percentage,
      timeline: records,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
module.exports = {
  registerStudent,
  getAllStudents,
  getStudentById,
  uploadFaceImage,
  updateStudent,
  deleteStudent,
  enrollFace,
  getStudentReport,
};
