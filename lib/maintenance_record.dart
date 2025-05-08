class MaintenanceRecord {
  final int? id;
  final String serviceType;
  final String serviceDate;
  final int mileage;
  final String notes;

  MaintenanceRecord({
    this.id,
    required this.serviceType,
    required this.serviceDate,
    required this.mileage,
    required this.notes,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id'],
      serviceType: json['serviceType'] ?? "Unknown",
      serviceDate: json['serviceDate']?.toString() ?? "Invalid date",
      mileage: json['mileage'] ?? 0,
      notes: json['notes'] ?? "",
    );
  }


  Map<String, dynamic> toJson() => {
    'serviceType': serviceType,
    'serviceDate': serviceDate,
    'mileage': mileage,
    'notes': notes,
  };
}
