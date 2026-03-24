package com.clickeat.util;

import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public final class MailUtil {

    private MailUtil() {
    }

    public static void sendOtpMail(String toEmail, String fullName, String otp) throws Exception {
        // TEST LOCAL: hard-code tam thoi
        final String fromEmail = "nguyenbao.130304@gmail.com";
        final String appPassword = "upytgodwzjxjpwgx"; // bo het khoang trang

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        // timeout de neu loi SMTP thi khong treo lau
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");
        props.put("mail.smtp.writetimeout", "10000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, appPassword);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(fromEmail, "ClickEat"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("ClickEat - Ma xac minh dat lai mat khau");

        String name = (fullName == null || fullName.isBlank()) ? "ban" : fullName;

        String html = ""
                + "<div style='font-family:Arial,sans-serif;max-width:600px;margin:0 auto;padding:24px;'>"
                + "<h2 style='color:#f97316;margin-bottom:12px;'>ClickEat - Dat lai mat khau</h2>"
                + "<p>Xin chao <b>" + escapeHtml(name) + "</b>,</p>"
                + "<p>Ma xac minh cua ban la:</p>"
                + "<div style='font-size:32px;font-weight:800;letter-spacing:8px;color:#111827;"
                + "background:#fff7ed;border:1px solid #fed7aa;border-radius:16px;padding:16px 20px;"
                + "display:inline-block;margin:12px 0;'>"
                + otp
                + "</div>"
                + "<p>Ma nay chi co hieu luc trong <b>60 giay</b>.</p>"
                + "<p>Neu ban khong yeu cau dat lai mat khau, vui long bo qua email nay.</p>"
                + "<p style='margin-top:24px;color:#6b7280;'>ClickEat Team</p>"
                + "</div>";

        message.setContent(html, "text/html; charset=UTF-8");
        Transport.send(message);
    }

    private static String escapeHtml(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}