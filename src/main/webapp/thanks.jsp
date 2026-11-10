<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Murach's Java Servlets and JSP</title>
    <link rel="stylesheet" href="styles/main.css">
</head>
<body>
    <h1>Thanks for completing our survey</h1>
    <p>Here is the information that you entered:</p>

    <h2>Your information:</h2>

    <label>First Name:</label>
    <span><c:out value="${user.firstName}" /></span><br>

    <label>Last Name:</label>
    <span><c:out value="${user.lastName}" /></span><br>

    <label>Email:</label>
    <span><c:out value="${user.email}" /></span><br>

    <label>Date of Birth:</label>
    <span><c:out value="${user.date}" /></span><br>

    <h2>How did you hear about us?</h2>
    <p><c:out value="${survey.heardFrom}" /></p>

    <h2>Would you like to receive announcements about new CDs and special offers?</h2>
    <p>Receive announcements: <c:out value="${survey.wantsUpdates ? 'Yes' : 'No'}" /></p>
    <p>Receive email announcements: <c:out value="${survey.emailAnnouncements ? 'Yes' : 'No'}" /></p>

    <h2>Please contact me by:</h2>
    <p><c:out value="${survey.contactVia}" /></p>

    <p>To complete another survey, click the Return button below.</p>
    <form action="emailList" method="get">
        <input type="hidden" name="action" value="join">
        <input type="submit" value="Return">
    </form>
</body>
</html>