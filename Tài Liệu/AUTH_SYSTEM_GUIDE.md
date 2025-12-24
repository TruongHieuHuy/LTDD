# 🔐 Authentication System - Mini Game Center

## Tổng quan

Project này sử dụng hệ thống authentication **TỐT HƠN** so với các hướng dẫn cơ bản, với:
- ✅ **Provider Pattern** cho state management
- ✅ **Hive Database** thay vì SharedPreferences
- ✅ **JWT Authentication** với auto-refresh
- ✅ **Type-safe** với Models và ApiResponse wrapper

---

## 📁 Cấu trúc thư mục

```
lib/
├── config/
│   └── config_url.dart          # Quản lý API URLs từ .env
├── models/
│   └── auth_model.dart          # AuthModel, UserProfile, ApiResponse
├── providers/
│   └── auth_provider.dart       # AuthProvider (State Management)
├── services/
│   └── api_service.dart         # API Client (HTTP requests)
└── screens/
    └── login_screen.dart        # Login/Register UI
```

---

## 🔧 Setup

### 1. Cài đặt Dependencies

Đã được cài đặt sẵn trong `pubspec.yaml`:

```yaml
dependencies:
  provider: ^6.1.2              # State management
  hive: ^2.2.3                  # Local database
  hive_flutter: ^1.1.0
  http: ^1.6.0                  # HTTP client
  jwt_decoder: ^2.0.1           # JWT token decoder
  flutter_dotenv: ^6.0.0        # Environment variables
```

### 2. Cấu hình .env

Copy file `.env.example` thành `.env`:

```bash
cp .env.example .env
```

Chỉnh sửa `.env`:

```env
# Android Emulator
BASE_URL=http://10.0.2.2:3000

# iOS Simulator
# BASE_URL=http://localhost:3000

# Physical Device (thay YOUR_IP)
# BASE_URL=http://192.168.1.100:3000
```

⚠️ **LƯU Ý**: File `.env` đã được thêm vào `.gitignore`, **KHÔNG PUSH** lên GitHub!

---

## 🚀 Sử dụng

### 1. Đăng ký tài khoản

```dart
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Trong Widget
final authProvider = context.read<AuthProvider>();

final result = await authProvider.register(
  username: 'johndoe',
  email: 'john@example.com',
  password: 'password123',
);

if (result.success) {
  // Đăng ký thành công, đã auto-login
  Navigator.pushNamedAndRemoveUntil(context, '/modular', (r) => false);
} else {
  // Hiển thị lỗi
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.message)),
  );
}
```

### 2. Đăng nhập

```dart
final authProvider = context.read<AuthProvider>();

final result = await authProvider.login(
  email: 'john@example.com',
  password: 'password123',
  rememberMe: true,  // Lưu email cho lần sau
);

if (result.success) {
  // Đăng nhập thành công
  Navigator.pushNamedAndRemoveUntil(context, '/modular', (r) => false);
} else {
  // Hiển thị lỗi
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.message)),
  );
}
```

### 3. Lấy thông tin user (trong Widget)

```dart
// Sử dụng watch để auto-rebuild khi state thay đổi
final authProvider = context.watch<AuthProvider>();

if (authProvider.isLoggedIn) {
  final username = authProvider.username;
  final email = authProvider.userEmail;
  final totalScore = authProvider.totalScore;
  final userId = authProvider.userId;
  
  return Text('Welcome, $username!');
} else {
  return Text('Please login');
}
```

### 4. Kiểm tra trạng thái đăng nhập

```dart
final authProvider = context.read<AuthProvider>();

if (authProvider.isLoggedIn) {
  // User đã đăng nhập
  final token = authProvider.token;
  // API calls sẽ tự động include token
} else {
  // Chuyển đến login screen
  Navigator.pushNamed(context, '/login');
}
```

### 5. Đăng xuất

```dart
final authProvider = context.read<AuthProvider>();

await authProvider.logout();

// Chuyển về login screen
Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
```

### 6. Refresh user profile

```dart
final authProvider = context.read<AuthProvider>();

// Refresh profile từ server
await authProvider.refreshProfile();

// Profile đã được update
print('Score: ${authProvider.totalScore}');
```

---

## 🔑 API Endpoints

### Base URL
Được quản lý bởi `ConfigUrl.baseUrl` từ file `.env`

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Đăng ký tài khoản mới |
| POST | `/api/auth/login` | Đăng nhập |
| GET | `/api/auth/me` | Lấy thông tin user hiện tại |
| POST | `/api/auth/forgot-password` | Quên mật khẩu |
| POST | `/api/auth/reset-password` | Reset mật khẩu |

### Helper Methods trong ConfigUrl

```dart
ConfigUrl.baseUrl           // http://10.0.2.2:3000
ConfigUrl.apiAuth           // http://10.0.2.2:3000/api/auth
ConfigUrl.apiGames          // http://10.0.2.2:3000/api/games
ConfigUrl.apiFriends        // http://10.0.2.2:3000/api/friends
ConfigUrl.apiPosts          // http://10.0.2.2:3000/api/posts
ConfigUrl.apiLeaderboard    // http://10.0.2.2:3000/api/leaderboard
ConfigUrl.apiAchievements   // http://10.0.2.2:3000/api/achievements
```

---

## 🏗️ Architecture

### Flow Diagram

