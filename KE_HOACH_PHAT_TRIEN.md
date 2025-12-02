# Smart Student Tools - Kế Hoạch Phát Triển

## Tổng Quan Dự Án
**Tên:** Smart Student Tools (truonghieuhuy)
**Loại:** Ứng dụng Mobile Flutter
**Nền tảng:** Android & iOS
**Phiên bản hiện tại:** 1.0.0+1
**SDK:** Flutter 3.10+

### Mục Đích Dự Án
Một ứng dụng công cụ sinh viên toàn diện với các tính năng dịch thuật, quản lý báo thức, cộng tác nhóm, quản lý hồ sơ cá nhân và cài đặt.

---

## Trạng Thái Triển Khai Hiện Tại

### ✅ Các Tính Năng Đã Hoàn Thành

#### 1. **Màn Hình Dịch Thuật (Dịch thuật)**
- Hỗ trợ đa ngôn ngữ (Tiếng Việt, Tiếng Anh, Tiếng Trung, Tiếng Nhật, Tiếng Hàn, Tiếng Pháp, Tiếng Đức, Tiếng Tây Ban Nha)
- Dịch văn bản đầu vào với tính năng khử yễu
- OCR (Nhận dạng ký tự quang học) từ hình ảnh
- Chọn hình ảnh (camera/thư viện)
- Tính năng hoán đổi ngôn ngữ
- Tích hợp nhận dạng giọng nói
- Giao diện: Chủ đề tối với màu xanh lam nhấn

#### 2. **Màn Hình Báo Thức (Báo thức)**
- Tạo báo thức qua bộ chọn thời gian
- Lệnh giọng nói để tạo báo thức
- Bật/tắt báo thức
- Xóa báo thức bằng vuốt để bỏ qua
- Hoạt ảnh sóng âm thanh cho trạng thái nghe giọng nói
- Hiển thị báo thức tiếp theo trong tiêu đề
- Giao diện trạng thái trống

#### 3. **Màn Hình Nhóm (Nhóm)**
- Danh sách thành viên nhóm với 5 thành viên
- Hiển thị chi tiết thành viên (MSSV, điện thoại, email, lớp)
- Hộp thoại chi tiết thành viên với các hành động liên hệ
- Giao diện dựa trên thẻ với hình đại diện
- Chỉ báo trưởng nhóm

#### 4. **Màn Hình Cá Nhân (Cá nhân)**
- Hồ sơ người dùng với hình đại diện
- Hiển thị thông tin liên hệ
- Nút hành động nhanh (Gọi khẩn cấp, YouTube)
- Thiết kế tiêu đề gradient
- Thẻ thông tin liên hệ

#### 5. **Màn Hình Cài Đặt (Cài đặt)**
- Bật/tắt thông báo
- Bật/tắt chế độ tối
- Bật/tắt bảo mật sinh trắc học
- Lựa chọn ngôn ngữ
- Tùy chọn thay đổi mật khẩu
- Hiển thị phiên bản ứng dụng
- Nút đăng xuất
- Được sắp xếp thành các phần

#### 6. **Điều Hướng**
- Thanh điều hướng dưới cùng với Google Nav Bar
- 5 tab chính với biểu tượng
- Chủ đề Material Design 3
- Lược đồ màu tùy chỉnh (nhấn xanh lam nhẹ)

---

## 🔴 Các Công Việc Còn Lại (Theo Thứ Tự Ưu Tiên)

### Giai Đoạn 1: Chức Năng Cơ Bản (Quan Trọng)

#### 1.1 **Màn Hình Dịch - Hoàn Thành Các TODO**
- [ ] Chức năng sao chép vào bộ nhớ tạm
- [ ] Chuyển đổi văn bản thành giọng nói cho văn bản dịch
- [ ] Hiển thị lịch sử dịch
- [ ] Xử lý tính khả dụng kết nối mạng
- [ ] Cải thiện xử lý lỗi

**Ưu tiên:** CAO
**Thời gian ước tính:** 4-6 giờ
**Phụ thuộc:** gói clipboard, gói text_to_speech

#### 1.2 **Màn Hình Báo Thức - Hoàn Thành Triển Khai**
- [ ] Tích hợp với Android alarm APIs (mã Kotlin gốc)
- [ ] Lưu báo thức vào bộ nhớ liên tục (SharedPreferences/SQLite)
- [ ] Thông báo báo thức khi đến giờ
- [ ] Triển khai chức năng lặp lại (hàng ngày, hàng tuần, v.v.)
- [ ] Thêm lựa chọn âm thanh tùy chỉnh
- [ ] Chức năng báo thức lại

**Ưu tiên:** CAO
**Thời gian ước tính:** 6-8 giờ
**Phụ thuộc:** android_alarm_manager_plus, flutter_local_notifications

