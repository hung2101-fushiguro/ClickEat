package com.clickeat.controller.ai;

import java.util.ArrayList;
import java.util.List;

/** Parsed, structured response from the AI layer. Immutable after construction. */
public final class StructuredAiResponse {

    // ── Core fields ──────────────────────────────────────────────────────────
    private final String intent;
    private final boolean needsClarification;
    private final String naturalResponse;
    private final String nutritionNote;
    private final String cta;

    // ── Parse diagnostics ────────────────────────────────────────────────────
    private final boolean parsedJson;
    private final boolean usedFallbackRecommendations;
    private final String parseFailureReason;

    // ── Lists ────────────────────────────────────────────────────────────────
    private final List<String> clarificationQuestions;
    private final List<Recommendation> recommendations;
    private final List<MemoryWritebackEntry> memoryWritebacks;

    private StructuredAiResponse(Builder b) {
        this.intent = b.intent;
        this.needsClarification = b.needsClarification;
        this.naturalResponse = b.naturalResponse;
        this.nutritionNote = b.nutritionNote;
        this.cta = b.cta;
        this.parsedJson = b.parsedJson;
        this.usedFallbackRecommendations = b.usedFallbackRecommendations;
        this.parseFailureReason = b.parseFailureReason;
        this.clarificationQuestions = List.copyOf(b.clarificationQuestions);
        this.recommendations = List.copyOf(b.recommendations);
        this.memoryWritebacks = List.copyOf(b.memoryWritebacks);
    }

    // ── Accessors ─────────────────────────────────────────────────────────────
    public String intent()                              { return intent; }
    public boolean needsClarification()                 { return needsClarification; }
    public String naturalResponse()                     { return naturalResponse; }
    public String nutritionNote()                       { return nutritionNote; }
    public String cta()                                 { return cta; }
    public boolean parsedJson()                         { return parsedJson; }
    public boolean usedFallbackRecommendations()        { return usedFallbackRecommendations; }
    public String parseFailureReason()                  { return parseFailureReason; }
    public List<String> clarificationQuestions()        { return clarificationQuestions; }
    public List<Recommendation> recommendations()       { return recommendations; }
    public List<MemoryWritebackEntry> memoryWritebacks(){ return memoryWritebacks; }

    // ── Inner types ───────────────────────────────────────────────────────────

    public static final class Recommendation {
        public final String dishName;
        public final String reason;
        public final int healthScore;
        public final boolean isHealthyAlternative;
        public final Integer estimatedCalories;
        public final String priceLevel;
        public final List<String> tags;

        public Recommendation(String dishName, String reason, int healthScore,
                              boolean isHealthyAlternative, Integer estimatedCalories,
                              String priceLevel, List<String> tags) {
            this.dishName = dishName;
            this.reason = reason;
            this.healthScore = Math.max(1, Math.min(10, healthScore));
            this.isHealthyAlternative = isHealthyAlternative;
            this.estimatedCalories = estimatedCalories;
            this.priceLevel = priceLevel == null ? "unknown" : priceLevel;
            this.tags = tags == null ? List.of() : List.copyOf(tags);
        }
    }

    public static final class MemoryWritebackEntry {
        public final String key;
        public final String value;
        public final double confidence;

        public MemoryWritebackEntry(String key, String value, double confidence) {
            this.key = key;
            this.value = value;
            this.confidence = confidence;
        }
    }

    // ── Builder ───────────────────────────────────────────────────────────────

    public static Builder builder() { return new Builder(); }

    public static final class Builder {
        private String intent = "fallback";
        private boolean needsClarification = false;
        private String naturalResponse = "Mình gợi ý nhanh vài món để bạn chọn nhé.";
        private String nutritionNote = "";
        private String cta = "Bạn muốn mình chốt món nào luôn?";
        private boolean parsedJson = false;
        private boolean usedFallbackRecommendations = false;
        private String parseFailureReason = "";
        private List<String> clarificationQuestions = new ArrayList<>();
        private List<Recommendation> recommendations = new ArrayList<>();
        private List<MemoryWritebackEntry> memoryWritebacks = new ArrayList<>();

        public Builder intent(String v)                             { intent = v; return this; }
        public Builder needsClarification(boolean v)               { needsClarification = v; return this; }
        public Builder naturalResponse(String v)                   { naturalResponse = v; return this; }
        public Builder nutritionNote(String v)                     { nutritionNote = v; return this; }
        public Builder cta(String v)                               { cta = v; return this; }
        public Builder parsedJson(boolean v)                       { parsedJson = v; return this; }
        public Builder usedFallbackRecommendations(boolean v)      { usedFallbackRecommendations = v; return this; }
        public Builder parseFailureReason(String v)                { parseFailureReason = v; return this; }
        public Builder clarificationQuestions(List<String> v)      { clarificationQuestions = v; return this; }
        public Builder recommendations(List<Recommendation> v)     { recommendations = v; return this; }
        public Builder memoryWritebacks(List<MemoryWritebackEntry> v){ memoryWritebacks = v; return this; }

        public StructuredAiResponse build() { return new StructuredAiResponse(this); }
    }
}
