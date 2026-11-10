package murach.business;

public class Survey {

    private String heardFrom;
    private boolean wantsUpdates;
    private boolean emailAnnouncements;
    private String contactVia;

    public Survey() {
    }

    public String getHeardFrom() {
        return heardFrom;
    }

    public void setHeardFrom(String heardFrom) {
        this.heardFrom = heardFrom;
    }

    public boolean isWantsUpdates() {
        return wantsUpdates;
    }

    public void setWantsUpdates(boolean wantsUpdates) {
        this.wantsUpdates = wantsUpdates;
    }

    public boolean isEmailAnnouncements() {
        return emailAnnouncements;
    }

    public void setEmailAnnouncements(boolean emailAnnouncements) {
        this.emailAnnouncements = emailAnnouncements;
    }

    public String getContactVia() {
        return contactVia;
    }

    public void setContactVia(String contactVia) {
        this.contactVia = contactVia;
    }
}