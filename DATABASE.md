# Database khảo sát PostgreSQL

Database `ltweb_postgre` có bảng `public.w2_survey`. Mỗi dòng là một lần gửi đầy đủ. Email không UNIQUE vì một người được gửi nhiều lần; dữ liệu cũ không bị ghi đè.

| Cột | Kiểu | Ý nghĩa |
| --- | --- | --- |
| id | BIGINT identity, primary key | Mã tự tăng |
| first_name | VARCHAR(100), NOT NULL | Tên |
| last_name | VARCHAR(100), NOT NULL | Họ |
| email | VARCHAR(254), NOT NULL | Email |
| date_of_birth | DATE, NOT NULL | Ngày sinh |
| heard_from | VARCHAR(30), NOT NULL | Nguồn giới thiệu |
| wants_updates | BOOLEAN, NOT NULL | Checkbox nhận thông báo |
| email_announcements | BOOLEAN, NOT NULL | Checkbox nhận email |
| contact_via | VARCHAR(30), NOT NULL | Cách liên hệ |
| submitted_at | TIMESTAMPTZ, NOT NULL | Thời gian gửi tự tạo |

CHECK chặn tên trống, email sai dạng cơ bản, ngày sinh tương lai và lựa chọn ngoài form. Index email hỗ trợ tìm lại. Hai checkbox độc lập. Khoảng trống trong ID sau lỗi/chèn thử là bình thường.

SQL: `src/main/resources/db/schema.sql`. Servlet tự chạy khi khởi tạo, dùng IF NOT EXISTS, không xóa dữ liệu. Đây là schema khởi tạo; thay đổi cấu trúc bảng sau này cần migration riêng.

## Luồng ghi

HTML POST → EmailListServlet → UserDB.insert(User, Survey) → PostgreSQL → thanks.jsp.

UserDB giữ tên repo mẫu nhưng đã dùng JDBC thật. PreparedStatement truyền giá trị bằng tham số. Một INSERT lưu cả tám trường theo autocommit. Chỉ hiện cảm ơn sau khi ghi thành công; lỗi ghi/kết nối trả HTTP 503. Không có trang công khai xem danh sách người điền. Mỗi POST thành công là một dòng; refresh POST có thể gửi lại.

## Local đã tạo trên máy này

- PostgreSQL 17.11, host `127.0.0.1`, port **55434**.
- Database `ltweb_postgre`, role ứng dụng `ltweb_app` không có quyền superuser.
- Cụm riêng tại `../.reference/survey-postgres/data`; không thay đổi database trong Windows service đang có.
- Mật khẩu ngẫu nhiên nằm ở `.runtime/local-env.ps1`, loại khỏi Git, Docker và ZIP. Không chia sẻ file này.

Trong pgAdmin: đăng ký server với thông tin trên, lấy DB_PASSWORD trong file local. Query Tool:

```sql
SET TIME ZONE 'Asia/Ho_Chi_Minh';
SELECT id, first_name, last_name, email, date_of_birth,
       heard_from, wants_updates, email_announcements,
       contact_via, submitted_at
FROM w2_survey
ORDER BY id DESC;
```

Hoặc PowerShell trong thư mục ch04-survey:

```powershell
. ./.runtime/local-env.ps1
$env:PGPASSWORD = $env:DB_PASSWORD
& 'C:/Program Files/PostgreSQL/17/bin/psql.exe' -h 127.0.0.1 -p 55434 -U ltweb_app -d ltweb_postgre
```

Trong psql: `\dt` xem bảng, `\d w2_survey` xem cấu trúc, `\q` thoát.

Cụm riêng không tự khởi động sau khi reboot. Khởi động từ thư mục dự án:

```powershell
& 'C:/Program Files/PostgreSQL/17/bin/pg_ctl.exe' -D ../.reference/survey-postgres/data -l ../.reference/survey-postgres/server.log -o '-h 127.0.0.1 -p 55434' -w start
```

Dừng đúng cụm riêng:

```powershell
& 'C:/Program Files/PostgreSQL/17/bin/pg_ctl.exe' -D ../.reference/survey-postgres/data -m fast -w stop
```

## Sang máy khác

Cài PostgreSQL, dùng tài khoản quản trị tạo role/database với mật khẩu riêng:

