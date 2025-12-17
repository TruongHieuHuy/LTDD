# 🚀 HƯỚNG DẪN XÂY DỰNG BACKEND - WEEK 1

**Mục tiêu**: Setup Backend cơ bản trong 5-7 ngày  
**Stack**: Node.js + Express + MongoDB + JWT  
**Kết quả**: API Register/Login + Save Score hoạt động

---

## 📋 CHECKLIST WEEK 1

- [ ] **Ngày 1**: Setup project + Database connection
- [ ] **Ngày 2**: Authentication API (Register/Login)
- [ ] **Ngày 3**: Game Score API (CRUD)
- [ ] **Ngày 4**: Test API với Postman
- [ ] **Ngày 5**: Deploy lên cloud (Render/Railway)

---

## BƯỚC 1: SETUP PROJECT (30 phút)

### 1.1 Cài đặt Node.js

```bash
# Kiểm tra Node.js đã cài chưa
node --version  # Cần >= 18.x

# Nếu chưa có, download từ: https://nodejs.org/
```

### 1.2 Tạo project mới

```bash
# Tạo thư mục project
mkdir game-backend
cd game-backend

# Khởi tạo npm
npm init -y

# Cài đặt dependencies
npm install express mongoose dotenv bcryptjs jsonwebtoken cors
npm install --save-dev nodemon
```

### 1.3 Cấu trúc thư mục

```bash
game-backend/
├── src/
│   ├── config/
│   │   └── database.js       # MongoDB connection
│   ├── models/
│   │   ├── User.js           # User schema
│   │   └── GameScore.js      # GameScore schema
│   ├── routes/
│   │   ├── auth.js           # Auth routes
│   │   └── scores.js         # Score routes
│   ├── middleware/
│   │   └── auth.js           # JWT verification
│   └── server.js             # Entry point
├── .env                      # Environment variables
├── .gitignore
└── package.json
```

**Tạo file .gitignore**:
```
node_modules/
.env
```

---

## BƯỚC 2: SETUP DATABASE (30 phút)

### 2.1 Tạo MongoDB Database (MIỄN PHÍ)

**Option A: MongoDB Atlas (Recommended)**

1. Truy cập: https://www.mongodb.com/cloud/atlas/register
2. Đăng ký tài khoản miễn phí
3. Tạo cluster mới (chọn FREE tier)
4. Create Database: `game_mobile_db`
5. Create User: Username + Password
6. Network Access: Add `0.0.0.0/0` (allow all IPs)
7. Copy Connection String: `mongodb+srv://...`

**Option B: MongoDB Local**
```bash
# Windows - Download từ https://www.mongodb.com/try/download/community
# Sau khi cài, chạy:
mongod

# Connection string: mongodb://localhost:27017/game_mobile_db
```

### 2.2 Tạo file .env

```env
# .env
PORT=3000
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/game_mobile_db?retryWrites=true&w=majority
JWT_SECRET=your_super_secret_key_change_this_in_production_12345
NODE_ENV=development
```

> ⚠️ **LƯU Ý**: Thay `username`, `password`, và JWT_SECRET bằng giá trị thực

### 2.3 Tạo Database Connection

**File: src/config/database.js**
```javascript
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ MongoDB connected successfully');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    process.exit(1); // Exit if cannot connect
  }
};

module.exports = connectDB;
```

---

## BƯỚC 3: TẠO MODELS (30 phút)

### 3.1 User Model

**File: src/models/User.js**
```javascript
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: [true, 'Username is required'],
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 20,
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Invalid email format'],
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: 6,
  },
  avatarUrl: {
    type: String,
    default: null,
  },
  totalGamesPlayed: {
    type: Number,
    default: 0,
  },
  totalScore: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  lastLoginAt: {
    type: Date,
    default: Date.now,
  },
});

// Hash password trước khi save
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Method để so sánh password
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
```

### 3.2 GameScore Model

