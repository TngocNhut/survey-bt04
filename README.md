# Chapter 04 — Survey

Bài khảo sát giao diện theo ảnh yêu cầu, dùng HTML5, CSS3, Java Servlet, JavaBean và JSP theo cấu trúc repo tham khảo. Mã nguồn trong `src`, không cần cơ sở dữ liệu.

## Mở dự án

Mở thư mục `ch04-survey` bằng IntelliJ IDEA hoặc VS Code. Xem `SOURCES.md` để đối chiếu các nhóm mã với số slide.

```text
src/main/webapp/index.html             Form khảo sát
src/main/webapp/styles/main.css        Giao diện, CSS ngoài
src/main/webapp/im/anh.png             Logo Murach từ slide 28
src/main/java/murach/email/EmailListServlet.java  Nhận form, kiểm tra, forward JSP
src/main/java/murach/business/User.java          JavaBean thông tin người dùng
src/main/java/murach/business/Survey.java        JavaBean câu trả lời
src/main/java/murach/data/UserDB.java            Danh sách người dùng tạm trong RAM
src/main/webapp/thanks.jsp             Hiển thị kết quả qua JSTL c:out
src/main/webapp/WEB-INF/web.xml         Ánh xạ /emailList, trang mặc định
Dockerfile                            Tự build WAR rồi chạy Tomcat 9
render.yaml                           Cấu hình Render Blueprint tùy chọn
```

## Cách hoạt động

1. Người dùng nhập First Name, Last Name, Email và chọn Date of Birth bằng ô ngày có biểu tượng lịch (`input type="date"`), như GitHub tham khảo. Cách hiển thị ngày và lịch tùy trình duyệt/ngôn ngữ; dữ liệu gửi lên máy chủ luôn theo `YYYY-MM-DD`.
2. Chọn một nguồn giới thiệu, có thể bật riêng từng checkbox và chọn cách liên hệ.
3. Submit gửi POST đến `emailList` với hidden `action=add`.
4. Servlet đọc `request.getParameter`, kiểm tra đầu vào, tạo `User` và `Survey`, đặt request attributes và forward đến `thanks.jsp`.
5. JSP hiển thị đủ thông tin và các lựa chọn. Checkbox bỏ trống hiển thị No. Return mở lại form.

`UserDB` chỉ lưu người dùng trong RAM, mất khi khởi động lại; câu trả lời Survey chỉ dùng để hiển thị trong request. Các lựa chọn nhận thông báo là dữ liệu khảo sát, chưa có chức năng gửi email. Không cần tài khoản hay mật khẩu DB.

## Chạy trên máy với Maven và Tomcat

Cần JDK 21 trở lên, Maven 3.9 và **Tomcat 9** (mã dùng `javax.servlet`; không dùng Tomcat 10/11).

Mở PowerShell trong thư mục dự án:

```powershell
mvn clean package
```

Copy `target/ch04survey.war` vào thư mục `webapps` của Tomcat 9. Chạy `bin/startup.bat`, mở `http://localhost:8080/ch04survey/` (thay cổng nếu Tomcat dùng cổng khác).

Không mở HTML bằng file:// để kiểm tra Submit, vì Servlet cần máy chủ Java. Khi chỉ mở file HTML, bạn chỉ xem được giao diện.

## Chạy bằng Docker (tùy chọn)

Nếu máy có Docker đang hoạt động:

```powershell
docker build -t ch04-survey .
docker run --rm -p 8086:8080 ch04-survey
```

Mở `http://localhost:8086/`. Render tự build bằng Docker, máy cá nhân không bắt buộc cài Docker.

## Đưa lên GitHub

Cách dễ nhất: tạo repo mới, rồi dùng GitHub Desktop chọn **Add local repository** cho thư mục `ch04-survey`, tạo repository tại đó nếu được hỏi, commit và **Publish repository**.

Hoặc dùng PowerShell trong đúng thư mục `ch04-survey`:

```powershell
git init
git add .
git commit -m "Add Chapter 04 survey"
git branch -M main
```

Tạo repo rỗng trên GitHub, không tạo README ở bước tạo repo. Sau đó chạy 2 lệnh GitHub cung cấp: `git remote add origin ...` và `git push -u origin main`, dùng URL repo của bạn.

