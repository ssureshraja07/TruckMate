import 'package:connector/models/trip_dto.dart';
import 'package:connector/widjets/voice_player_widjet.dart';
import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  final TripDto trip;
  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final hasVoice = trip.voiceUrl != null && trip.voiceUrl!.isNotEmpty;
    final hasPhoto = trip.photoUrl != null && trip.photoUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Photo (full width top)
          if (hasPhoto)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Image.network(
                "http://10.0.2.2:8080${trip.photoUrl}",
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ LEFT — from, to, loadtype, price, date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From → To
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 8,
                            color: Color(0xFF1a1a2e),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            trip.fromLocation,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Container(
                          width: 1.5,
                          height: 12,
                          color: Colors.black26,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle_outlined,
                            size: 8,
                            color: Color(0xFF1a1a2e),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            trip.toLocation,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Load type chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trip.loadType.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1a1a2e),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Text(
                        "₹${trip.offeredPrice != null ? trip.offeredPrice!.toStringAsFixed(0) : '0'}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF065f46),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Date
                      Text(
                        trip.pickupTime != null
                            ? "${trip.pickupTime!}/${trip.pickupTime!}/${trip.pickupTime!}"
                            : '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ RIGHT — voice player (only if voice exists)
                if (hasVoice) ...[
                  const SizedBox(width: 12),
                  VoicePlayerWidget(
                    voiceUrl: "http://10.0.2.2:8080${trip.voiceUrl}",
                  ),
                ],
              ],
            ),
          ),

          // ✅ Description (below if exists)
          if (trip.description != null && trip.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
              child: Text(
                trip.description!,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}
