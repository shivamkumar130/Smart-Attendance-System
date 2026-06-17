# Backend API Server

**Express.js REST API for Smart Attendance System**

Node.js backend service providing student management, attendance tracking, and analytics endpoints for the Smart Attendance System mobile application.

## 📋 Overview

The backend API is built with Express.js and MongoDB, handling:

- Student registration and management
- Attendance marking and tracking
- Analytics and reporting
- File uploads (student images)
- RESTful API endpoints

## 🛠️ Tech Stack

- **Node.js** - Runtime environment
- **Express.js** 5.2.1 - Web framework
- **Mongoose** 9.6.3 - MongoDB ODM
- **JWT** 9.0.3 - Authentication
- **Multer** 2.1.1 - File upload
- **CORS** 2.8.6 - Cross-origin requests
- **Bcryptjs** 3.0.3 - Password hashing
- **Dotenv** 17.4.2 - Environment variables

## 📁 Project Structure

```
backend/
├── server.js                    # Express app entry point
├── controllers/
│   ├── studentController.js    # Student CRUD & analytics
│   └── attendanceController.js # Attendance marking & reports
├── models/
│   ├── Student.js              # Student schema
│   └── Attendance.js           # Attendance records
├── routes/
│   ├── studentRoutes.js        # /api/students endpoints
│   └── attendanceRoutes.js     # /api/attendance endpoints
├── middleware/
│   └── upload.js               # Multer configuration
├── uploads/
│   └── students/               # Student profile images
├── package.json                # Dependencies
├── .env                        # Environment variables (not in git)
└── README.md                   # This file
```

## 🚀 Getting Started

### Installation

```bash
# Install dependencies
npm install

# Create .env file
cat > .env << EOF
MONGO_URI=mongodb://localhost:27017/attendance_system
PORT=5000
JWT_SECRET=your_jwt_secret_key_here
EOF

# Start development server
npm run dev

# Or production server
npm start
```

### Environment Variables

Create `.env` file in root directory:

```env
# Database
MONGO_URI=mongodb://username:password@hostname:port/database_name

# Server
PORT=5000

# Authentication
JWT_SECRET=your_secure_secret_key_minimum_32_characters

# Optional
NODE_ENV=development
```

## 📡 API Endpoints

### Base URL

```
http://localhost:5000/api
```

### Student Routes (`/api/students`)

#### Get All Students

```http
GET /api/students
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "John Doe",
      "rollNumber": "CS001",
      "email": "john@example.com",
      "department": "Computer Science",
      "semester": "4",
      "profileImage": "/uploads/students/image.jpg",
      "faceEmbedding": [0.1, 0.2, ...],
      "createdAt": "2026-06-01T10:30:00Z",
      "updatedAt": "2026-06-01T10:30:00Z"
    }
  ],
  "count": 1
}
```

#### Get Student by ID

```http
GET /api/students/:id
```

**Example:**

```http
GET /api/students/507f1f77bcf86cd799439011
```

#### Register New Student

```http
POST /api/students/register
Content-Type: application/json

{
  "name": "John Doe",
  "rollNumber": "CS001",
  "email": "john@example.com",  // Optional
  "department": "Computer Science",
  "semester": "4",
  "faceEmbedding": [0.1, 0.2, 0.3, ...] // From AI service
}
```

#### Update Student

```http
PUT /api/students/:id
Content-Type: application/json

{
  "name": "John Smith",
  "email": "john.smith@example.com",
  "semester": "5"
}
```

#### Delete Student

```http
DELETE /api/students/:id
```

### Attendance Routes (`/api/attendance`)

#### Mark Attendance

```http
POST /api/attendance/mark
Content-Type: application/json

{
  "studentId": "507f1f77bcf86cd799439011",
  "status": "Present",
  "confidence": 0.95,
  "faceEmbedding": [0.1, 0.2, ...],
  "date": "2026-06-17T10:30:00Z"
}
```

#### Get Attendance by Date

```http
GET /api/attendance/by-date?date=2026-06-17
```

#### Get Student Attendance History

```http
GET /api/attendance/by-student/507f1f77bcf86cd799439011
```

#### Get Attendance Analytics

```http
GET /api/attendance/analytics?range=month&month=06&year=2026
```

**Query Parameters:**

- `range`: "day" | "month" | "year" | "date"
- `month`: MM (required if range=month)
- `year`: YYYY (required if range=month/year)
- `date`: YYYY-MM-DD (required if range=date)

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "date": "2026-06-17",
      "totalStudents": 50,
      "presentCount": 45,
      "absentCount": 5,
      "attendancePercentage": 90,
      "department": "CSE",
      "semester": "4"
    }
  ]
}
```

#### Get Monthly Report

```http
GET /api/attendance/monthly-report?month=06&year=2026&department=CSE&semester=4
```

**Query Parameters:**

- `month`: MM
- `year`: YYYY
- `department`: Department name (optional)
- `semester`: Semester (optional)

#### Get/Delete Attendance Record

```http
GET /api/attendance/:id
DELETE /api/attendance/:id
```

## 🗄️ Database Models

### Student Model

```javascript
{
  _id: ObjectId,
  name: {
    type: String,
    required: true
  },
  rollNumber: {
    type: String,
    required: true,
    unique: true
  },
  email: {
    type: String,
    required: false,
    unique: true,
    sparse: true  // Allows null values while maintaining uniqueness
  },
  department: {
    type: String,
    required: true
  },
  semester: {
    type: String,
    required: true
  },
  profileImage: String,
  faceEmbedding: [Number], // Vector from InsightFace
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}
```

### Attendance Model

```javascript
{
  _id: ObjectId,
  studentId: {
    type: ObjectId,
    ref: 'Student',
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['Present', 'Absent'],
    required: true
  },
  confidence: {
    type: Number,
    min: 0,
    max: 1
  },
  faceEmbedding: [Number],
  recordedAt: Date,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}
