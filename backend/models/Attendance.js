const mongoose = require("mongoose");

const attendanceSchema = new mongoose.Schema(
  {
    studentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Student",
      required: true,
    },

    subject: {
      type: String,
      required: true,
      trim: true,
    },

    status: {
      type: String,
      enum: ["Present", "Absent"],
      default: "Present",
    },

    attendanceDate: {
      type: Date,
      default: Date.now,
    },

    checkInTime: {
      type: Date,
      default: Date.now,
    },
    attendanceType: {
      type: String,
      enum: ["Unjustified", "Justified", "Late"],
    },
    confidence: {
      type: Number,
      min: 0,
      max: 1,
    },
  },
  {
    timestamps: true,
  },
);

module.exports = mongoose.model("Attendance", attendanceSchema);
