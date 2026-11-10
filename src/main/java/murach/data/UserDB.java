package murach.data;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.Properties;
import murach.business.Survey;
import murach.business.User;

public final class UserDB {
    private UserDB() {
    }

    // Cau hinh lay tu moi truong, khong ghi mat khau trong ma nguon.
    private static Connection getConnection() throws SQLException {
        String host = required("DB_HOST");
        String port = System.getenv().getOrDefault("DB_PORT", "5432");
        String database = required("DB_NAME");
        Properties properties = new Properties();
        properties.setProperty("user", required("DB_USER"));
        properties.setProperty("password", required("DB_PASSWORD"));
        properties.setProperty("sslmode", System.getenv().getOrDefault("DB_SSLMODE", "require"));
        properties.setProperty("connectTimeout", "5");
        properties.setProperty("socketTimeout", "10");
        return DriverManager.getConnection(
                "jdbc:postgresql://" + host + ":" + port + "/" + database, properties);
    }

    private static String required(String name) throws SQLException {
        String value = System.getenv(name);
        if (value == null || value.isBlank()) {
            throw new SQLException("Missing database configuration: " + name);
        }
        return value;
    }

    private static String tableName() throws SQLException {
        String table = System.getenv().getOrDefault("DB_TABLE", "w2_survey");
        // SQL identifiers cannot be bind parameters; accept only a short simple name.
        if (!table.matches("[a-z][a-z0-9_]{0,39}")) {
            throw new SQLException("DB_TABLE must be a simple lowercase table name (max 40 characters).");
        }
        return table;
    }

    public static void initialize() throws SQLException, IOException {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("PostgreSQL JDBC driver is missing.", ex);
        }
        try (var input = UserDB.class.getResourceAsStream("/db/schema.sql")) {
            if (input == null) {
                throw new IOException("Database schema resource is missing.");
            }
            String sql = new String(input.readAllBytes(), StandardCharsets.UTF_8)
                    .replace("w2_survey", tableName());
            try (Connection connection = getConnection();
                    Statement statement = connection.createStatement()) {
                statement.execute(sql);
            }
        }
    }

    public static boolean isAvailable() throws SQLException {
        try (Connection connection = getConnection()) {
            return connection.isValid(2);
        }
    }

    // Mot INSERT luu ca User va Survey, tranh luu thieu mot nua du lieu.
    public static int insert(User user, Survey survey) throws SQLException {
        String sql = "INSERT INTO public." + tableName() + " "
                + "(first_name, last_name, email, date_of_birth, heard_from, "
                + "wants_updates, email_announcements, contact_via) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection connection = getConnection();
                PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, user.getFirstName());
            statement.setString(2, user.getLastName());
            statement.setString(3, user.getEmail());
            statement.setObject(4, LocalDate.parse(user.getDate()));
            statement.setString(5, survey.getHeardFrom());
            statement.setBoolean(6, survey.isWantsUpdates());
            statement.setBoolean(7, survey.isEmailAnnouncements());
            statement.setString(8, survey.getContactVia());
            return statement.executeUpdate();
        }
    }
}