```

## 💾 Database Connection

Mongoose connects to MongoDB using the `MONGO_URI` from environment variables:

```javascript
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB Connected"))
  .catch((error) => console.log(error));
```

## 🔍 Analytics Query Logic

### Absent Count Calculation

```javascript
absentCount = Math.max(totalStudents - presentCount, absentRecordsCount);
```

### Attendance Percentage

```javascript
attendancePercentage = (presentCount / totalStudents) * 100;
```

### Total Records

```javascript
totalRecords = totalStudents; // All enrolled students
```

## 📦 Middleware

### CORS

Enabled for cross-origin requests from Flutter mobile app:

```javascript
app.use(cors());
```

### JSON Parser

```javascript
app.use(express.json());
```

### File Upload (Multer)

Configured in `middleware/upload.js`:

```javascript
const multer = require("multer");
const storage = multer.diskStorage({
  destination: "./uploads/students/",
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});
const upload = multer({ storage });
```

## 🔐 Security Features

1. **JWT Authentication** - Secure API access
2. **Input Validation** - Server-side validation
3. **CORS Protection** - Control cross-origin requests
4. **Password Hashing** - Bcryptjs for secure passwords
5. **Environment Variables** - Sensitive data protection
6. **Sparse Indexes** - Safe null handling for optional unique fields

## 🚀 Running the Application

### Development Mode

```bash
npm run dev
# Uses nodemon for auto-restart on file changes
```

### Production Mode

```bash
npm start
```

### Server Status

```
✓ MongoDB Connected
✓ Server Running on Port 5000
✓ API Running at http://localhost:5000
```

## 📊 Sample Requests

### Register Student with cURL

```bash
curl -X POST http://localhost:5000/api/students/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "rollNumber": "CS001",
    "email": "john@example.com",
    "department": "Computer Science",
    "semester": "4",
    "faceEmbedding": [0.1, 0.2, 0.3]
  }'
```

### Get Analytics

```bash
curl "http://localhost:5000/api/attendance/analytics?range=month&month=06&year=2026"
```

### Mark Attendance

```bash
curl -X POST http://localhost:5000/api/attendance/mark \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": "507f1f77bcf86cd799439011",
    "status": "Present",
    "confidence": 0.95,
    "faceEmbedding": [0.1, 0.2, 0.3]
  }'
```

## 🐛 Error Handling

All endpoints return standardized error responses:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

### Common Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `404` - Not Found
- `500` - Server Error

## 🧪 Testing

Run tests (when configured):

```bash
npm test
```

Currently no tests configured. To add tests:

```bash
npm install --save-dev jest
```

## 📈 Performance Optimization

1. **Aggregation Pipelines** - Efficient MongoDB queries
2. **Indexing** - Optimized database indexes
3. **Pagination** - Handle large datasets
4. **Caching** - Reduce database queries (when implemented)

## 🔄 Integration with AI Service

The backend communicates with Python AI service for face recognition:

```javascript
// Example: Send image to AI service for face embedding
const response = await axios.post("http://localhost:8000/enroll-face", {
  image_path: "/path/to/image.jpg",
});

const embedding = response.data.embedding;
```

## 📝 Environment Setup Example

```bash
# Complete .env file example
MONGO_URI=mongodb://localhost:27017/attendance_system
PORT=5000
JWT_SECRET=sk_dev_1234567890abcdefghijklmnopqrst
NODE_ENV=development
```

## 🚨 Common Issues & Solutions

| Issue                     | Cause                  | Solution                  |
| ------------------------- | ---------------------- | ------------------------- |
| MongoDB connection failed | MongoDB not running    | Start MongoDB: `mongod`   |
| Port 5000 already in use  | Another app using port | Change PORT in .env       |
| CORS errors               | Origin not allowed     | Update CORS configuration |
| Token invalid             | JWT expired            | Request new token         |
| File upload failed        | Wrong path/permissions | Check uploads directory   |

## 📚 Dependencies Documentation

- [Express.js Docs](https://expressjs.com/)
- [Mongoose Docs](https://mongoosejs.com/)
- [JWT Docs](https://jwt.io/)
- [Multer Docs](https://github.com/expressjs/multer)

## 🤝 Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Commit with clear message
5. Push and create Pull Request

## 📄 License

ISC License - See main project LICENSE file

## 👨‍💻 Author

**Shivam Kumar**  
Version: 1.0.0  
Last Updated: June 2026

---

**Status**: Production Ready ✅
