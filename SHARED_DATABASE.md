# Database chung cho nhiều bài LTWeb

Tên hiển thị server: `ltweb-postgre`. Tên database: `ltweb_postgre`.

| Bài | Bảng | Biến chọn bảng |
| --- | --- | --- |
| Bài 1, email list | public.w1_weblisting | EMAIL_DB_TABLE=w1_weblisting |
| Bài khảo sát | public.w2_survey | DB_TABLE=w2_survey |

Local: 127.0.0.1:55434, user ltweb_app. Mật khẩu riêng trong .runtime/local-env.ps1. File pgadmin-ltweb-postgre.json hỗ trợ đăng ký kết nối pgAdmin mà không chứa mật khẩu.

## Cấu hình Render

Tạo một Render Postgres, tên ltweb-postgre, database ltweb_postgre. Các web cần ở cùng region với database. Không xóa database cũ trước khi đã backup, restore và kiểm tra đầy đủ trên database mới.

Bài 1 (phải triển khai mã đã bổ sung EMAIL_DB_TABLE):

| Biến | Giá trị |
| --- | --- |
| EMAIL_DB_URL | jdbc:postgresql://INTERNAL_HOST:5432/ltweb_postgre?sslmode=require |
| EMAIL_DB_USER | Username database mới |
| EMAIL_DB_PASSWORD | Password database mới |
| EMAIL_DB_TABLE | w1_weblisting |

Web khảo sát:

| Biến | Giá trị |
| --- | --- |
| DB_HOST | INTERNAL_HOST |
| DB_PORT | 5432 |
| DB_NAME | ltweb_postgre |
| DB_USER | Username database mới |
| DB_PASSWORD | Password database mới |
| DB_SSLMODE | require |
| DB_TABLE | w2_survey |

Bài 1 không tự tạo bảng. Bản backup database chung cần được restore trước khi dùng web bài 1. Web khảo sát tự tạo bảng khảo sát nếu chưa có; không tự sao chép dữ liệu nguồn. Xem DATABASE.md về backup/restore.

Tên bảng được kiểm tra trước khi dùng trong SQL, chỉ gồm chữ thường/số/gạch dưới, tối đa 40 ký tự. Giá trị dữ liệu vẫn truyền bằng PreparedStatement. Đổi tên bảng trong Environment chỉ có tác dụng khi triển khai mã mới có hỗ trợ biến đó.

File render.yaml chỉ tạo database chung và web khảo sát; không tự tạo/triển khai thêm web bài 1. Nếu đã có web/database trên Render, cấu hình thủ công để tránh tạo trùng. Gói database miễn phí Render vẫn có thời hạn theo dịch vụ.

## Kết quả local

- Nguồn bài 1: local `weblisting.public.email_subscribers` trên 127.0.0.1:5432, không phải bản Render.
- Đích: `ltweb_postgre.public.w1_weblisting` trên 127.0.0.1:55434, giữ nguyên 1 dòng nguồn và ID.
- `w2_survey` giữ toàn bộ dữ liệu khảo sát, hiện có 21 dòng kiểm thử.
- Đối chiếu hash các dòng sao chép: khớp; cả hai web ghi đúng bảng, không ghi chéo.
- Web local bài 1: http://localhost:8086/w1weblisting/ .
- Web local khảo sát: http://localhost:8086/ch04survey/ .
- SQL cấu trúc cả hai bảng: `database/ltweb_postgre-schema.sql`.
- Backup cả cấu trúc và dữ liệu: `.runtime/ltweb_postgre-local.dump` (đã restore thử thành công vào database riêng; database thử đã được dọn).
- Không xóa/sửa database nguồn, không push GitHub hoặc thao tác trên Render.

Chạy lại kiểm tra hai web: load `.runtime/local-env.ps1`, rồi `python tests/shared_database_test.py`. Bài kiểm tra tạo email UUID riêng và chỉ xóa các dòng thử đó khi xong.
