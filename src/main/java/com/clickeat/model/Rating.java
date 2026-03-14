package com.clickeat.model;
import java.sql.Timestamp;

public class Rating {
    private long id;
    private long orderId;
    private Long raterCustomerId;
    private String raterGuestId;
    private String targetType;
    private long targetUserId;
    private int stars;
    private String comment;
    private Timestamp createdAt;
    
    // Additional fields for display/logic
    private String replyComment;
    private String customerName;
    private String orderCode;

    public Rating() {
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public long getOrderId() { return orderId; }
    public void setOrderId(long orderId) { this.orderId = orderId; }

    public Long getRaterCustomerId() { return raterCustomerId; }
    public void setRaterCustomerId(Long raterCustomerId) { this.raterCustomerId = raterCustomerId; }

    public String getRaterGuestId() { return raterGuestId; }
    public void setRaterGuestId(String raterGuestId) { this.raterGuestId = raterGuestId; }

    public String getTargetType() { return targetType; }
    public void setTargetType(String targetType) { this.targetType = targetType; }

    public long getTargetUserId() { return targetUserId; }
    public void setTargetUserId(long targetUserId) { this.targetUserId = targetUserId; }

    public int getStars() { return stars; }
    public void setStars(int stars) { this.stars = stars; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getReplyComment() { return replyComment; }
    public void setReplyComment(String replyComment) { this.replyComment = replyComment; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getOrderCode() { return orderCode; }
    public void setOrderCode(String orderCode) { this.orderCode = orderCode; }
}