**File: src/models/GameScore.js**
```javascript
const mongoose = require('mongoose');

const gameScoreSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  gameType: {
    type: String,
    required: true,
    enum: ['rubik', 'sudoku', 'caro', 'puzzle'],
  },
  score: {
    type: Number,
    required: true,
  },
  attempts: {
    type: Number,
    default: 1,
  },
  difficulty: {
    type: String,
    required: true,
    enum: ['easy', 'medium', 'hard', 'expert'],
  },
  timeSpent: {
    type: Number, // seconds
    default: 0,
  },
  gameData: {
    type: mongoose.Schema.Types.Mixed, // Game-specific data
    default: {},
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
  version: {
    type: Number,
    default: 1,
  },
});

// Index để query nhanh
gameScoreSchema.index({ userId: 1, gameType: 1, timestamp: -1 });
gameScoreSchema.index({ gameType: 1, score: -1 }); // For leaderboard

module.exports = mongoose.model('GameScore', gameScoreSchema);
```

---

## BƯỚC 4: AUTHENTICATION API (2 giờ)

### 4.1 JWT Middleware

**File: src/middleware/auth.js**
```javascript
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const authenticate = async (req, res, next) => {
  try {
    // Lấy token từ header
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ 
        success: false,
        message: 'No token provided' 
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Tìm user
    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    // Attach user to request
    req.user = user;
    req.userId = user._id;
    next();
  } catch (error) {
    res.status(401).json({ 
      success: false,
      message: 'Invalid or expired token' 
    });
  }
};

module.exports = authenticate;
```

### 4.2 Auth Routes

**File: src/routes/auth.js**
```javascript
const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const authenticate = require('../middleware/auth');

const router = express.Router();

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
};

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Validate input
    if (!username || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required',
      });
    }

    // Check if user exists
    const existingUser = await User.findOne({
      $or: [{ email }, { username }],
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Username or email already exists',
      });
    }

    // Create user
    const user = new User({ username, email, password });
    await user.save();

    // Generate token
    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      message: 'Registration successful',
      data: {
        user: {
          id: user._id,
          username: user.username,
          email: user.email,
        },
        token,
      },
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during registration',
    });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required',
      });
    }

    // Find user
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // Update last login
    user.lastLoginAt = new Date();
    await user.save();

    // Generate token
    const token = generateToken(user._id);

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user._id,
          username: user.username,
          email: user.email,
          totalGamesPlayed: user.totalGamesPlayed,
          totalScore: user.totalScore,
        },
        token,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login',
    });
  }
});

// GET /api/auth/me (Get current user)
router.get('/me', authenticate, async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        user: {
          id: req.user._id,
          username: req.user.username,
          email: req.user.email,
          totalGamesPlayed: req.user.totalGamesPlayed,
          totalScore: req.user.totalScore,
        },
      },
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router;
```

---

## BƯỚC 5: GAME SCORE API (1 giờ)

**File: src/routes/scores.js**
```javascript
const express = require('express');
const GameScore = require('../models/GameScore');
const User = require('../models/User');
const authenticate = require('../middleware/auth');

const router = express.Router();

// POST /api/scores (Save new score)
router.post('/', authenticate, async (req, res) => {
  try {
    const { gameType, score, attempts, difficulty, timeSpent, gameData } = req.body;

    // Validate
    if (!gameType || score === undefined || !difficulty) {
      return res.status(400).json({
        success: false,
        message: 'Game type, score, and difficulty are required',
      });
    }

    // Create score
    const gameScore = new GameScore({
      userId: req.userId,
      gameType,
      score,
      attempts,
      difficulty,
      timeSpent,
      gameData,
    });

    await gameScore.save();

    // Update user stats
    await User.findByIdAndUpdate(req.userId, {
      $inc: { totalGamesPlayed: 1, totalScore: score },
    });

    res.status(201).json({
      success: true,
      message: 'Score saved successfully',
      data: { score: gameScore },
    });
  } catch (error) {
    console.error('Save score error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// GET /api/scores (Get user's scores)
router.get('/', authenticate, async (req, res) => {
  try {
    const { gameType, limit = 50 } = req.query;

    const query = { userId: req.userId };
    if (gameType) query.gameType = gameType;

    const scores = await GameScore.find(query)
      .sort({ timestamp: -1 })
      .limit(parseInt(limit));

    res.json({
      success: true,
      data: { scores },
    });
  } catch (error) {
    console.error('Get scores error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// GET /api/scores/leaderboard (Global leaderboard)
router.get('/leaderboard', async (req, res) => {
  try {
    const { gameType = 'all', limit = 10 } = req.query;

    const query = gameType !== 'all' ? { gameType } : {};

    const leaderboard = await GameScore.find(query)
      .sort({ score: -1 })
      .limit(parseInt(limit))
      .populate('userId', 'username avatarUrl');

    res.json({
      success: true,
      data: { leaderboard },
    });
  } catch (error) {
    console.error('Leaderboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router;
```