#### 1.3 **Màn Hình Nhóm - Hoàn Thành Trò Chuyện/Cuộc Gọi**
- [ ] Triển khai tính năng trò chuyện (MessageScreen)
- [ ] Tích hợp cuộc gọi điện thoại
- [ ] Lịch sử tin nhắn
- [ ] Liên hệ API backend

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 8-12 giờ
**Phụ thuộc:** socket_io, phone_contacts

#### 1.4 **Màn Hình Cá Nhân - Hoàn Thành Hành Động**
- [ ] Triển khai cuộc gọi điện thoại (quy trình hoàn chỉnh)
- [ ] Trình khởi chạy URL YouTube
- [ ] Chức năng chỉnh sửa hồ sơ
- [ ] Tải lên/cập nhật hình ảnh hồ sơ

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 3-5 giờ
**Phụ thuộc:** url_launcher (đã được thêm)

#### 1.5 **Màn Hình Cài Đặt - Hoàn Thành Hành Động**
- [ ] Triển khai chuyển ngôn ngữ (bản địa hóa)
- [ ] Triển khai chuyển đổi chủ đề chế độ tối
- [ ] Kết nối chức năng đăng xuất với hệ thống xác thực
- [ ] Lưu trữ tùy chọn liên tục
- [ ] Quy trình thay đổi mật khẩu

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 6-8 giờ
**Phụ thuộc:** get_storage, flutter_localization

---

### Giai Đoạn 2: Kiến Trúc & Chất Lượng Mã

#### 2.1 **Cải Tiến Cấu Trúc Dự Án**
- [ ] Tạo thư mục utils/ với các hàm trợ giúp
  - `translation_helper.dart`
  - `alarm_helper.dart`
  - `permission_helper.dart`
  - `validation_helper.dart`
  
- [ ] Tạo thư mục widgets/ với các thành phần có thể tái sử dụng
  - `custom_button.dart`
  - `custom_text_field.dart`
  - `loading_dialog.dart`
  - `error_dialog.dart`
  - `info_card.dart`

- [ ] Tạo thư mục models/ cho cấu trúc dữ liệu
  - `user_model.dart`
  - `alarm_model.dart`
  - `translation_model.dart`
  - `group_member_model.dart`

**Ưu tiên:** CAO
**Thời gian ước tính:** 4-6 giờ

#### 2.2 **Quản Lý Trạng Thái**
- [ ] Triển khai Provider hoặc GetX để quản lý trạng thái
- [ ] Tạo các nhà cung cấp cho:
  - AuthProvider
  - AlarmProvider
  - TranslationProvider
  - UserProvider

**Ưu tiên:** CAO
**Thời gian ước tính:** 6-8 giờ
**Phụ thuộc:** provider hoặc get

#### 2.3 **Lưu Trữ Dữ Liệu**
- [ ] Triển khai cơ sở dữ liệu cục bộ (Hive hoặc SQLite)
- [ ] Lưu trữ dữ liệu người dùng
- [ ] Lưu trữ lịch sử báo thức
- [ ] Lưu trữ lịch sử dịch
- [ ] Lưu trữ tùy chọn người dùng

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 5-7 giờ
**Phụ thuộc:** hive hoặc sqflite

---

### Giai Đoạn 3: Tích Hợp Gốc

#### 3.1 **Mã Gốc Android (Kotlin)**
**Tệp:** `android/app/src/main/kotlin/.../MainActivity.kt`

Các công việc:
- [ ] Triển khai phương thức `setAlarm()`
- [ ] Triển khai phương thức `processVoiceAlarmCommand()`
- [ ] Triển khai phương thức `startSpeechRecognition()`
- [ ] Triển khai phương thức `callPhone()`
- [ ] Triển khai phương thức `openYouTube()`
- [ ] Yêu cầu các quyền cần thiết tại thời gian chạy
- [ ] Xử lý các trình nhận phát sóng báo thức

**Ưu tiên:** QUAN TRỌNG
**Thời gian ước tính:** 8-12 giờ
**Quyền cần thiết:**
  - SCHEDULE_EXACT_ALARM
  - SCHEDULE_EXACT_ALARM_PERMISSION (cho API 31+)
  - INTERNET
  - RECORD_AUDIO
  - CAMERA
  - READ_EXTERNAL_STORAGE
  - WRITE_EXTERNAL_STORAGE
  - CALL_PHONE
  - READ_PHONE_STATE

#### 3.2 **Mã Gốc iOS (Swift)**
**Tệp:** `ios/Runner/GeneratedPluginRegistrant.swift`

Các công việc:
- [ ] Triển khai các phương thức iOS tương đương
- [ ] Xử lý quyền iOS
- [ ] Kiểm tra trên mô phỏng iOS/thiết bị

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 6-8 giờ

