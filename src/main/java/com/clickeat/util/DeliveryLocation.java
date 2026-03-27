package com.clickeat.util;

public class DeliveryLocation {

    private Double latitude;
    private Double longitude;
    private String address;
    private String source; // GPS / DEFAULT_ADDRESS / SESSION

    public DeliveryLocation() {
    }

    public DeliveryLocation(Double latitude, Double longitude, String address, String source) {
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.source = source;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public boolean hasCoordinates() {
        return latitude != null && longitude != null
                && latitude != 0 && longitude != 0;
    }
}