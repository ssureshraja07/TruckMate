class TripDto {
  final int tripId;
  final String fromLocation;
  final String toLocation;
  final String? loadType;
  final double? weightInTons;
  final double? offeredPrice;
  final String? pickupTime;
  final String? description;
  final String? photoUrl;
  final String? voiceUrl;
  final String? status;
  final String? ownerName;
  final String? ownerPhone;

  TripDto({
    required this.tripId,
    required this.fromLocation,
    required this.toLocation,
    this.loadType,
    this.weightInTons,
    this.offeredPrice,
    this.pickupTime,
    this.description,
    this.photoUrl,
    this.voiceUrl,
    this.status,
    this.ownerName,
    this.ownerPhone,
  });

  factory TripDto.fromJson(Map<String, dynamic> json) => TripDto(
    tripId: json['tripId'],
    fromLocation: json['fromLocation'],
    toLocation: json['toLocation'],
    loadType: json['loadType'],
    weightInTons: json['weightInTons']?.toDouble(),
    offeredPrice: json['offeredPrice']?.toDouble(),
    pickupTime: json['pickupTime'],
    description: json['description'],
    photoUrl: json['photoUrl'],
    voiceUrl: json['voiceUrl'],
    status: json['status'],
    ownerName: json['ownerName'],
    ownerPhone: json['ownerPhone'],
  );
}
