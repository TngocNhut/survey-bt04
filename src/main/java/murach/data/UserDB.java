package murach.data;

import java.util.List;
import java.util.Objects;
import java.util.concurrent.CopyOnWriteArrayList;
import murach.business.User;

public final class UserDB {
    // Luu tam trong RAM. Du lieu mat khi ung dung/Tomcat khoi dong lai.
    private static final List<User> USERS = new CopyOnWriteArrayList<>();

    private UserDB() {
    }

    public static int insert(User user) {
        USERS.add(Objects.requireNonNull(user, "user"));
        return 1;
    }

    public static List<User> selectAll() {
        return List.copyOf(USERS);
    }
}
