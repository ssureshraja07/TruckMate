import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_dto.dart';
import '../models/vehicle_dto.dart';
import '../services/api_service.dart';
import 'package:connector/logins/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _phone = '';
  String _role = '';
  List<TripDto> _myTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'User';
      _phone = prefs.getString('phone') ?? '';
      _role = prefs.getString('role') ?? '';
    });
    await _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() => _isLoading = true);
    try {
      // Owner-ஓட trips எல்லாம் fetch பண்ணு (posts-ஆ காட்டுவோம்)
      final trips = await ApiService.getOwnerTrips(_phone);
      setState(() {
        _myTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String get _username {
    if (_name.isEmpty) return 'user';
    return _name.toLowerCase().replaceAll(' ', '_') + '_trucks';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchTrips,
          child: CustomScrollView(
            slivers: [
              // ── Top bar ──
              SliverToBoxAdapter(child: _buildTopBar()),

              // ── Avatar + Join Members ──
              SliverToBoxAdapter(child: _buildAvatarSection()),

              // ── Name ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    _name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ── Edit / Share buttons ──
              SliverToBoxAdapter(child: _buildActionButtons()),

              // ── Divider ──
              const SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFF222222),
                ),
              ),

              // ── Posts grid ──
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white54,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else if (_myTrips.isEmpty)
                SliverFillRemaining(child: _buildEmptyPosts())
              else
                _buildPostsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TOP BAR ─────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              _username,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showMenu,
            child: const Icon(Icons.menu, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  // ─── AVATAR + JOIN MEMBERS ───────────────────────────────
  Widget _buildAvatarSection() {
    final initial = _name.isNotEmpty ? _name[0].toUpperCase() : 'U';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF333333), width: 2),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF2d2d4e),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Join members button + plus
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a2e),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4a4a8e),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Join Members",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF555555)),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── EDIT / SHARE BUTTONS ────────────────────────────────
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          Expanded(child: _darkBtn("Edit profile", onTap: () {})),
          const SizedBox(width: 8),
          Expanded(child: _darkBtn("Share profile", onTap: () {})),
        ],
      ),
    );
  }

  Widget _darkBtn(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ─── POSTS GRID (2 columns) ──────────────────────────────
  SliverGrid _buildPostsGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => _PostGridItem(trip: _myTrips[i]),
        childCount: _myTrips.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
    );
  }

  // ─── EMPTY POSTS ─────────────────────────────────────────
  Widget _buildEmptyPosts() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.grid_on_outlined,
            color: Colors.white.withOpacity(0.15),
            size: 48,
          ),
          const SizedBox(height: 14),
          const Text(
            "No trips posted yet",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            "Post your first trip to see it here",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── MENU ────────────────────────────────────────────────
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuItem(Icons.settings_outlined, "Settings", () {}),
            _menuItem(Icons.bookmark_outline, "Saved trips", () {}),
            _menuItem(Icons.logout, "Logout", () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            }, isRed: true),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isRed = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isRed ? Colors.red : Colors.white, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: isRed ? Colors.red : Colors.white,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

// ─── POST GRID ITEM ──────────────────────────────────────────
class _PostGridItem extends StatelessWidget {
  final TripDto trip;
  const _PostGridItem({required this.trip});

  bool get _hasPhoto => trip.photoUrl != null && trip.photoUrl!.isNotEmpty;

  bool get _hasVoice => trip.voiceUrl != null && trip.voiceUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo or placeholder
        _hasPhoto
            ? Image.network(
                "http://10.0.2.2:8080${trip.photoUrl}",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),

        // Gradient overlay bottom
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
        ),

        // Voice badge top right
        if (_hasVoice)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D9E75),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    "voice",
                    style: TextStyle(color: Color(0xFF1D9E75), fontSize: 9),
                  ),
                ],
              ),
            ),
          ),

        // From → To bottom left
        Positioned(
          bottom: 5,
          left: 6,
          child: Text(
            "${trip.fromLocation} → ${trip.toLocation}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    final colors = [
      [const Color(0xFF1a1a3e), const Color(0xFF2d2d5e)],
      [const Color(0xFF1a2e1a), const Color(0xFF2d4e2d)],
      [const Color(0xFF2e1a1a), const Color(0xFF4e2d2d)],
      [const Color(0xFF1a2a2e), const Color(0xFF2d3e4e)],
    ];
    final pair = colors[trip.tripId % colors.length];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pair,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_shipping_outlined,
          color: Colors.white.withOpacity(0.2),
          size: 30,
        ),
      ),
    );
  }
}
