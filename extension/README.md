# FAP Auto Attendance Assistant - Chrome Extension

Extension hỗ trợ giảng viên Đại học FPT tự động tích điểm danh trên hệ thống FAP (`fap.fpt.edu.vn`).

## Các tính năng chính:
1. **Đồng bộ trực tiếp**: Lấy danh sách điểm danh từ Google Sheets DB hoặc từ ứng dụng Flutter Desktop.
2. **Tự động tích điểm danh (Auto-Fill Attendance)**:
   - Tự động nhận diện MSSV trên trang điểm danh FAP.
   - Tích radio `Present` (P) cho sinh viên đã quét mã QR OTP 10s thành công.
   - Tích radio `Absent` (A) cho sinh viên vắng mặt.
   - Đánh dấu màu xanh/đỏ trực quan trên từng dòng sinh viên.
3. **1-Click Lưu điểm danh**: Hỗ trợ lưu kết quả lên FAP chỉ với 1 click.

## Hướng dẫn cài đặt vào Chrome / Edge:
1. Mở trình duyệt Chrome hoặc Edge, truy cập đường dẫn: `chrome://extensions/`
2. Bật chế độ **Developer mode (Chế độ dành cho nhà phát triển)** ở góc trên bên phải.
3. Nhấn vào nút **Load unpacked (Tải tiện ích đã giải nén)**.
4. Chọn thư mục: `C:\Users\minhn\.gemini\antigravity\scratch\fap_attendance_app\extension`
5. Truy cập `https://fap.fpt.edu.vn/` vào trang điểm danh, widget tự động hiển thị ở góc dưới bên phải màn hình!