Đảm bảo trang gốc repo hiển thị trực tiếp `pom.xml`, `Dockerfile` và thư mục `src`. Không tải các slide, `.reference`, `target`, WAR hay ZIP lên repo. Dockerfile sẽ tự tạo WAR từ mã nguồn mới, không cần commit file WAR như repo mẫu.

## Triển khai lên Render từng bước

Theo tài liệu chính thức: https://render.com/docs/docker và https://render.com/docs/web-services .

1. Đăng nhập https://dashboard.render.com bằng GitHub.
2. Chọn **New → Web Service**, kết nối GitHub và chọn repo vừa tạo.
3. Điền cấu hình:

| Mục | Giá trị |
| --- | --- |
| Name | Tên riêng của bạn, ví dụ `nhat-ch04-survey` nếu còn trống |
| Branch | `main` |
| Language / Runtime | **Docker** |
| Root Directory | Để trống nếu Dockerfile nằm ở gốc repo |
| Dockerfile Path | `./Dockerfile` |
| Docker Build Context Directory (nếu có) | `.` |
| Instance Type | Free nếu tài khoản có lựa chọn này |
| Docker Command | Để trống, sử dụng CMD trong Dockerfile |
| Health Check Path trong Advanced | `/index.html` |
| Environment Variables | Không cần thêm |

4. Nếu bạn đã upload cả thư mục `ch04-survey` bên trong một repo lớn, đặt **Root Directory = `ch04-survey`**, sau đó giữ Dockerfile Path là `./Dockerfile`. Không upload cả thư mục bài giảng.
5. Chọn **Create Web Service / Deploy Web Service**. Theo dõi Logs: Maven cần báo BUILD SUCCESS; sau đó Tomcat báo Server startup.
6. Khi dịch vụ Live, mở URL `https://<tên-dịch-vụ>.onrender.com/` Render cấp. WAR được đặt tên `ROOT.war` trên máy chủ nên không thêm `/ch04survey` hay `/ch02email` vào URL Render.
7. Điền khảo sát thử và Submit, kiểm tra trang cảm ơn. Nhấn Return để mở lại form.

Render cấp biến `PORT` (mặc định 10000); Dockerfile tự đổi cổng Tomcat theo biến này. Không cần đặt PORT thủ công hay Build Command/Start Command kiểu Node.js.

Sau mỗi lần sửa, commit và push lên nhánh main; Render sẽ tự triển khai lại nếu Auto-Deploy được bật. Có thể dùng Manual Deploy → Deploy latest commit.

Có sẵn `render.yaml` nếu muốn dùng New → Blueprint thay vì nhập cấu hình thủ công; chỉ dùng cách này khi thư mục dự án là gốc repo.

## Lỗi thường gặp

- **Dockerfile not found / pom.xml not found**: kiểm tra Root Directory, Dockerfile Path và Build Context; `pom.xml`, `Dockerfile`, `src` phải cùng cấp.
- **COPY WAR file not found**: dùng Dockerfile đi kèm, không dùng Dockerfile cũ yêu cầu upload `ch02email.war`.
- **404 /ch04survey trên Render**: mở `/` vì máy chủ triển khai ROOT.war.
- **javax.servlet không tìm thấy**: dùng Tomcat 9; kiểm tra chưa đổi Docker base image sang Tomcat 10/11.
- **400 khi Submit**: nhập đủ trường, email hợp lệ, chọn ngày sinh hợp lệ và không nằm trong tương lai. Các lựa chọn phải là giá trị từ form.
- **Lần mở đầu chậm**: gói Free ngủ sau 15 phút không có truy cập và cần thời gian khởi động lại, theo https://render.com/docs/free .
- **Dữ liệu mất khi restart**: đây là danh sách RAM của bài học, chưa có lưu trữ lâu dài.

## Kiểm tra chức năng

Khi máy chủ đang chạy, dùng Python 3 (không cần cài thư viện ngoài):

```powershell
python tests/smoke_test.py http://localhost:8080/ch04survey/
```

Có thể thay URL bằng URL Render để kiểm tra sau triển khai. Bài kiểm tra gửi dữ liệu mẫu, xác minh kết quả, checkbox, UTF-8, escape HTML, Return và đầu vào sai.