```
┌─────────────────┐
│  LoginScreen    │
└────────┬────────┘
         │ user input
         ▼
┌─────────────────┐
│  AuthProvider   │ ◄── State Management (Provider)
└────────┬────────┘
         │ call API
         ▼
┌─────────────────┐
│   ApiService    │ ◄── HTTP Client (auto inject token)
└────────┬────────┘
         │ HTTP request
         ▼
┌─────────────────┐
│   Backend API   │ (Node.js + Express + Prisma)
└────────┬────────┘
         │ response
         ▼
┌─────────────────┐
│   ApiService    │ ◄── Parse response
└────────┬────────┘
         │ return ApiResponse<T>
         ▼
┌─────────────────┐
│  AuthProvider   │ ◄── Save to Hive + notifyListeners()
└────────┬────────┘
         │ update UI
         ▼
┌─────────────────┐
│  LoginScreen    │ ◄── Rebuild with new state
└─────────────────┘
```

### Hive Storage

```dart
Box: 'authBox'
├── 'currentAuth'    → AuthModel {token, email, expiryDate}
├── 'savedEmail'     → String (for remember me)
└── 'userProfile'    → UserProfile {id, username, totalScore, ...}
```

---

## 🔒 Security Features

### 1. JWT Token
- ✅ Auto-inject vào header của mọi API request
- ✅ Validate expiry date trước khi sử dụng
- ✅ Auto-clear khi token expired

### 2. Secure Storage
- ✅ Sử dụng Hive (encrypted local database)
- ✅ Token không bao giờ hardcode trong code
- ✅ Auto-clear khi logout

### 3. Error Handling
- ✅ ApiResponse wrapper cho tất cả API calls
- ✅ Network error handling
- ✅ Authentication error handling (401/403)

### 4. Environment Variables
- ✅ API URLs từ `.env` file
- ✅ `.env` trong `.gitignore`
- ✅ `.env.example` cho team

---

## 📊 Models

### AuthModel
```dart
class AuthModel {
  String email;
  String sessionToken;
  DateTime expiryDate;
  bool isLoggedIn;
  
  bool get isSessionValid => 
    isLoggedIn && 
    sessionToken.isNotEmpty && 
    expiryDate.isAfter(DateTime.now());
}
```

### UserProfile
```dart
class UserProfile {
  String id;
  String username;
  String email;
  int totalScore;
  int totalGamesPlayed;
  String? avatarUrl;
  DateTime createdAt;
}
```

### ApiResponse
```dart
class ApiResponse<T> {
  bool success;
  String message;
  T? data;
  
  factory ApiResponse.success(T data, [String? message]);
  factory ApiResponse.error(String message);
}
```

---

## 🐛 Troubleshooting

### 1. Lỗi "Target of URI doesn't exist: 'package:flutter_dotenv/flutter_dotenv.dart'"

**Nguyên nhân**: Chưa cài package `flutter_dotenv`

**Giải pháp**:
```bash
flutter pub add flutter_dotenv
flutter pub get
```

### 2. Lỗi "BASE_URL is not set in the .env file"

**Nguyên nhân**: File `.env` chưa tồn tại hoặc chưa khai báo BASE_URL

**Giải pháp**:
1. Copy `.env.example` thành `.env`
2. Thêm dòng: `BASE_URL=http://10.0.2.2:3000`
3. Thêm `.env` vào `pubspec.yaml`:
```yaml
flutter:
  assets:
    - .env
```

### 3. Lỗi kết nối API (Network Error)

**Nguyên nhân**: URL không đúng với platform

**Giải pháp**:
- **Android Emulator**: `http://10.0.2.2:3000`
- **iOS Simulator**: `http://localhost:3000`
- **Physical Device**: `http://<YOUR_IP>:3000`

### 4. Lỗi 401 Unauthorized

**Nguyên nhân**: Token expired hoặc không hợp lệ

**Giải pháp**:
```dart
final authProvider = context.read<AuthProvider>();
await authProvider.logout();
await authProvider.login(email: email, password: password);
```

---

## 🎯 Best Practices

### 1. Luôn dùng Provider.of hoặc context.read/watch

❌ **KHÔNG NÊN**:
```dart
final authProvider = AuthProvider(); // Tạo instance mới
await authProvider.login(...);
```

✅ **NÊN**:
```dart
final authProvider = context.read<AuthProvider>();
await authProvider.login(...);
```

### 2. Dùng watch để auto-rebuild UI

❌ **KHÔNG NÊN**:
```dart
final authProvider = context.read<AuthProvider>();
return Text('Score: ${authProvider.totalScore}'); // Không auto-update
```

✅ **NÊN**:
```dart
final authProvider = context.watch<AuthProvider>();
return Text('Score: ${authProvider.totalScore}'); // Auto-update khi score thay đổi
```

### 3. Check isLoggedIn trước khi gọi API

✅ **NÊN**:
```dart
if (authProvider.isLoggedIn) {
  await apiService.submitScore(...);
} else {
  Navigator.pushNamed(context, '/login');
}
```

### 4. Handle errors properly

✅ **NÊN**:
```dart
final result = await authProvider.login(...);
if (!result.success && mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.message)),
  );
}
```

---

## 📚 Tài liệu liên quan

- [AUTH_COMPARISON.md](./AUTH_COMPARISON.md) - So sánh với các cách implement khác
- [BACKEND_ARCHITECTURE_DESIGN.md](./BACKEND_ARCHITECTURE_DESIGN.md) - Backend API design
- [AUTH_TESTING_GUIDE.md](./AUTH_TESTING_GUIDE.md) - Hướng dẫn test authentication

---

## 💡 Tips

1. **Auto-login**: Khi mở app, AuthProvider tự động check token trong Hive và restore session nếu còn hạn
2. **Remember me**: Lưu email để auto-fill lần sau
3. **Profile caching**: User profile được cache offline, giảm API calls
4. **Token refresh**: Profile tự động refresh từ server khi cần
5. **Type-safe**: Tất cả API responses đều có type với Models

---

**Tạo bởi**: Mini Game Center Team  
**Ngày cập nhật**: 24/12/2025  
**Version**: 1.0.0