```sql
CREATE ROLE ltweb_app LOGIN PASSWORD 'THAY_BANG_MAT_KHAU_RIENG';
CREATE DATABASE ltweb_postgre OWNER ltweb_app ENCODING 'UTF8';
```

Đặt DB_* theo .env.example trước khi chạy Tomcat. Java/Tomcat không tự đọc .env; start-local.ps1 đọc .runtime/local-env.ps1 nếu có.

## Backup/chuyển dữ liệu

Schema tự tạo trên Render, nhưng dữ liệu local không tự chuyển. Nên bắt đầu với database Render trống, gửi khảo sát thử mới. Không upload thư mục data hay mật khẩu lên GitHub.

Backup dữ liệu kiểm thử local: `.runtime/ltweb_postgre-local.dump`, không chứa mật khẩu, không đưa lên GitHub. Tạo bản mới sau khi load local-env.ps1 và đặt PGPASSWORD:

```powershell
& 'C:/Program Files/PostgreSQL/17/bin/pg_dump.exe' -h 127.0.0.1 -p 55434 -U ltweb_app -d ltweb_postgre --format=custom --no-owner --no-privileges --file=.runtime/ltweb_postgre-local.dump
```

Khôi phục bằng pg_restore vào database mới, trống, PostgreSQL 17 trở lên. Nếu web đã tạo bảng và bảng còn trống, dùng --data-only. Không dùng --clean trên database đang có dữ liệu cần giữ.

Từ local đến Render: đặt PGHOST bằng External Hostname, PGPORT, PGUSER, PGDATABASE, PGPASSWORD theo database đích; PGSSLMODE=require. Cho phép IP máy bạn trong External Access trước khi kết nối. Blueprint mặc định ipAllowList: [] chỉ cho nội bộ; đóng lại truy cập ngoài khi xong.

```powershell
$env:PGSSLMODE = 'require'
& 'C:/Program Files/PostgreSQL/17/bin/pg_restore.exe' --no-owner --no-privileges --exit-on-error --data-only .runtime/ltweb_postgre-local.dump
```

## Database chung nhiều bài

Tên hiển thị server/instance có thể đặt `ltweb-postgre`; tên database dùng `ltweb_postgre` để thuận tiện cho SQL. Bài 1 dùng `w1_weblisting`; bài khảo sát dùng `w2_survey`. Cùng host/port/database, mỗi web chọn bảng riêng bằng biến môi trường. Tên bảng chỉ chấp nhận chữ thường, số, dấu gạch dưới, tối đa 40 ký tự; không cho nhập câu SQL.

Web khảo sát: `DB_NAME=ltweb_postgre`, `DB_TABLE=w2_survey`. Bài 1 đã sửa mã local tại `C:/Users/Ngoc Nhat/IdeaProjects/weblisting` để đọc `EMAIL_DB_TABLE=w1_weblisting`; các biến kết nối vẫn là EMAIL_DB_URL, EMAIL_DB_USER, EMAIL_DB_PASSWORD. Cần triển khai lại mã đã sửa thì biến tên bảng mới có tác dụng.

File `pgadmin-ltweb-postgre.json` có thể import bằng Tools → Import/Export Servers trong pgAdmin. File không chứa mật khẩu; lấy mật khẩu local từ .runtime/local-env.ps1 sau khi chuyển cấu hình sang database chung.

Giữ database Render cũ tới khi đã sao chép đủ và xác minh dữ liệu trên Render mới. Bản đăng ký render-weblisting trong pgAdmin là kết nối đến Render, không phải bản database local.

## Trạng thái sao chép hiện tại

Đã tạo ltweb_postgre và sao chép survey_responses thành w2_survey, kiểm tra khớp đầy đủ dữ liệu và ID của 11 dòng nguồn. Web local đang ghi vào database chung với DB_TABLE=w2_survey. Đã sao chép email_subscribers từ database local weblisting (127.0.0.1:5432) thành w1_weblisting, giữ nguyên 1 dòng dữ liệu/ID và cấu trúc. Đã đối chiếu hash dữ liệu, thử cả hai website và khôi phục backup của cả hai bảng thành công. Hiện w2_survey có 21 dòng kiểm thử. Các dòng thử riêng cho kiểm tra ghi chéo đã được dọn. Không kết nối hoặc thay đổi Render trong bước sao chép này; database nguồn local cũng giữ nguyên.
