class DeviceLocation {
  final String deviceId;
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? description;
  final String? lastUpdated;

  DeviceLocation({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.description,
    this.lastUpdated,
  });

  factory DeviceLocation.fromJson(Map<String, dynamic> json) {
    return DeviceLocation(
      deviceId: json['device_id'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      locationName: json['location_name'],
      description: json['description'],
      lastUpdated: json['last_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'latitude': latitude,
      'longitude': longitude,
      if (locationName != null) 'location_name': locationName,
      if (description != null) 'description': description,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    };
  }

  DeviceLocation copyWith({
    String? deviceId,
    double? latitude,
    double? longitude,
    String? locationName,
    String? description,
    String? lastUpdated,
  }) {
    return DeviceLocation(
      deviceId: deviceId ?? this.deviceId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      description: description ?? this.description,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
