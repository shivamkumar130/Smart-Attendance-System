const Attendance = require("../models/Attendance");
const Student = require("../models/Student");
const axios = require("axios");
const path = require("path");

const markAttendance = async (req, res) => {
  try {
    const { studentId, subject, status } = req.body;

    const student = await Student.findById(studentId);
    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student not found",
      });
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const attendanceExists = await Attendance.findOne({
      studentId,
      subject,
      attendanceDate: { $gte: today },
    });

    if (attendanceExists) {
      return res.status(400).json({
        success: false,
        message: "Attendance already marked today",
      });
    }

    const attendance = await Attendance.create({
      studentId,
      subject,
      status: status || "Present",
      attendanceDate: new Date(),
      checkInTime: new Date(),
      attendanceType: req.body.attendanceType || req.body.type,
    });

    res.status(201).json({
      success: true,
      message: "Attendance marked successfully",
      attendance,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getAllAttendance = async (req, res) => {
  try {
    const attendance = await Attendance.find()
      .populate("studentId", "name rollNo email")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: attendance.length,
      attendance,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getStudentAttendance = async (req, res) => {
  try {
    const attendance = await Attendance.find({
      studentId: req.params.id,
    })
      .populate("studentId", "name rollNo")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: attendance.length,
      attendance,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const deleteAttendance = async (req, res) => {
  try {
    const attendance = await Attendance.findById(req.params.id);

    if (!attendance) {
      return res.status(404).json({
        success: false,
        message: "Attendance not found",
      });
    }

    await attendance.deleteOne();

    res.status(200).json({
      success: true,
      message: "Attendance deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const recognizeAndMarkAttendance = async (req, res) => {
  try {
    const students = await Student.find({
      faceEmbedding: { $exists: true, $ne: [] },
    });

    if (students.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No enrolled students found",
      });
    }

    const fs = require("fs");
    const uploadedImagePath = req.file?.path || req.body.imagePath;

    if (!uploadedImagePath) {
      return res.status(400).json({
        success: false,
        message: "No image path provided",
      });
    }

    const imagePath = path.join(__dirname, "..", uploadedImagePath);

    console.log("Recognition Image:", imagePath);
    console.log("Exists:", fs.existsSync(imagePath));

    const subject = req.body.subject || "Software Engineering";

    const response = await axios.post("http://127.0.0.1:8000/recognize-face", {
      image_path: imagePath,
      students,
    });

    if (!response.data.success) {
      return res.status(400).json({
        success: false,
        message: response.data.message,
      });
    }

    const matchedStudent = response.data.recognized_student;
    const studentId = matchedStudent.id || matchedStudent._id;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const attendanceExists = await Attendance.findOne({
      studentId,
      subject,
      attendanceDate: { $gte: today },
    });

    let attendanceMarked = false;

    if (!attendanceExists) {
      await Attendance.create({
        studentId,
        subject,
        status: "Present",
        confidence: response.data.confidence,
        checkInTime: new Date(),
        attendanceDate: new Date(),
        attendanceType: req.body.attendanceType || req.body.type,
      });
      attendanceMarked = true;
    }

    res.status(200).json({
      success: true,
      student: matchedStudent,
      confidence: response.data.confidence,
      attendanceMarked,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const recognizeLiveAttendance = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No image uploaded",
      });
    }

    const fs = require("fs");

    const students = await Student.find({
      faceEmbedding: { $exists: true, $ne: [] },
    });

    if (students.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No enrolled students found",
      });
    }

    const imagePath = path.resolve(req.file.path);

    console.log("IMAGE PATH:", imagePath);
    console.log("FILE EXISTS:", fs.existsSync(imagePath));

    const response = await axios.post("http://127.0.0.1:8000/recognize-face", {
      image_path: imagePath,
      students,
    });

    if (!response.data.success) {
      return res.status(400).json({
        success: false,
        message: response.data.message,
      });
    }

    const matchedStudent =
      response.data.student || response.data.recognized_student;

    if (!matchedStudent) {
      return res.status(400).json({
        success: false,
        message: "No matching student found",
      });
    }

    const studentId = matchedStudent.id || matchedStudent._id;

    const subject = req.body.subject;

    if (!subject) {
      return res.status(400).json({
        success: false,
        message: "Subject is required",
      });
    }

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const attendanceExists = await Attendance.findOne({
      studentId,
      subject,
      attendanceDate: {
        $gte: startOfDay,
        $lte: endOfDay,
      },
    });

    let attendanceMarked = false;

    if (!attendanceExists) {
      await Attendance.create({
        studentId,
        subject,
        status: "Present",
        confidence: response.data.confidence,
        attendanceDate: new Date(),
        checkInTime: new Date(),
        attendanceType: req.body.attendanceType || req.body.type,
      });

      attendanceMarked = true;
    }

    res.status(200).json({
      success: true,
      message: attendanceMarked
        ? "Attendance marked successfully"
        : "Attendance already marked today",
      student: matchedStudent,
      confidence: response.data.confidence,
      attendanceMarked,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getReport = async (req, res) => {
  try {
    const totalStudents = await Student.countDocuments();

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const presentStudents = await Attendance.distinct("studentId", {
      attendanceDate: {
        $gte: startOfDay,
        $lte: endOfDay,
      },
      status: "Present",
    });

    const presentToday = presentStudents.length;
    const absentToday = totalStudents - presentToday;
    const totalAttendance = await Attendance.countDocuments();

    const percentage =
      totalStudents === 0
        ? 0
        : ((presentToday / totalStudents) * 100).toFixed(2);

    res.json({
      success: true,
      totalStudents,
      presentToday,
      absentToday,
      totalAttendance,
      attendancePercentage: percentage,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getAttendanceSummary = async (req, res) => {
  try {
    const summary = await Attendance.aggregate([
      {
        $lookup: {
          from: "students",
          localField: "studentId",
          foreignField: "_id",
          as: "student",
        },
      },
      { $unwind: "$student" },
      {
        $group: {
          _id: "$studentId",
          name: { $first: "$student.name" },
          rollNo: { $first: "$student.rollNo" },
          totalPresent: { $sum: 1 },
          lastAttendance: { $max: "$attendanceDate" },
        },
      },
      { $sort: { totalPresent: -1 } },
    ]);

    res.json({
      success: true,
      summary,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getAttendanceAnalytics = async (req, res) => {
  try {
    const range = (req.query.range || "day").toString().toLowerCase();
    const now = new Date();
    const year =
      parseInt(req.query.year?.toString() ?? "") || now.getFullYear();
    const month =
      parseInt(req.query.month?.toString() ?? "") || now.getMonth() + 1;
    const dateParam = req.query.date?.toString();

    let startDate;
    let endDate;
    let label;

    if (range === "year") {
      startDate = new Date(year, 0, 1, 0, 0, 0, 0);
      endDate = new Date(year, 11, 31, 23, 59, 59, 999);
      label = `${year}`;
    } else if (range === "month") {
      startDate = new Date(year, month - 1, 1, 0, 0, 0, 0);
      endDate = new Date(year, month, 0, 23, 59, 59, 999);
      label = `Month ${month}, ${year}`;
    } else {
      const selectedDate = dateParam ? new Date(dateParam) : now;
      startDate = new Date(selectedDate);
      startDate.setHours(0, 0, 0, 0);
      endDate = new Date(selectedDate);
      endDate.setHours(23, 59, 59, 999);
      const yearLabel = startDate.getFullYear();
      const monthLabel = (startDate.getMonth() + 1).toString().padStart(2, "0");
      const dayLabel = startDate.getDate().toString().padStart(2, "0");
      label = `${yearLabel}-${monthLabel}-${dayLabel}`;
    }

    const totalStudents = await Student.countDocuments();

    const presentCount = await Attendance.countDocuments({
      attendanceDate: { $gte: startDate, $lte: endDate },
      status: "Present",
    });

    const absentRecordsCount = await Attendance.countDocuments({
      attendanceDate: { $gte: startDate, $lte: endDate },
      status: "Absent",
    });

    const absentCount = Math.max(
      totalStudents - presentCount,
      absentRecordsCount,
    );
    const totalRecords = totalStudents;
    const attendancePercentage =
      totalRecords === 0 ? 0 : ((presentCount / totalRecords) * 100).toFixed(2);

    res.json({
      success: true,
      range,
      label,
      startDate,
      endDate,
      totalStudents,
      present: presentCount,
      absent: absentCount,
      totalRecords,
      attendancePercentage,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getDashboardStats = async (req, res) => {
  try {
    const totalStudents = await Student.countDocuments();

    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const presentStudents = await Attendance.distinct("studentId", {
      attendanceDate: {
        $gte: startOfDay,
        $lte: endOfDay,
      },
      status: "Present",
    });

    const presentToday = presentStudents.length;
    const absentToday = totalStudents - presentToday;

    const percentage =
      totalStudents === 0 ? 0 : (presentToday / totalStudents) * 100;

    res.json({
      success: true,
      totalStudents,
      presentToday,
      absentToday,
      percentage: percentage.toFixed(1),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const getRecentAttendance = async (req, res) => {
  try {
    const records = await Attendance.find()
      .populate("studentId", "name rollNo")
      .sort({
        attendanceDate: -1,
      })
      .limit(2);

    res.status(200).json({
      success: true,
      records,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const getAttendanceByDate = async (req, res) => {
  try {
    const selectedDate = new Date(req.params.date);

    const startOfDay = new Date(selectedDate);

    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(selectedDate);

    endOfDay.setHours(23, 59, 59, 999);

    const attendance = await Attendance.find({
      attendanceDate: {
        $gte: startOfDay,
        $lte: endOfDay,
      },
    })
      .populate("studentId", "name rollNo")
      .sort({
        attendanceDate: -1,
      });

    res.json({
      success: true,
      attendance,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const getMonthlyReport = async (req, res) => {
  const month = parseInt(req.query.month);

  const year = parseInt(req.query.year);

  const startDate = new Date(year, month - 1, 1);

  const endDate = new Date(year, month, 0, 23, 59, 59);

  const report = await Attendance.aggregate([
    {
      $match: {
        attendanceDate: {
          $gte: startDate,
          $lte: endDate,
        },
        status: "Present",
      },
    },
    {
      $group: {
        _id: "$studentId",
        totalPresent: {
          $sum: 1,
        },
      },
    },
    {
      $lookup: {
        from: "students",
        localField: "_id",
        foreignField: "_id",
        as: "student",
      },
    },
    {
      $unwind: "$student",
    },
    {
      $project: {
        _id: 0,
        name: "$student.name",
        rollNo: "$student.rollNo",
        department: "$student.department",
        semester: "$student.semester",
        totalPresent: 1,
      },
    },
  ]);
  res.json({
    success: true,
    report,
  });
};
module.exports = {
  markAttendance,
  getAllAttendance,
  getStudentAttendance,
  deleteAttendance,
  recognizeAndMarkAttendance,
  recognizeLiveAttendance,
  getReport,
  getAttendanceSummary,
  getAttendanceAnalytics,
  getDashboardStats,
  getRecentAttendance,
  getAttendanceByDate,
  getMonthlyReport,
};
