import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/trip_dto.dart';
import '../services/api_service.dart';
import 'package:connector/logins/login_page.dart';
import 'search_page.dart';
import 'package:connector/screens/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _selectedCity = "All cities";
  List<TripDto> _allTrips = [];
  List<String> _cities = ["All cities"];
  bool _isLoading = true;
  String _userName = '';

  List<TripDto> get _filteredTrips {
    if (_selectedCity == "All cities") return _allTrips;
    return _allTrips
        .where(
          (t) => t.fromLocation.toLowerCase() == _selectedCity.toLowerCase(),
        )
        .toList();
  }

  // Unique owners for stories
  List<TripDto> get _storyOwners {
    final seen = <String>{};
    return _filteredTrips
        .where((t) => t.ownerPhone != null && seen.add(t.ownerPhone!))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('name') ?? 'User');
    await _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() => _isLoading = true);
    try {
      final trips = await ApiService.getActiveTrips();
      final cities = {"All cities", ...trips.map((t) => t.fromLocation)};
      setState(() {
        _allTrips = trips;
        _cities = cities.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildFeed(), const SearchPage(), const ProfilePage()],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── FEED ────────────────────────────────────────────────
  Widget _buildFeed() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchTrips,
        child: CustomScrollView(
          slivers: [
            // ── App name center ──
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "TruckMate",
                style: TextStyle(
                  color: Color(0xFF1a1a2e),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.5),
                child: Container(height: 0.5, color: const Color(0xFFE8E8E8)),
              ),
            ),

            // ── City filter chips ──
            SliverToBoxAdapter(child: _buildCityFilter()),

            // ── Stories ──
            SliverToBoxAdapter(child: _buildStories()),

            const SliverToBoxAdapter(
              child: Divider(
                height: 0.5,
                thickness: 0.5,
                color: Color(0xFFE8E8E8),
              ),
            ),

            // ── Posts ──
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF1a1a2e)),
                ),
              )
            else if (_filteredTrips.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    "No trips in this city",
                    style: TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _TripPost(trip: _filteredTrips[i]),
                  childCount: _filteredTrips.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── CITY FILTER ─────────────────────────────────────────
  Widget _buildCityFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: _cities.map((city) {
            final sel = _selectedCity == city;
            return GestureDetector(
              onTap: () => setState(() => _selectedCity = city),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? const Color(0xFF1a1a2e)
                      : const Color(0xFFF0F0F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel
                        ? const Color(0xFF1a1a2e)
                        : const Color(0xFFE0E0E0),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  city,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: sel ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── STORIES ─────────────────────────────────────────────
  Widget _buildStories() {
    if (_storyOwners.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: _storyOwners.map((trip) {
            final initial = (trip.ownerName?.isNotEmpty == true)
                ? trip.ownerName![0].toUpperCase()
                : 'O';
            return GestureDetector(
              onTap: () => setState(() => _selectedCity = trip.fromLocation),
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Story ring
                    Container(
                      width: 62,
                      height: 62,
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1a1a2e), Color(0xFF4a4a8e)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF2d2d4e),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 62,
                      child: Text(
                        trip.ownerName ?? 'Owner',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ──────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBtn(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: "Home",
                active: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavBtn(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: "Search",
                active: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavBtn(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: "Profile",
                active: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TRIP POST (Instagram style) ─────────────────────────────
class _TripPost extends StatefulWidget {
  final TripDto trip;
  const _TripPost({required this.trip});

  @override
  State<_TripPost> createState() => _TripPostState();
}

class _TripPostState extends State<_TripPost> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get _hasPhoto =>
      widget.trip.photoUrl != null && widget.trip.photoUrl!.isNotEmpty;

  bool get _hasVoice =>
      widget.trip.voiceUrl != null && widget.trip.voiceUrl!.isNotEmpty;

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(
        UrlSource("http://10.0.2.2:8080${widget.trip.voiceUrl}"),
      );
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final initial = (trip.ownerName?.isNotEmpty == true)
        ? trip.ownerName![0].toUpperCase()
        : 'O';

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + name + role ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF2d2d4e),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.ownerName ?? 'Owner',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a2e),
                      ),
                    ),
                    Text(
                      "${trip.ownerPhone ?? ''} · ${trip.fromLocation}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Photo + audio overlay ──
          if (_hasPhoto)
            Stack(
              children: [
                Image.network(
                  "http://10.0.2.2:8080${trip.photoUrl}",
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _photoPlaceholder(),
                ),
                if (_hasVoice)
                  Positioned(bottom: 10, right: 10, child: _audioOverlay()),
              ],
            )
          else
            Stack(
              children: [
                _photoPlaceholder(),
                if (_hasVoice)
                  Positioned(bottom: 10, right: 10, child: _audioOverlay()),
              ],
            ),

          // ── Trip info ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // From → To
                Row(
                  children: [
                    const Icon(Icons.circle, size: 7, color: Color(0xFF1a1a2e)),
                    const SizedBox(width: 6),
                    Text(
                      trip.fromLocation,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Container(width: 1, height: 10, color: Colors.black26),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.circle_outlined,
                      size: 7,
                      color: Color(0xFF1a1a2e),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trip.toLocation,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Chips
                Wrap(
                  spacing: 6,
                  children: [
                    _chip(trip.loadType ?? ''),
                    if (trip.weightInTons != null)
                      _chip("${trip.weightInTons} tons"),
                    if (trip.pickupTime != null)
                      _chip(_formatDate(trip.pickupTime!)),
                  ],
                ),

                const SizedBox(height: 6),

                // Price
                if (trip.offeredPrice != null)
                  Text(
                    "₹${trip.offeredPrice!.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF065f46),
                    ),
                  ),

                // Description
                if (trip.description != null &&
                    trip.description!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    trip.description!,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],

                const SizedBox(height: 10),
              ],
            ),
          ),

          const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE8E8E8)),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: const Color(0xFFE8E8E8),
      child: const Icon(Icons.image_outlined, size: 40, color: Colors.white54),
    );
  }

  Widget _audioOverlay() {
    return GestureDetector(
      onTap: _toggleAudio,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 14,
                color: const Color(0xFF1a1a2e),
              ),
            ),
            const SizedBox(width: 6),
            // Wave bars
            Row(
              children: List.generate(7, (i) {
                final heights = [4.0, 8.0, 6.0, 10.0, 7.0, 9.0, 5.0];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 2.5,
                  height: _isPlaying
                      ? heights[(i + 1) % heights.length]
                      : heights[i],
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const SizedBox(width: 6),
            const Text(
              "voice",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Color(0xFF1a1a2e)),
      ),
    );
  }

  String _formatDate(String dt) {
    try {
      final d = DateTime.parse(dt);
      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return dt;
    }
  }
}

// ─── NAV BUTTON ──────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavBtn({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? activeIcon : icon,
            size: 26,
            color: active ? const Color(0xFF1a1a2e) : Colors.black38,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: active ? const Color(0xFF1a1a2e) : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
