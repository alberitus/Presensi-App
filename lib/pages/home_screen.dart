import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../model/user.dart';
import '../model/absensi.dart';
import 'profile_screen.dart';
import 'request_screen.dart';

class AbsensiHomeScreen extends StatefulWidget {
  final User user;

  const AbsensiHomeScreen({super.key, required this.user});

  @override
  State<AbsensiHomeScreen> createState() => _AbsensiHomeScreenState();
}

class _AbsensiHomeScreenState extends State<AbsensiHomeScreen>
    with TickerProviderStateMixin {
  final ApiService api = ApiService();
  List<Absensi> absensiList = [];
  bool isLoading = true;
  bool hasCheckedIn = false;
  bool hasCheckedOut = false;
  int _selectedIndex = 0;
  
  Absensi? todayAbsensi;
  late AnimationController _btnController;
  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Button animation controller
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..forward();

    // Page transition animation controller
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeInOut),
    );

    _pageController.forward();
    _loadAbsensiData();
  }

  @override
  void dispose() {
    _btnController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '🌅 Morning,';
    if (hour >= 12 && hour < 17) return '🌞 Afternoon,';
    if (hour >= 17 && hour < 21) return '🌆 Evening,';
    return '🌙 Night,';
  }

  Future<void> _loadAbsensiData() async {
    try {
      final response = await api.get('/absensi?user_id=${widget.user.id}');
      
      setState(() {
        absensiList = (response['data'] as List? ?? [])
            .map((item) => Absensi.fromJson(item))
            .toList();
        
        final today = DateTime.now();
        todayAbsensi = absensiList
            .where(
              (absensi) =>
                  absensi.tanggal.year == today.year &&
                  absensi.tanggal.month == today.month &&
                  absensi.tanggal.day == today.day,
            )
            .firstOrNull;
        
        hasCheckedIn = todayAbsensi?.jamMasuk != null;
        hasCheckedOut = todayAbsensi?.jamKeluar != null;
        
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkIn() async {
    final messenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final position = await LocationService.getCurrentLocation();
      
      if (position == null) {
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('❌ Gagal mendapatkan lokasi GPS'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final locationString = '${position.latitude},${position.longitude}';
      final isFakeGps = await LocationService.isFakeGPS();

      final response = await api.post('/absensi/masuk', {
        'user_id': widget.user.id,
        'lokasi_masuk': locationString,
        'status': 'hadir',
        'is_fake_gps': isFakeGps,
      });

      Navigator.pop(context);
      
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          todayAbsensi = Absensi.fromJson(response['data']);
          hasCheckedIn = true;
          hasCheckedOut = false;
        });
        
        // Restart button animation
        _btnController.reset();
        _btnController.forward();
      }
      
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isFakeGps 
              ? '⚠️ Check in berhasil (Fake GPS terdeteksi!)'
              : '✅ Check in berhasil!'
          ),
          backgroundColor: isFakeGps ? Colors.orange : Colors.green,
        ),
      );

      await _loadAbsensiData();
    } catch (e) {
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkOut() async {
    final messenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final position = await LocationService.getCurrentLocation();
      
      if (position == null) {
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('❌ Gagal mendapatkan lokasi GPS'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final locationString = '${position.latitude},${position.longitude}';

      final response = await api.post('/absensi/keluar', {
        'user_id': widget.user.id,
        'lokasi_keluar': locationString,
      });

      Navigator.pop(context);
      
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          todayAbsensi = Absensi.fromJson(response['data']);
          hasCheckedOut = true;
        });
        
        // Restart button animation
        _btnController.reset();
        _btnController.forward();
      }
      
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Check out berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadAbsensiData();
    } catch (e) {
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getWorkingHours() {
    if (todayAbsensi == null) {
      return '-- - --';
    }
    
    final checkIn = todayAbsensi!.jamMasuk ?? '--:-';
    final checkOut = todayAbsensi!.jamKeluar ?? '--:--';
    
    return '$checkIn - $checkOut';
  }

  void _onNavigate(int index) {
    if (_selectedIndex != index) {
      _pageController.reverse().then((_) {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Animated page transition wrapper
    Widget currentScreen;
    
    if (_selectedIndex == 1) {
      currentScreen = RequestScreen(
        user: widget.user,
        onNavigate: _onNavigate,
      );
    } else if (_selectedIndex == 2) {
      currentScreen = ProfileScreen(
        user: widget.user,
        onNavigate: _onNavigate,
      );
    } else {
      currentScreen = _buildHomeScreen();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: currentScreen,
    );
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: SafeArea(
        child: Column(
          children: [
            // Header with slide animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              tween: Tween(begin: -50.0, end: 0.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: (value + 50) / 50,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              widget.user.namaLengkap,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.user.division} - ${widget.user.role}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Card Working Schedule with scale animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      tween: Tween(begin: 0.8, end: 1.0),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Working Schedule',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEE, dd MMM yyyy').format(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getWorkingHours(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Animated buttons
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildActionButton(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Section with slide up animation
            Expanded(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                tween: Tween(begin: 100.0, end: 0.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value),
                    child: child,
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Menu with stagger animation
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: 0.8 + (0.2 * value),
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMenuIcon(
                                  Icons.calendar_today,
                                  'Attendance\nList',
                                  Colors.green,
                                  0,
                                ),
                                _buildMenuIcon(
                                  Icons.edit,
                                  'Attendance\nCorrection',
                                  Colors.blue,
                                  1,
                                ),
                                _buildMenuIcon(
                                  Icons.work,
                                  'On Duty',
                                  Colors.orange,
                                  2,
                                ),
                                _buildMenuIcon(
                                  Icons.exit_to_app,
                                  'Leave',
                                  Colors.orange,
                                  3,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Riwayat header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Attendance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'View All',
                                style: TextStyle(color: Color(0xFF1565C0)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // List with stagger animation
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.builder(
                                  itemCount: absensiList.take(5).length,
                                  itemBuilder: (context, index) {
                                    final absensi = absensiList[index];
                                    return TweenAnimationBuilder<double>(
                                      duration: Duration(
                                        milliseconds: 400 + (index * 100),
                                      ),
                                      curve: Curves.easeOutCubic,
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(0, 30 * (1 - value)),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: _buildAttendanceCard(absensi),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigate,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Request',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (!hasCheckedIn) {
      return SizedBox(
        key: const ValueKey('check_in'),
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E24AA),
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _checkIn,
          child: const Text(
            'Check In',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    
    if (hasCheckedIn && !hasCheckedOut) {
      return SizedBox(
        key: const ValueKey('check_out'),
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _checkOut,
          child: const Text(
            'Check Out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    
    return Container(
      key: const ValueKey('completed'),
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Completed',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, String label, Color color, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 700 + (index * 100)),
      curve: Curves.elasticOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Absensi absensi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEE, dd MMM yyyy').format(absensi.tanggal),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: absensi.jamMasuk != null ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Day',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          absensi.jamMasuk ?? '--:--',
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: absensi.jamKeluar != null ? Colors.red : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Day',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          absensi.jamKeluar ?? '--:--',
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}