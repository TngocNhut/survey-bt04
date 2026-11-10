# Chapter 04 — Survey với PostgreSQL

HTML5/CSS3, Java Servlet, JavaBean, JSP, Maven WAR và Tomcat 9 theo cấu trúc bài mẫu. Giữ màu teal/đen/nền trắng và ô ngày sinh có lịch. Mỗi Submit hợp lệ lưu đủ thông tin và câu trả lời vào PostgreSQL, không còn danh sách RAM.

## File chính

| File | Nội dung |
| --- | --- |
| src/main/webapp/index.html | Form POST, date, radio, checkbox, select |
| src/main/webapp/styles/main.css | CSS ngoài theo mẫu |
| src/main/java/murach/email/EmailListServlet.java | Kiểm tra, gọi lớp dữ liệu, forward JSP |
| src/main/java/murach/data/UserDB.java | JDBC PreparedStatement lưu User và Survey |
| src/main/resources/db/schema.sql | SQL khởi tạo bảng |
| src/main/webapp/thanks.jsp | Hiển thị kết quả qua JSTL |
| DATABASE.md | Thiết kế, xem dữ liệu, local, backup/restore |
| SOURCES.md | Đối chiếu slide và GitHub |
| .env.example | Tên biến môi trường, không có mật khẩu thật |
| render.yaml | Blueprint Postgres + Web Service |

## Chạy local trên máy đang làm bài

Database riêng: 127.0.0.1, port 55434, database ltweb_postgre. Xem DATABASE.md để khởi động lại database sau reboot hoặc xem dữ liệu bằng pgAdmin.

PowerShell trong thư mục ch04-survey:

```powershell
./scripts/start-local.ps1
```

Script đọc .runtime/local-env.ps1, build WAR và chạy Tomcat của bài. Nếu port 8086 đang chạy, dùng luôn bản đó hoặc dừng đúng Tomcat trước; script không tự dừng ứng dụng đang chạy.

Mở http://localhost:8086/ch04survey/ . Health check: http://localhost:8086/ch04survey/health trả 200 và OK khi database hoạt động.

Cần JDK 21 trở lên, Maven 3.9 và Tomcat 9 vì mã dùng javax.servlet. Có thể truyền -TomcatHome đến thư mục Tomcat của bạn; URL/cổng phụ thuộc server.xml. Không mở file:// để thử Submit. Máy khác: tạo database theo DATABASE.md và đặt DB_* trước khi khởi động Tomcat. Có thể build bằng mvn clean package, copy target/ch04survey.war vào webapps.

## Kiểm tra

```powershell
. ./.runtime/local-env.ps1
python tests/smoke_test.py http://localhost:8086/ch04survey/
python tests/database_test.py http://localhost:8086/ch04survey/
```

Smoke test kiểm tra form/JSP, tiếng Việt, escape HTML, Return, dữ liệu sai. Database test truy vấn PostgreSQL thật, kiểm tra từng cột, checkbox, cùng email gửi nhiều lần và ghi đồng thời. Dữ liệu thử có email db-test-...@example.com.

Sau khi restart web hoặc database:

```powershell
python tests/database_test.py http://localhost:8086/ch04survey/ --verify-persistence
```

Khi cố ý tắt database local:

```powershell
python tests/database_test.py http://localhost:8086/ch04survey/ --expect-unavailable
```

Database test cần psql và DB_*; chỉ chạy trên môi trường thử nghiệm vì tạo dòng dữ liệu thật.

## Render — nhập thủ công

Bản này cần một Render Postgres và một Web Service. Đưa mã mới lên GitHub trước khi deploy. Không push .runtime, .env, target hoặc backup. Không dùng Static Site cho Servlet/JSP.

### 1. Tạo PostgreSQL

New → Postgres. Name ví dụ ltweb-postgre, Database ltweb_postgre, User ltweb_app. Chọn cùng Region với web, ví dụ Singapore, và gói phù hợp. Free (nếu có) hết hạn sau 30 ngày; muốn giữ lâu hơn cần gói phù hợp và backup.

Chờ Available; lấy Internal Hostname, Port, Database, Username, Password trong thông tin kết nối.

Tài liệu: https://render.com/docs/postgresql-creating-connecting và https://render.com/docs/free .

### 2. Tạo hoặc cập nhật web

New → Web Service → repo TngocNhut/survey-bt04, hoặc cập nhật Environment của web đã có.

| Mục | Giá trị |
| --- | --- |
| Branch | main |
| Language / Runtime | Docker |
| Root Directory | Trống nếu Dockerfile/pom.xml/src ở gốc repo |
| Dockerfile Path | ./Dockerfile |
| Docker Build Context | . |
| Docker Command | Trống |
| Region | Cùng vùng với database |
| Health Check Path | /health |

Trong Environment:

| Biến | Giá trị |
| --- | --- |
| DB_HOST | Internal Hostname, không có https:// hay jdbc: |
| DB_PORT | 5432 hoặc port Render cấp |
| DB_NAME | Database Render cấp |
| DB_USER | Username Render cấp |
| DB_PASSWORD | Mật khẩu Render cấp, lưu như secret |
| DB_SSLMODE | require |
| DB_TABLE | w2_survey |

Không dán nguyên URL postgres://... vào DB_HOST. Không cần đặt PORT; Dockerfile đọc PORT Render cấp.

Deploy. App tự tạo bảng/index bằng schema.sql lúc khởi động với tài khoản sở hữu database. Không cần import SQL thủ công. Nếu muốn dùng role chỉ có INSERT, cần tạo bảng trước bằng role quản trị và điều chỉnh cơ chế khởi tạo ứng dụng.

Mở URL Render tại /health kiểm tra OK, sau đó mở / điền khảo sát và truy vấn bảng kiểm tra dòng mới. Không thêm /ch04survey vì Render dùng ROOT.war. Nếu DB chưa Available hoặc biến sai, health không đạt; xem Logs, sửa rồi redeploy. DB lỗi lúc Submit trả 503, dữ liệu sai trả 400.

Tài liệu Docker: https://render.com/docs/docker .

## Render Blueprint — cách thay thế

render.yaml tạo cả database và web, tự nối DB_* qua fromDatabase. New → Blueprint → chọn repo → kiểm tra gói/cấu hình trước khi Deploy. File chọn free và Singapore, chỉnh nếu tài khoản/vùng không hỗ trợ. Nếu đã có web, ưu tiên cấu hình thủ công để tránh tạo trùng. Không cần dùng cả hai cách.

## Dữ liệu local và giới hạn

Schema được tạo tự động nhưng dữ liệu local không tự chuyển. Nên để Render trống rồi gửi khảo sát mới; muốn chuyển dữ liệu local, xem DATABASE.md. Không upload thư mục data PostgreSQL vào Docker/GitHub.

Chưa có đăng nhập/trang quản trị hoặc gửi email thật. Xem dữ liệu bằng pgAdmin/psql. Mỗi POST thành công tạo một dòng; refresh POST có thể gửi lại. Dữ liệu còn sau khi web restart, miễn database không bị xóa/hết hạn. Render Postgres Free hết hạn sau 30 ngày.
