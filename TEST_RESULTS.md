# Kết quả kiểm tra local — 10/11/2026

Môi trường: PostgreSQL 17.11 (cụm riêng, 127.0.0.1:55434), Tomcat 9.0.123, JDK 25 (biên dịch release 21), PostgreSQL JDBC 42.7.14. Chưa chạy Docker image hoặc triển khai Render.

| Kiểm tra đã thực hiện | Kết quả |
| --- | --- |
| Maven package, JDBC nằm trong WAR | PASS |
| Form, bắt buộc nhập, Submit, JSP, Return | PASS |
| Date picker và màn hình nhỏ không tràn ngang | PASS |
| Truy vấn trực tiếp đủ 8 trường dữ liệu + id/thời gian gửi | PASS |
| Tên tiếng Việt, dấu nháy đơn và nội dung HTML | Lưu nguyên trong DB, escape khi hiển thị JSP |
| Checkbox bật/tắt độc lập, cách liên hệ | PASS |
| Cùng email gửi nhiều lần, 4 yêu cầu gửi đồng thời | Mỗi lần thành công một dòng riêng |
| Email/ngày sinh/lựa chọn không hợp lệ | Bị từ chối, không ghi thêm dòng |
| Tắt PostgreSQL khi web đang chạy | Submit và /health trả 503, không hiện cảm ơn |
| Khởi động lại PostgreSQL | Dòng kiểm thử id=4 còn nguyên |
| Khởi động lại Tomcat, chạy lại schema IF NOT EXISTS | Dòng kiểm thử id=4 còn nguyên |
| Backup pg_dump rồi restore vào database trống riêng | Khôi phục đủ 11 dòng; đã xóa database kiểm tra riêng |

Dữ liệu kiểm thử hiện có 11 dòng, email mẫu example.com. Không có dữ liệu người dùng thật. Backup ở .runtime/survey_bt04-local.dump, cấu hình mật khẩu ở .runtime/local-env.ps1; cả hai không nằm trong Git hoặc ZIP mã nguồn.

Để tự chạy lại: xem README.md và tests/database_test.py. Database test tạo thêm dữ liệu thử mỗi lần chạy. Health local: http://localhost:8086/ch04survey/health .

## Chuyển database chung ltweb_postgre

Đã kiểm tra hash toàn bộ dữ liệu/ID của 11 dòng survey nguồn với bản sao w2_survey: khớp. Smoke test và database test tiếp tục PASS trên ltweb_postgre, DB_TABLE=w2_survey. Hai dự án Java đều build PASS sau khi thêm biến tên bảng. Đã sao chép từ local weblisting sang w1_weblisting: 1 dòng, hash toàn bộ giá trị/ID khớp. shared_database_test.py PASS cho cả hai web; các dòng thử riêng đã dọn. Backup database chung restore PASS: w1 có 1 dòng, w2 có 21 dòng. Nguồn local giữ nguyên; Render không thay đổi.
