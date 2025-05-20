class MaintenanceRecord {
  final int? id;
  final String carModel; // ✅ Add this line
  final String serviceType;
  final DateTime serviceDate;
  final int mileage;
  final String notes;

  MaintenanceRecord({
    this.id,
    required this.carModel, // ✅ Add this parameter
    required this.serviceType,
    required this.serviceDate,
    required this.mileage,
    required this.notes,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id'],
      carModel: json['carModel'] ?? 'Unknown',
      // ✅ Parse from JSON
      serviceType: json['serviceType'] ?? "Unknown",
      serviceDate: DateTime.tryParse(json['serviceDate'] ?? '') ??
          DateTime(2000),
      mileage: json['mileage'] ?? 0,
      notes: json['notes'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carModel': carModel,
      'serviceType': serviceType,
      'mileage': mileage,
      'notes': notes,
      'serviceDate': serviceDate.toIso8601String(),
      // ✅ convert DateTime to String
    };
  }
}
