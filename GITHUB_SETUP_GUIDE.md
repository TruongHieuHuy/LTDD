# 🚀 HƯỚNG DẪN PUSH CODE LÊN GITHUB

## ✅ ĐÃ HOÀN THÀNH

### Frontend (Flutter - TruongHieuHuy)
- ✅ Git đã được khởi tạo
- ✅ Đã commit tất cả code (79 files, 24,242 dòng mới)
- ✅ Đã tạo nhánh `dev` từ `main`
- ✅ Đã push nhánh `dev` lên GitHub
- ✅ Repository: `https://github.com/TruongHieuHuy/LTDD`

### Backend (Node.js)
- ✅ Git đã được khởi tạo
- ✅ Đã commit tất cả code (18 files, 3,976 dòng)
- ✅ Đã đổi nhánh `master` → `main`
- ⏳ CHƯA push lên GitHub (cần tạo repository trước)

---

## 🎯 BƯỚC TIẾP THEO - PUSH BACKEND

### Bước 1: Tạo Repository trên GitHub

1. Truy cập: https://github.com/new
2. Điền thông tin:
   - **Repository name:** `GameMobileBackend` (hoặc tên khác)
   - **Description:** Backend API cho Game Mobile App
   - **Visibility:** Private (khuyến nghị) hoặc Public
   - **⚠️ KHÔNG** tick "Initialize with README" (đã có rồi)
3. Click **Create repository**

### Bước 2: Push Code lên GitHub

Sau khi tạo repository xong, chạy các lệnh sau trong PowerShell:

```powershell
# Di chuyển vào thư mục Backend
cd d:\AndroidStudioProjects\Backend

# Thêm remote repository (thay YOUR_USERNAME bằng username GitHub của bạn)
git remote add origin https://github.com/YOUR_USERNAME/GameMobileBackend.git

# Push code lên nhánh main
git push -u origin main
```

**Ví dụ cụ thể:**
```powershell
# Nếu username GitHub là "TruongHieuHuy"
git remote add origin https://github.com/TruongHieuHuy/GameMobileBackend.git
git push -u origin main
```

### Bước 3: Xác nhận

Truy cập repository trên GitHub và kiểm tra:
- ✅ Có 18 files
- ✅ Có folder `src/`, `prisma/`
- ✅ Có file `README.md`, `package.json`

---

## 📊 TÓM TẮT CẤU TRÚC GIT

### Frontend Repository
```
Repository: https://github.com/TruongHieuHuy/LTDD
├── Branch: main (production)
└── Branch: dev (development) ← ĐANG DÙNG
    └── Commit latest: "feat: complete posts system..."
```

### Backend Repository (SAU KHI PUSH)
```
Repository: https://github.com/YOUR_USERNAME/GameMobileBackend
└── Branch: main (production)
    └── Commit latest: "feat: complete backend API..."
```

---

## 🔄 WORKFLOW PHÁT TRIỂN

### Khi code feature mới (Frontend)

```bash
# 1. Đảm bảo đang ở nhánh dev
cd d:\AndroidStudioProjects\TruongHieuHuy
git checkout dev

# 2. Pull code mới nhất (nếu làm việc nhóm)
git pull origin dev

# 3. Code feature...

# 4. Commit changes
git add .
git commit -m "feat: mô tả ngắn gọn feature"

# 5. Push lên GitHub
git push origin dev

# 6. Khi feature ổn định, merge vào main
git checkout main
git merge dev
git push origin main
```

### Khi code feature mới (Backend)

```bash
# 1. Code trong nhánh main (hoặc tạo nhánh feature)
cd d:\AndroidStudioProjects\Backend

# 2. Commit changes
git add .
git commit -m "feat: mô tả feature"

# 3. Push lên GitHub
git push origin main
```

---

## 👥 PHÂN CÔNG CHO TEAM

### Cách team member clone project

