# 🎓 Smart Attendance System

**AI-Powered Face Recognition Attendance Management System**

A comprehensive full-stack solution for automated student attendance tracking using facial recognition technology, with real-time analytics and comprehensive reporting capabilities.

## 🌟 Features

✅ **AI-Powered Face Recognition** - InsightFace-based facial recognition  
✅ **Real-time Attendance** - Mark attendance with live camera capture  
✅ **Multi-level Analytics** - Daily, Monthly, and Yearly reports  
✅ **Interactive Dashboard** - Pie charts and attendance visualizations  
✅ **PDF Exports** - Generate detailed attendance reports  
✅ **Department/Semester Filtering** - Organized student management  
✅ **Mobile-First** - Responsive Flutter UI for all devices  
✅ **Secure APIs** - JWT authentication and CORS protection

## 🏗️ System Architecture

```
┌────────────────────────────────────────────────┐
│         Flutter Mobile Application              │
│  (Dashboard, Reports, Student Management)      │
└─────────────────────┬──────────────────────────┘
                      │ HTTP/REST API
┌─────────────────────▼──────────────────────────┐
│     Node.js Express Backend (Port 5000)         │
│  (Student CRUD, Attendance Tracking, Analytics)│
└────────────┬──────────────────────────┬────────┘
             │                          │
      ┌──────▼──────┐          ┌────────▼────────┐
      │   MongoDB   │          │  Python FastAPI │
      │  (Database) │          │  (Port 8000)    │
      └─────────────┘          │  AI Recognition │
                               └─────────────────┘
```

## 📦 Project Structure

```
smart-attendance-system/
│
├── frontend/
│   └── mobile_app/                    # Flutter mobile application
│       ├── lib/
│       │   ├── screens/               # UI Screens (8 screens)
│       │   ├── services/              # API & Face Recognition services
│       │   ├── models/                # Data models
│       │   ├── widgets/               # Reusable components
│       │   └── utils/                 # PDF generation & helpers
│       ├── android/                   # Android native code
│       ├── ios/                       # iOS native code
│       └── pubspec.yaml               # Flutter dependencies
│
├── backend/                           # Node.js Express API
│   ├── server.js                      # Entry point
│   ├── controllers/                   # Business logic
│   ├── models/                        # MongoDB schemas
│   ├── routes/                        # API endpoints
│   ├── middleware/                    # Upload handling
│   └── package.json                   # Node dependencies
│
├── ai-service/                        # Python FastAPI
│   ├── app.py                         # FastAPI app
│   ├── services/                      # Face recognition logic
│   ├── face_detection/                # Detection models
│   ├── face_recognition/              # Recognition models
│   └── requirements.txt               # Python dependencies
│
└── docker/                            # Docker configuration

```

## 🛠️ Tech Stack

### Frontend

- **Flutter** 3.12.1 - Cross-platform mobile UI
- **Dart** - Programming language
- **fl_chart** - Data visualization (pie charts)
- **http** - REST API client
- **image_picker** - Camera/gallery integration
- **pdf + printing** - Report generation & export
- **intl** - Date formatting (standardized: dd MMM yyyy, hh:mm a)

### Backend

- **Node.js** - Runtime environment
- **Express.js** 5.2.1 - Web framework
- **Mongoose** 9.6.3 - MongoDB ODM
- **JWT** - Authentication
- **Multer** - File upload handling
- **CORS** - Cross-origin requests
- **Nodemon** - Development server

### AI Service

- **FastAPI** - Modern Python web framework
- **InsightFace** - Face detection & recognition
- **NumPy** - Numerical computations
- **OpenCV** - Image processing
- **SciPy** - Scientific computing

### Database

- **MongoDB** 4.4+ - Document database
- Collections: Students, Attendance

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK**: ^3.12.1
- **Node.js**: ^16.0
- **Python**: ^3.8
- **MongoDB**: 4.4+
- **Android Studio** or **Xcode** (for mobile dev)

### Installation

#### 1. Clone Repository

```bash
git clone <repository-url>
cd smart-attendance-system
```

#### 2. Backend Setup

```bash
cd backend
npm install

# Create .env file
echo "MONGO_URI=mongodb://localhost:27017/attendance_system" > .env
echo "PORT=5000" >> .env
echo "JWT_SECRET=your_secret_key" >> .env

npm run dev
```

#### 3. AI Service Setup

```bash
cd ai-service
pip install -r requirements.txt
python app.py
```

#### 4. Frontend Setup

```bash
cd frontend/mobile_app
flutter pub get
flutter run
```

## 📡 API Endpoints

### Students (`/api/students`)

| Method | Endpoint           | Description                           |
| ------ | ------------------ | ------------------------------------- |
| GET    | `/`                | Get all students                      |
| GET    | `/:id`             | Get student by ID                     |
| POST   | `/register`        | Register a new student                |
| PUT    | `/:id`             | Update student details                |
| DELETE | `/:id`             | Delete student and attendance records |
| POST   | `/upload-face/:id` | Upload student face image             |
| POST   | `/enroll-face/:id` | Enroll student face embedding         |
| GET    | `/report/:id`      | Get student attendance report         |

### Attendance (`/api/attendance`)