#### 3.3 **Xử Lý Quyền**
- [ ] Yêu cầu quyền tại thời gian chạy cho camera
- [ ] Yêu cầu quyền tại thời gian chạy cho microphone
- [ ] Yêu cầu quyền tại thời gian chạy cho danh bạ
- [ ] Yêu cầu quyền tại thời gian chạy cho vị trí (nếu cần)
- [ ] Xử lý các trường hợp từ chối quyền

**Ưu tiên:** CAO
**Thời gian ước tính:** 3-4 giờ
**Gói:** permission_handler (đã được thêm)

---

### Giai Đoạn 4: Tích Hợp API & Backend

#### 4.1 **Thiết Lập Backend**
- [ ] Thiết kế các điểm cuối API
  - POST /api/auth/login
  - POST /api/auth/register
  - GET /api/user/profile
  - POST /api/translations/save
  - GET /api/translations/history
  - POST /api/groups/members
  - POST /api/alarms/create
  - GET /api/alarms/list

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 8-10 giờ
**Công nghệ:** Node.js/Express hoặc Firebase

#### 4.2 **Triển Khai Máy Khách API**
- [ ] Tạo trình bao bọc máy khách HTTP
- [ ] Triển khai xử lý lỗi
- [ ] Thêm ghi nhật ký yêu cầu/phản hồi
- [ ] Triển khai logic làm mới mã thông báo
- [ ] Thêm cấu hình URL cơ sở

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 4-6 giờ
**Gói:** http (đã được thêm)

#### 4.3 **Hệ Thống Xác Thực**
- [ ] Màn hình đăng nhập người dùng
- [ ] Màn hình đăng ký người dùng
- [ ] Quản lý mã thông báo JWT
- [ ] Lưu trữ phiên
- [ ] Chức năng đăng xuất

**Ưu tiên:** QUAN TRỌNG
**Thời gian ước tính:** 8-10 giờ

---

### Giai Đoạn 5: Kiểm Thử & Gỡ Lỗi

#### 5.1 **Kiểm Thử Đơn Vị**
- [ ] Kiểm thử các hàm trợ giúp dịch
- [ ] Kiểm thử tính toán thời gian báo thức
- [ ] Kiểm thử logic xác thực
- [ ] Kiểm thử quản lý trạng thái

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 4-6 giờ

#### 5.2 **Kiểm Thử Widget**
- [ ] Kiểm thử giao diện người dùng màn hình dịch
- [ ] Kiểm thử giao diện người dùng màn hình báo thức
- [ ] Kiểm thử đầu vào biểu mẫu
- [ ] Kiểm thử điều hướng

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 5-7 giờ

#### 5.3 **Kiểm Thử Tích Hợp**
- [ ] Kiểm thử các quy trình người dùng đầy đủ
- [ ] Kiểm thử tích hợp API
- [ ] Kiểm thử các kênh phương thức gốc

**Ưu tiên:** THẤP
**Thời gian ước tính:** 6-8 giờ

#### 5.4 **Kiểm Thử Thủ Công**
- [ ] Kiểm thử thiết bị (Android)
- [ ] Kiểm thử thiết bị (iOS)
- [ ] Kiểm thử hiệu suất
- [ ] Kiểm thử khả năng tiếp cận

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 8-10 giờ

---

### Giai Đoạn 6: Cải Tiến Giao Diện/Trải Nghiệm Người Dùng

#### 6.1 **Tinh Chỉnh Thiết Kế**
- [ ] Thêm màn hình khởi động
- [ ] Thêm giới thiệu ứng dụng/hướng dẫn
- [ ] Cải thiện chuyển đổi và hoạt ảnh
- [ ] Thêm trạng thái tải đến tất cả các màn hình
- [ ] Thêm trạng thái trống đến tất cả các màn hình
- [ ] Cải thiện thông báo lỗi

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 6-8 giờ

#### 6.2 **Khả Năng Tiếp Cận**
- [ ] Các nhãn ngữ nghĩa cho widget
- [ ] Tỷ lệ tương phản thích hợp
- [ ] Khả năng tiếp cận kích thước phông chữ
- [ ] Hỗ trợ trình đọc màn hình

**Ưu tiên:** THẤP
**Thời gian ước tính:** 3-4 giờ

---

### Giai Đoạn 7: Bản Địa Hóa (i18n)

#### 7.1 **Hỗ Trợ Đa Ngôn Ngữ**
- [ ] Triển khai intl/flutter_localizations
- [ ] Tạo các tệp dịch (.arb)
  - Tiếng Anh (en)
  - Tiếng Việt (vi)
  - Tiếng Trung (zh)
  - Tiếng Nhật (ja)
  - Tiếng Hàn (ko)
  
- [ ] Cập nhật tất cả các chuỗi giao diện người dùng để sử dụng các chuỗi đã được bản địa hóa