**Frontend (Flutter):**
```bash
# Clone repository
git clone https://github.com/TruongHieuHuy/LTDD.git
cd LTDD

# Checkout nhánh dev
git checkout dev

# Install dependencies
flutter pub get

# Chạy app
flutter run
```

**Backend (Node.js):**
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/GameMobileBackend.git
cd GameMobileBackend

# Install dependencies
npm install

# Setup database (PostgreSQL cần chạy sẵn)
npx prisma migrate dev

# Start server
npm run dev
```

### Cách team member push code

```bash
# 1. Pull code mới nhất trước
git pull origin dev  # (hoặc main cho backend)

# 2. Code changes...

# 3. Add và commit
git add .
git commit -m "feat: mô tả thay đổi"

# 4. Push lên GitHub
git push origin dev  # (hoặc main cho backend)
```

---

## 🛡️ BẢO MẬT

### ⚠️ QUAN TRỌNG - File KHÔNG được push lên GitHub:

**Frontend:**
- ✅ Đã ignore: `build/`, `.dart_tool/`, `*.env`
- ⚠️ Không commit API keys trong code
- ⚠️ Google API Key nên dùng biến môi trường

**Backend:**
- ✅ Đã ignore: `.env`, `node_modules/`
- ⚠️ KHÔNG BAO GIỜ push file `.env`
- ⚠️ JWT_SECRET phải khác nhau cho dev và production

### Kiểm tra trước khi push:

```bash
# Xem file sẽ được commit
git status

# Xem nội dung thay đổi
git diff

# Hủy add file nhạy cảm (nếu vô tình add)
git reset HEAD .env
```

---

## 📝 COMMIT MESSAGE CONVENTION

### Format:
```
<type>: <mô tả ngắn gọn>

[body - tùy chọn]
```

### Types:
- `feat:` - Thêm tính năng mới
- `fix:` - Sửa bug
- `refactor:` - Cải thiện code (không thay đổi tính năng)
- `docs:` - Cập nhật tài liệu
- `style:` - Format code, thêm dấu `;`, etc
- `test:` - Thêm/sửa tests
- `chore:` - Công việc linh tinh (update dependencies, etc)

### Ví dụ:
```bash
git commit -m "feat: add real-time messaging with Socket.io"
git commit -m "fix: resolve duplicate message issue in chat"
git commit -m "docs: update API documentation for posts endpoints"
git commit -m "refactor: optimize database queries in posts service"
```

---

## 🆘 TROUBLESHOOTING

### Lỗi: "fatal: remote origin already exists"
```bash
git remote remove origin
git remote add origin <URL-mới>
```

### Lỗi: "Updates were rejected"
```bash
# Pull trước khi push
git pull origin dev --rebase
git push origin dev
```

### Lỗi: "Permission denied (publickey)"
```bash
# Sử dụng HTTPS thay vì SSH
git remote set-url origin https://github.com/USERNAME/REPO.git
```

### Muốn xóa commit cuối (chưa push)
```bash
git reset --soft HEAD~1
```

### Muốn xóa tất cả changes chưa commit
```bash
git reset --hard HEAD
```

---

## ✅ CHECKLIST HOÀN TẤT

Frontend:
- [x] Git initialized
- [x] Code committed
- [x] Branch `dev` created
- [x] Pushed to GitHub
- [x] Project documentation created

Backend:
- [x] Git initialized  
- [x] Code committed
- [x] Branch renamed to `main`
- [ ] Repository created on GitHub
- [ ] Pushed to GitHub

Documentation:
- [x] PROJECT_STATUS.md created
- [x] GITHUB_SETUP_GUIDE.md created
- [x] Team workflow documented

---

**🎉 HOÀN THÀNH SETUP! Giờ có thể phân công công việc cho team!**

**📌 Các file quan trọng cần đọc:**
1. `PROJECT_STATUS.md` - Tổng quan dự án và phân công task
2. `README.md` - Hướng dẫn chạy project (Frontend & Backend)
3. `GITHUB_SETUP_GUIDE.md` - Hướng dẫn Git workflow (file này)
