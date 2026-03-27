package com.clickeat.model;

import java.sql.Timestamp;

public class AITrainingEvent {

    private long id;
    private int userId;
    private String userMessage;
    private String systemContext;
    private String conversationContext;
    private String promptHash;
    private String aiReply;
    private boolean hasProfile;
    private String healthGoal;
    private Integer feedbackScore;
    private String feedbackNote;
    private String feedbackCategory;
    private String feedbackGroundTruth;
    private String feedbackErrorType;
    private Timestamp feedbackAt;
    private Timestamp createdAt;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserMessage() {
        return userMessage;
    }

    public void setUserMessage(String userMessage) {
        this.userMessage = userMessage;
    }

    public String getSystemContext() {
        return systemContext;
    }

    public void setSystemContext(String systemContext) {
        this.systemContext = systemContext;
    }

    public String getAiReply() {
        return aiReply;
    }

    public void setAiReply(String aiReply) {
        this.aiReply = aiReply;
    }

    public String getConversationContext() {
        return conversationContext;
    }

    public void setConversationContext(String conversationContext) {
        this.conversationContext = conversationContext;
    }

    public String getPromptHash() {
        return promptHash;
    }

    public void setPromptHash(String promptHash) {
        this.promptHash = promptHash;
    }

    public boolean isHasProfile() {
        return hasProfile;
    }

    public void setHasProfile(boolean hasProfile) {
        this.hasProfile = hasProfile;
    }

    public String getHealthGoal() {
        return healthGoal;
    }

    public void setHealthGoal(String healthGoal) {
        this.healthGoal = healthGoal;
    }

    public Integer getFeedbackScore() {
        return feedbackScore;
    }

    public void setFeedbackScore(Integer feedbackScore) {
        this.feedbackScore = feedbackScore;
    }

    public String getFeedbackNote() {
        return feedbackNote;
    }

    public void setFeedbackNote(String feedbackNote) {
        this.feedbackNote = feedbackNote;
    }

    public String getFeedbackCategory() {
        return feedbackCategory;
    }

    public void setFeedbackCategory(String feedbackCategory) {
        this.feedbackCategory = feedbackCategory;
    }

    public String getFeedbackGroundTruth() {
        return feedbackGroundTruth;
    }

    public void setFeedbackGroundTruth(String feedbackGroundTruth) {
        this.feedbackGroundTruth = feedbackGroundTruth;
    }

    public String getFeedbackErrorType() {
        return feedbackErrorType;
    }

    public void setFeedbackErrorType(String feedbackErrorType) {
        this.feedbackErrorType = feedbackErrorType;
    }

    public Timestamp getFeedbackAt() {
        return feedbackAt;
    }

    public void setFeedbackAt(Timestamp feedbackAt) {
        this.feedbackAt = feedbackAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