| Method | Endpoint          | Description                        |
| ------ | ----------------- | ---------------------------------- |
| POST   | `/mark`           | Mark attendance manually           |
| POST   | `/recognize`      | Recognize face and mark attendance |
| POST   | `/recognize-live` | Recognize live image upload        |
| GET    | `/`               | Get all attendance records         |
| GET    | `/student/:id`    | Get attendance by student          |
| DELETE | `/:id`            | Delete attendance record           |
| GET    | `/report`         | Get today's attendance report      |
| GET    | `/summary`        | Get student attendance summary     |
| GET    | `/analytics`      | Get attendance analytics           |
| GET    | `/recent`         | Get recent attendance records      |
| GET    | `/date/:date`     | Get attendance by date             |
| GET    | `/monthly-report` | Get filtered monthly report        |

### AI Service (`http://localhost:8000`)

| Method | Endpoint          | Description                    |
| ------ | ----------------- | ------------------------------ |
| GET    | `/`               | Service status                 |
| GET    | `/health`         | Health check                   |
| POST   | `/enroll-face`    | Generate face embedding        |
| POST   | `/recognize-face` | Recognize a face from an image |

## 📊 Database Schema

### Student

```javascript
{
  _id: ObjectId,
  name: String,
  rollNumber: String (unique),
  email: String (optional, unique if provided),
  department: String,
  semester: String,
  profileImage: String,
  faceEmbedding: [Number], // Face vector
  createdAt: Date,
  updatedAt: Date
}
```

### Attendance

```javascript
{
  _id: ObjectId,
  studentId: ObjectId,
  date: Date,
  status: String ("Present" | "Absent"),
  confidence: Number (0-1),
  faceEmbedding: [Number],
  recordedAt: Date,
  createdAt: Date
}
```

## 🎯 Main Screens

1. **Dashboard Screen** - Overview with recent attendance
2. **Students Screen** - Student list with management
3. **Mark Attendance** - Face recognition camera
4. **Attendance History** - Records by date with search
5. **Reports Screen** - Daily/Monthly/Yearly analytics with pie charts
6. **Monthly Report** - Department/Semester filtered report
7. **Student Details** - Individual student analytics
8. **Add Student** - New student registration

## 📊 Analytics Features

### Dashboard Reports

- **Daily View**: Today's attendance
- **Monthly View**: Current month statistics
- **Yearly View**: Annual attendance
- **Visualization**: Pie charts (Present vs Absent)
- **Metrics**: Count, percentage, confidence scores
- **Export**: PDF with formatted data

### Monthly Reports

- Department filtering
- Semester/Class filtering
- Student-wise attendance days
- Summary statistics
- PDF export with metadata

## 🔄 Workflow

```
1. Student Registration
   └─ Capture face photo → AI generates embedding → Store in DB

2. Attendance Marking
   └─ Capture image → AI recognizes face → Mark attendance → Update DB

3. Analytics
   └─ Fetch records → Filter by range → Calculate stats → Generate PDF
```

## 📝 Configuration

### Backend `.env`

```env
MONGO_URI=mongodb://localhost:27017/attendance_system
PORT=5000
JWT_SECRET=your_secure_key_here
```

### Frontend API URL

Update in `lib/services/api_service.dart`:

```dart
static const String baseUrl = "http://192.168.x.x:5000";
```

## 🚀 Running the Application

**Terminal 1 - Backend**

```bash
cd backend
npm run dev
# Server on http://localhost:5000
```

**Terminal 2 - AI Service**

```bash
cd ai-service
python app.py
# Service on http://localhost:8000
```

**Terminal 3 - Mobile App**

```bash
cd frontend/mobile_app
flutter run
# App on connected device/emulator
```

**Database**

```bash
# Ensure MongoDB is running
mongod
```

## 📱 Build for Production

### Android APK

```bash
cd frontend/mobile_app
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS App

```bash
cd frontend/mobile_app
flutter build ios --release
```

## 🐛 Troubleshooting

| Issue                     | Solution                                                   |
| ------------------------- | ---------------------------------------------------------- |
| MongoDB connection failed | Verify MongoDB is running, check MONGO_URI                 |
| API calls timeout         | Check backend server (port 5000), update IP address        |
| Face recognition fails    | Ensure AI service (port 8000) is running, clear image path |
| Flutter build errors      | Run `flutter clean && flutter pub get`                     |
| Student email conflicts   | Email is optional; skip if not needed                      |

## 🔐 Security

- JWT-based authentication
- Optional email validation (null-safe with sparse indexes)
- File upload validation (Multer)
- CORS protection
- Environment variables for sensitive data
- Password hashing with bcryptjs

## 📈 Performance

- Optimized MongoDB aggregation pipelines
- Async/await for non-blocking operations
- Efficient face embedding comparison
- PDF generation with streaming
- Lazy loading of attendance records

## ✅ Quality Assurance

- Date format standardization: **dd MMM yyyy, hh:mm a**
- Consistent API response format
- Error handling across all layers
- Input validation on frontend & backend
- Timezone-aware date handling

## 📚 Documentation

- **Frontend**: [frontend/mobile_app/README.md](frontend/mobile_app/README.md)
- **Backend**: See API Endpoints section
- **AI Service**: API documentation in comments

## 👨‍💻 Development

### Code Standards

- Consistent date formatting across all screens
- RESTful API design principles
- Clean architecture separation of concerns
- DRY (Don't Repeat Yourself) principle

### Git Workflow

```bash
git checkout -b feature/your-feature
git commit -m "Add your feature"
git push origin feature/your-feature
```

## 📄 License

This project is licensed under the **ISC License**. See LICENSE file for details.

## 👥 Author

**Shivam Kumar**  
Version: 1.0.0  
Last Updated: June 2026

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

For issues, questions, or feature requests, please open an issue in the repository.

---

**Status**: Production Ready ✅  
**Maintenance**: Active  
**Next Release**: TBD