---

## BƯỚC 6: MAIN SERVER (30 phút)

**File: src/server.js**
```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database');
const authRoutes = require('./routes/auth');
const scoresRoutes = require('./routes/scores');

const app = express();

// Middleware
app.use(cors()); // Allow cross-origin requests
app.use(express.json()); // Parse JSON body

// Connect to MongoDB
connectDB();

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Game Mobile API - Server is running!' });
});

app.use('/api/auth', authRoutes);
app.use('/api/scores', scoresRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Something went wrong!',
  });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV}`);
});
```

**File: package.json** (Thêm scripts)
```json
{
  "name": "game-backend",
  "version": "1.0.0",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^8.0.0",
    "dotenv": "^16.3.1",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.2",
    "cors": "^2.8.5"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
```

---

## BƯỚC 7: CHẠY SERVER (5 phút)

```bash
# Chạy server (dev mode - tự động restart khi code thay đổi)
npm run dev

# Hoặc chạy production
npm start
```

**Kết quả mong đợi**:
```
✅ MongoDB connected successfully
🚀 Server running on port 3000
📝 Environment: development
```

---

## BƯỚC 8: TEST API VỚI POSTMAN (30 phút)

### 8.1 Cài đặt Postman

Download: https://www.postman.com/downloads/

### 8.2 Test Register

**Request**:
```
POST http://localhost:3000/api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "123456"
}
```

**Response (Success)**:
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "id": "6583a1b2c3d4e5f6g7h8i9j0",
      "username": "testuser",
      "email": "test@example.com"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 8.3 Test Login

**Request**:
```
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "123456"
}
```

### 8.4 Test Save Score

**Request**:
```
POST http://localhost:3000/api/scores
Authorization: Bearer <YOUR_TOKEN_HERE>
Content-Type: application/json

{
  "gameType": "sudoku",
  "score": 1500,
  "attempts": 1,
  "difficulty": "hard",
  "timeSpent": 300
}
```

### 8.5 Test Leaderboard

**Request**:
```
GET http://localhost:3000/api/scores/leaderboard?gameType=sudoku&limit=10
```

---

## BƯỚC 9: DEPLOY LÊN CLOUD (1 giờ) - OPTIONAL

### Option A: Render.com (MIỄN PHÍ)

1. Push code lên GitHub
2. Truy cập: https://render.com/
3. Create New → Web Service
4. Connect GitHub repo
5. Build Command: `npm install`
6. Start Command: `npm start`
7. Add Environment Variables (từ .env)
8. Deploy!

**URL**: `https://your-app.onrender.com`

### Option B: Railway.app

1. Truy cập: https://railway.app/
2. New Project → Deploy from GitHub
3. Add variables từ .env
4. Deploy tự động!

---

## ✅ CHECKLIST HOÀN THÀNH

Sau khi làm xong, bạn cần có:

- [x] ✅ Server chạy được ở localhost:3000
- [x] ✅ MongoDB Atlas hoạt động
- [x] ✅ Register user thành công
- [x] ✅ Login trả về JWT token
- [x] ✅ Save score với token authentication
- [x] ✅ Leaderboard hiển thị top 10
- [x] ✅ Test tất cả API bằng Postman

---

## 🚨 TROUBLESHOOTING

### Lỗi: "MongoDB connection error"
```bash
# Kiểm tra MONGO_URI trong .env
# Đảm bảo username/password đúng
# Kiểm tra Network Access trên MongoDB Atlas
```

### Lỗi: "Cannot find module"
```bash
# Cài lại dependencies
npm install
```

### Lỗi: "Port 3000 already in use"
```bash
# Thay PORT trong .env
PORT=5000
```

---

## 📚 NEXT STEPS

Sau khi Backend Week 1 hoàn thành:

1. ✅ **Week 2**: Bắt đầu làm game Sudoku (dễ nhất)
2. ✅ **Week 3**: Làm game Puzzle
3. ⚠️ **Week 4**: Làm game Caro (nhớ dùng Isolate!)
4. 🔴 **Week 5**: Làm game Rubik (tìm package!)

---

**Version**: 1.0  
**Last Updated**: 18/12/2025  
**Estimated Time**: 1 day (8 hours)
