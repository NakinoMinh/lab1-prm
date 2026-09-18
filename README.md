# Lab 1: FAP Smart Attendance Desktop Application & Chrome Extension
> **Dự án Lab 1 - Mobile & Desktop Development (PRM/PRN) - Đại học FPT**  
> Ứng dụng Desktop hỗ trợ giảng viên FPT điểm danh sinh viên thông minh qua **Mã QR động & OTP 10 giây**, kết nối **Google Sheets Database**, thời khóa biểu **FAP Weekly Timetable**, và tiện ích **Chrome Extension tự động tích điểm danh trên FAP**.

---

## 🌟 Tính Năng Nổi Bật

### 1. 📅 Thời Khóa Biểu Tuần Chuẩn FAP (FAP Timetable Grid)
- **Giao diện Material 3 hiện đại**: Thiết kế desktop-first, tuân thủ nguyên tắc [Material 3 Color System](https://m3.material.io/styles/color/system/how-the-system-works) với các vai trò màu `surfaceContainer`, `surfaceContainerLow`, v.v.
- Bảng lịch dạy 7 ngày (Thứ 2 - CN) x 6 Ca học (Slot 1 - Slot 6) với giờ học chuẩn FAP (7:00-9:15, 9:30-11:45,...).
- Thẻ môn học trực quan, phân màu sắc hài hòa theo mã môn (`PRN232`, `PRM393`, `SWP391`, `EXE201`, `MLN111`, `ITE302c`).
- Chuyển tuần (`Trước / Sau / Tuần hiện tại`).

### 2. 📌 Chi Tiết Ca Dạy (Activity Detail Modal)
- Xem thông tin ca dạy chi tiết: Môn học, Nhóm SV/Lớp, Phòng học (NVH 602...), Giảng viên, Buổi học, Link Google Meet.
- **1-Click bắt đầu điểm danh**: Tự động chuyển thẳng sang màn hình tạo mã QR & OTP 10s của lớp đó.

### 3. ➕ Tạo Lớp / Ca Dạy Mới (Bắt buộc Import Học Viên)
- Giảng viên tự tạo ca dạy mới: Nhập mã môn, tên môn, mã lớp, slot, thứ, phòng học, giảng viên, học online.
- **2 Phương thức nạp học viên**:
  - 📁 **File Excel (.xlsx) / CSV**: Đọc trực tiếp danh sách sinh viên gồm RollNo, FullName, Email.
  - ☁️ **Google Sheets DB**: Dán link Google Sheets hoặc Web App URL để tải trực tiếp danh sách lớp từ Cloud.
  - *Bắt buộc phải nạp danh sách học viên trước khi lưu lớp.*

### 4. 📱 Mã QR & OTP Động Reset Mỗi 10 Giây (Dynamic TOTP)
- Thuật toán TOTP sinh mã 6 số tự động thay đổi mỗi 10 giây kèm vòng tròn đếm ngược thời gian trực quan.
- Mã QR kích thước lớn thân thiện với máy chiếu lớp học, chống chụp ảnh điểm danh hộ từ xa.

### 5. 🎓 Trang Sinh Viên Quét Mã QR & Thẻ Điểm Danh Điện Tử
- Sinh viên quét QR code trên máy chiếu hoặc truy cập đường link check-in.
- Tự động nhận diện lớp học và trích xuất mã OTP 10 giây từ mã QR.
- Sinh viên đăng nhập bằng Email FPT (ví dụ: `minhnbse182173@fpt.edu.vn`) và bấm xác nhận.
- Xuất **Thẻ Điểm Danh Điện Tử Hợp Lệ (Digital Attendance Pass)** có mã hash chống gian lận SHA-256 và thời gian ghi nhận chi tiết.
- Cập nhật tức thời trạng thái **CÓ MẶT (PRESENT)** trên màn hình giảng viên.

### 6. 🧩 Chrome Extension Tự Động Tích Điểm Danh Trên FAP
- Tiện ích mở rộng nằm tại thư mục `extension/` (Manifest V3).
- Nhúng widget nổi trực tiếp vào website `fap.fpt.edu.vn`.
- Tự động đọc danh sách sinh viên đã điểm danh thành công từ ứng dụng/Google Sheets.
- **Tự động tick radio `Present` (P)** cho sinh viên có mặt và **`Absent` (A)** cho sinh viên vắng mặt trên bảng điểm danh của FAP.
- Nút 1-Click lưu điểm danh lên hệ thống FAP.

### 7. ☁️ Kết Nối Google Sheets DB (Google Apps Script API)
- Hoạt động mượt mà ở cả 2 chế độ:
  - **Local Mode (Chế độ nội bộ)**: Chạy độc lập, lưu trữ tức thời trong bộ nhớ.
  - **Google Sheets Cloud Mode**: Tích hợp Google Apps Script REST API endpoint (`doGet`/`doPost`), tự động đồng bộ 2 chiều.
- Cung cấp sẵn mã nguồn Google Apps Script trong app để copy-paste vào Sheets.

### 8. 📊 Quản Lý & Xuất Báo Cáo FAP
- Tìm kiếm MSSV, Họ tên, Email; lọc theo trạng thái (Có mặt, Trễ, Vắng).
- Giảng viên có thể ghi đè thủ công trạng thái sinh viên.
- Xuất file `.csv` chuẩn định dạng để tải lên hệ thống FAP.

---

## 🛠️ Cài Đặt & Chạy Ứng Dụng

### Yêu cầu môi trường:
- Flutter SDK (>= 3.13.0)
- Python 3.x (để chạy local server cho desktop web app & API extension)
- Trình duyệt Google Chrome / Edge

### 1. Khởi chạy ứng dụng Desktop Web:
```bash
# 1. Cài đặt dependencies
flutter pub get

# 2. Chạy server web ứng dụng
python serve_app.py
```
Truy cập ứng dụng tại: 👉 **[http://localhost:8080/](http://localhost:8080/)**

### 2. Cài đặt Chrome Extension vào trình duyệt:
1. Mở Chrome / Edge, truy cập: `chrome://extensions/`
2. Bật công tắc **Developer mode** (Chế độ cho nhà phát triển) ở góc trên bên phải.
3. Bấm **Load unpacked** (Tải tiện ích đã giải nén).
4. Chọn thư mục `extension/` trong dự án.
5. Truy cập `https://fap.fpt.edu.vn/` vào trang điểm danh, widget tự động kích hoạt!

---

## 📂 Cấu Trúc Thư Mục

```
fap_attendance_app/
├── lib/
│   ├── dialogs/
│   │   ├── activity_detail_dialog.dart  # Dialog chi tiết ca dạy chuẩn FAP
│   │   └── add_class_dialog.dart        # Dialog tạo lớp mới (Import Excel/Google Sheets)
│   ├── models/
│   │   ├── attendance_session.dart      # Model phiên điểm danh
│   │   ├── fap_class_slot.dart          # Model ca dạy & thời khóa biểu FAP
│   │   └── student.dart                 # Model sinh viên & trạng thái điểm danh
│   ├── providers/
│   │   └── attendance_provider.dart     # Quản lý state tập trung (ChangeNotifier)
│   ├── screens/
│   │   ├── extension_guide_screen.dart   # Hướng dẫn & kiểm thử Chrome Extension
│   │   ├── fap_timetable_screen.dart    # Thời khóa biểu tuần M3
│   │   ├── student_qr_checkin_screen.dart # Trang SV quét QR & Thẻ điện tử
│   │   └── teacher_dashboard_screen.dart # Giao diện Desktop Giảng viên
│   ├── services/
│   │   ├── google_sheets_service.dart   # Kết nối Google Sheets & Apps Script
│   │   └── otp_service.dart             # Thuật toán TOTP xoay mã OTP 10s
│   └── widgets/
│       ├── qr_generator_widget.dart     # Widget mã QR & đồng hồ đếm ngược 10s
│       ├── roster_table_widget.dart     # Bảng danh sách sinh viên & tìm kiếm
│       └── sheets_config_widget.dart    # Cấu hình Google Sheets DB
├── extension/                           # Mã nguồn Chrome Extension cho FAP
│   ├── manifest.json
│   ├── content.js
│   ├── content.css
│   ├── popup.html
│   └── popup.js
├── serve_app.py                         # Server Python kèm API CORS cho Extension
└── pubspec.yaml
```

---
*Dự án thực hiện cho môn Lab 1 (Desktop Application / PRM / PRN) - Đại học FPT.*
