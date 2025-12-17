# ✅ HƯỚNG DẪN TEST AUTHENTICATION MỚI

## 🎯 Đã hoàn thành

### Backend (PostgreSQL + Prisma)
- ✅ Node.js + Express + PostgreSQL
- ✅ JWT Authentication 
- ✅ Register/Login API
- ✅ Game Score API + Leaderboard
- ✅ Server chạy tại: `http://localhost:3000`

### Flutter App  
- ✅ API Service (lib/services/api_service.dart)
- ✅ Auth Provider mới (kết nối Backend thật)
- ✅ Login Screen mới (có password + register)
- ✅ UserProfile cache local

---

## 🧪 CÁCH TEST

### 1. Chạy Backend (Terminal 1)
```bash
cd d:\AndroidStudioProjects\Backend
npm run dev
```

**Kết quả:**
```
🚀 Server running on port 3000
✅ PostgreSQL connected successfully via Prisma
```

### 2. Chạy Flutter App (Terminal 2)
```bash
cd d:\AndroidStudioProjects\TruongHieuHuy
flutter run
```

### 3. Test Register (Đăng ký tài khoản mới)
1. Mở app Flutter
2. Chuyển tab "Đăng ký"
3. Nhập:
   - Username: `player1` (3-20 ký tự)
   - Email: `player1@example.com`
   - Password: `123456` (tối thiểu 6 ký tự)
4. Click "Đăng ký"

**Kết quả mong đợi:**
- ✅ Tạo tài khoản thành công
- ✅ JWT token được lưu
- ✅ Tự động đăng nhập và chuyển đến màn hình chính

### 4. Test Login (Đăng nhập)
1. Logout (nếu đang đăng nhập)
2. Chuyển tab "Đăng nhập"
3. Nhập:
   - Email: `player1@example.com`
   - Password: `123456`
   - ✅ Check "Ghi nhớ đăng nhập" (30 ngày)
4. Click "Đăng nhập"

**Kết quả mong đợi:**
- ✅ Đăng nhập thành công
- ✅ Token được lưu trong Hive
- ✅ UserProfile được cache
- ✅ Chuyển đến màn hình chính

### 5. Test Auto-Login (Mở lại app)
1. Đóng app
2. Mở lại app

**Kết quả mong đợi:**
- ✅ Tự động đăng nhập (nếu đã check "Ghi nhớ")
- ✅ Không cần nhập lại password
- ✅ Profile được load từ server

---

## 🔍 KIỂM TRA DATABASE

### Xem data trong PostgreSQL
```bash
cd d:\AndroidStudioProjects\Backend
npm run prisma:studio
```

Mở browser: `http://localhost:5555`

**Xem:**
- Table `users` - Danh sách tài khoản
- Table `game_scores` - Điểm số game

---

## 📱 TEST CASES

### ✅ Test Case 1: Register với thông tin hợp lệ
**Input:**
- Username: `huy2025`
- Email: `huy@example.com`
- Password: `123456`

**Expected:**
- Success message
- Navigate to home screen
- Token saved

### ❌ Test Case 2: Register với username ngắn
**Input:**
- Username: `ab` (< 3 ký tự)
- Email: `test@example.com`
- Password: `123456`

**Expected:**
- Error: "Username must be 3-20 characters"

### ❌ Test Case 3: Register với email trùng
**Input:**
- Username: `newuser`
- Email: `player1@example.com` (đã tồn tại)
- Password: `123456`

**Expected:**
- Error: "Email already exists"

### ❌ Test Case 4: Login với sai password
**Input:**
- Email: `player1@example.com`
- Password: `wrong123`

**Expected:**
- Error: "Invalid email or password"

### ✅ Test Case 5: Login thành công + Remember Me
**Input:**
- Email: `player1@example.com`
- Password: `123456`
- Remember Me: ✅ Checked

**Expected:**
- Success
- Session 30 days
- Email saved for next login

---

## 🛠️ TROUBLESHOOTING

### Lỗi: "Network error"
**Nguyên nhân:** Backend không chạy hoặc sai URL

**Giải pháp:**
1. Check backend: `http://localhost:3000`
2. Xem API Service URL: `lib/services/api_service.dart` line 8
3. Đảm bảo `baseUrl = 'http://localhost:3000'`

### Lỗi: "Invalid email or password"
**Nguyên nhân:** Sai thông tin đăng nhập

**Giải pháp:**
1. Check email đã register chưa
2. Check password đúng chưa
3. Xem database: `npm run prisma:studio`

### Lỗi: "Email already exists"
**Nguyên nhân:** Email đã được đăng ký

**Giải pháp:**
1. Dùng email khác
2. Hoặc login với email cũ

### Lỗi: "Connection refused"
**Nguyên nhân:** Backend server không chạy

**Giải pháp:**
```bash
cd d:\AndroidStudioProjects\Backend
npm run dev
```

---

## 📊 DATA FLOW

### Register Flow:
```
Flutter App → POST /api/auth/register → Backend
                                        ↓
                                   Create User
                                        ↓
                                Generate JWT Token
                                        ↓
                         Return {user, token} → Flutter
                                                    ↓
                                              Save to Hive
                                                    ↓
                                            Navigate to Home
```

### Login Flow:
```
Flutter App → POST /api/auth/login → Backend
                                       ↓
                              Verify Password
                                       ↓
                             Generate JWT Token
                                       ↓
                        Return {user, token} → Flutter
                                                   ↓
                                           Save to Hive
                                                   ↓
                                       Set API Token Header
                                                   ↓
                                           Navigate to Home
```

### Auto-Login Flow (App Restart):
```
App Start → Load from Hive
              ↓
         Check Token Valid?
              ↓
         YES → Set API Token
              ↓
         GET /api/auth/me
              ↓
         Refresh UserProfile
              ↓
         Navigate to Home

         NO → Navigate to Login
```

---

## 🎮 NEXT STEPS

Sau khi authentication hoạt động:

1. ✅ **Test save game score**
   - Chơi game
   - Gọi `ApiService().saveScore()`
   - Xem trong database

2. ✅ **Test leaderboard**
   - Gọi `ApiService().getLeaderboard()`
   - Hiển thị top 10

3. ✅ **Bắt đầu game Sudoku**
   - Tạo `lib/screens/games/sudoku/`
   - Generate puzzle
   - Save score lên backend

---

**Version:** 1.0  
**Last Updated:** 18/12/2025  
**Status:** ✅ Backend + Auth hoạt động hoàn chỉnh
