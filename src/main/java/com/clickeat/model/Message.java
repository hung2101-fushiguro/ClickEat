package com.clickeat.model;

import java.sql.Timestamp;

public class Message {

    private long id;
    private long senderId;
    private long receiverId;
    private String content;
    private boolean isRead;
    private Timestamp createdAt;

    // Các trường bổ trợ để hiển thị tên và ảnh người chat cùng
    private String otherPartyName;
    private String otherPartyAvatar;
    private String otherPartyRole;

    public Message() {
    }

    // Getters and Setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getSenderId() {
        return senderId;
    }

    public void setSenderId(long senderId) {
        this.senderId = senderId;
    }

    public long getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(long receiverId) {
        this.receiverId = receiverId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public boolean isIsRead() {
        return isRead;
    }

    public void setIsRead(boolean isRead) {
        this.isRead = isRead;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getOtherPartyName() {
        return otherPartyName;
    }

    public void setOtherPartyName(String otherPartyName) {
        this.otherPartyName = otherPartyName;
    }

    public String getOtherPartyAvatar() {
        return otherPartyAvatar;
    }

    public void setOtherPartyAvatar(String otherPartyAvatar) {
        this.otherPartyAvatar = otherPartyAvatar;
    }

    public String getOtherPartyRole() {
        return otherPartyRole;
    }

    public void setOtherPartyRole(String otherPartyRole) {
        this.otherPartyRole = otherPartyRole;
    }
}