**Ưu tiên:** THẤP
**Thời gian ước tính:** 6-8 giờ
**Gói:** intl, flutter_localizations

---

### Giai Đoạn 8: Triển Khai & Phát Hành

#### 8.1 **Phát Hành Android**
- [ ] Tạo khóa ký
- [ ] Cấu hình build.gradle
- [ ] Xây dựng APK/AAB
- [ ] Kiểm thử bản dựng phát hành
- [ ] Xuất bản lên Google Play Store

**Ưu tiên:** CAO
**Thời gian ước tính:** 4-6 giờ

#### 8.2 **Phát Hành iOS**
- [ ] Cấu hình ký iOS
- [ ] Tạo hồ sơ cung cấp
- [ ] Xây dựng IPA
- [ ] Kiểm thử trên thiết bị vật lý
- [ ] Xuất bản lên App Store

**Ưu tiên:** TRUNG BÌNH
**Thời gian ước tính:** 6-8 giờ

---

## Tóm Tắt Lịch Trình

| Giai Đoạn | Số Công Việc | Giờ Ước Tính | Ưu Tiên |
|-----------|------------|------------|--------|
| Giai Đoạn 1: Tính Năng Cơ Bản | 5 | 27-39 | QUAN TRỌNG |
| Giai Đoạn 2: Kiến Trúc | 3 | 15-21 | CAO |
| Giai Đoạn 3: Tích Hợp Gốc | 3 | 17-24 | QUAN TRỌNG |
| Giai Đoạn 4: API & Backend | 3 | 20-26 | TRUNG BÌNH |
| Giai Đoạn 5: Kiểm Thử | 4 | 23-31 | TRUNG BÌNH |
| Giai Đoạn 6: Giao Diện/Trải Nghiệm | 2 | 9-12 | TRUNG BÌNH |
| Giai Đoạn 7: Bản Địa Hóa | 1 | 6-8 | THẤP |
| Giai Đoạn 8: Triển Khai | 2 | 10-14 | CAO |
| **TỔNG CỘNG** | **23** | **127-175 giờ** | - |

**Thời lượng ước tính:** 4-5 tuần (với 1 lập trình viên) hoặc 2-3 tuần (với 2-3 lập trình viên)

---

## Các Gói Phụ Thuộc Cần Thêm

```yaml
# Quản Lý Trạng Thái
provider: ^6.0.0
getx: ^4.6.0

# Lưu Trữ Cục Bộ
hive: ^2.2.0
hive_flutter: ^1.1.0
sqflite: ^2.0.0

# Bản Địa Hóa
intl: ^0.18.0
flutter_localizations:
  sdk: flutter

# Giao Diện Bổ Sung
lottie: ^2.4.0
shimmer: ^2.0.0

# Tiện Ích
get_storage: ^2.1.0
flutter_local_notifications: ^14.0.0
android_alarm_manager_plus: ^3.1.0

# Kiểm Thử
mocktail: ^0.3.0
```

---

## Chiến Lược Cam Kết Git

1. Cam kết hoàn thành Giai Đoạn-theo-Giai Đoạn
2. Sử dụng cam kết thông thường (feat:, fix:, refactor:, test:)
3. Ví dụ:
   - `feat: hoàn thành các TODO màn hình dịch`
   - `feat: thêm lưu trữ báo thức bằng Hive`
   - `feat: triển khai các kênh phương thức gốc cho Android`
   - `refactor: tổ chức cấu trúc mã với các mô hình và tiện ích`

---

## Ghi Chú Cho Nhóm

1. **Khuyến Nghị Ưu Tiên:** Bắt đầu với Giai Đoạn 1 & 3 (Tính Năng Cơ Bản + Tích Hợp Gốc)
2. **Đường Dẫn Quan Trọng:** Giai Đoạn 1 → Giai Đoạn 2 → Giai Đoạn 3 → Giai Đoạn 4
3. **Công Việc Song Song:** Giai Đoạn 5 (Kiểm Thử) có thể bắt đầu khi Giai Đoạn 1 hoàn thành 50%
4. **Xem Xét Mã:** Tất cả các PR phải bao gồm các bài kiểm thử trước khi hợp nhất
5. **Tài Liệu:** Cập nhật README.md sau khi hoàn thành từng tính năng chính

---

## Tiêu Chí Thành Công

- [ ] Tất cả 5 màn hình hoạt động đầy đủ
- [ ] Tích hợp gốc hoạt động trên Android/iOS
- [ ] Không lỗi quan trọng trong các tính năng cốt lõi
- [ ] Độ bao phủ mã tối thiểu 80% cho các đường dẫn quan trọng
- [ ] Hoạt ảnh mượt mà và chuyển đổi
- [ ] Thời gian khởi động <3 giây
- [ ] Giao diện đáp ứng trên tất cả kích thước thiết bị
- [ ] Xuất bản lên Play Store & App Store

