class VehicleDto {
  final String vehicleName;
  final String vehicleType;
  final String? phoneNumber;

  VehicleDto({
    required this.vehicleName,
    required this.vehicleType,
    this.phoneNumber,
  });

  factory VehicleDto.fromJson(Map<String, dynamic> json) => VehicleDto(
    vehicleName: json['vehicleName'] ?? '',
    vehicleType: json['vehicleType'] ?? '',
    phoneNumber: json['phoneNumber'],
  );
}
