import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

const String _databaseUrl =
    'https://projectdht11-72d14-default-rtdb.asia-southeast1.firebasedatabase.app';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  SensorReading _sensor = SensorReading.placeholder;
  bool _isConnecting = true;
  Object? _error;
  StreamSubscription<SensorReading>? _subscription;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _subscription = _sensorStream().listen(
      (reading) {
        setState(() {
          _sensor = reading;
          _isConnecting = false;
          _error = null;
        });
      },
      onError: (err) {
        setState(() {
          _error = err;
          _isConnecting = false;
        });
      },
    );
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _triggerWatering(BuildContext context) async {
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: _databaseUrl,
    );
    try {
      await db.ref('Relay/State').set('ON');
      await Future.delayed(const Duration(seconds: 3));
      await db.ref('Relay/State').set('OFF');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('tanaman Sedang di siram')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim perintah: $e')),
      );
    }
  }

  Stream<SensorReading> _sensorStream() {
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: _databaseUrl,
    );
    return db.ref('Sensor').onValue.map(SensorReading.fromSnapshot);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildStatCard(
      IconData icon,
      String label,
      String value,
      Color color,
      VoidCallback onTap,
    ) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black45),
              ],
            ),
          ),
        ),
      );
    }

    double? _extractNumber(String text) {
      final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(text);
      if (match == null) return null;
      return double.tryParse(match.group(0)!);
    }

    String? _tempCategory(double? value) {
      if (value == null) return null;
      if (value < 20) return 'Kategori: Dingin';
      if (value <= 30) return 'Kategori: Normal';
      return 'Kategori: Panas';
    }

    String? _airHumidityCategory(double? value) {
      if (value == null) return null;
      if (value < 40) return 'Kategori: Kering';
      if (value <= 70) return 'Kategori: Ideal';
      return 'Kategori: Lembap Tinggi';
    }

    String? _soilHumidityCategory(double? value) {
      if (value == null) return null;
      if (value < 40) return 'Kategori: Tanah Kering';
      if (value <= 70) return 'Kategori: Cukup';
      return 'Kategori: Tanah Basah';
    }

    void showDetailsSheet({
      required String title,
      required String value,
      required IconData icon,
      required Color color,
      String? note,
    }) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 46),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Terakhir: ${_sensor.lastUpdatedDisplay}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      if (note != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          note,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    }

    final isOffline =
        _error == null && !_isConnecting && _sensor.isStale(const Duration(seconds: 10));
    final statusText = _error != null
        ? 'Gagal memuat'
        : _isConnecting
            ? 'Menghubungkan...'
            : isOffline
                ? 'Offline'
                : 'Online · ${_sensor.lastUpdatedDisplay}';
    final statusColor = _error != null
        ? Colors.red
        : isOffline
            ? Colors.grey
            : Colors.teal;
    final statusIcon = _error != null
        ? Icons.error_outline
        : isOffline
            ? Icons.wifi_off
            : Icons.wifi_tethering;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                centerTitle: false,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black87,
                title: const Text('Dashboard IoT'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Chip(
                      avatar: Icon(
                        statusIcon,
                        size: 18,
                        color: statusColor,
                      ),
                      label: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: statusColor.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildStatCard(
                        Icons.thermostat,
                        'Suhu',
                        _sensor.temperature,
                        Colors.deepOrange,
                        () => showDetailsSheet(
                          title: 'Detail Suhu',
                          value: _sensor.temperature,
                          icon: Icons.thermostat,
                          color: Colors.deepOrange,
                          note: _tempCategory(_extractNumber(_sensor.temperature)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildStatCard(
                        Icons.water_drop,
                        'Kelembapan Udara',
                        _sensor.humidity,
                        Colors.blue,
                        () => showDetailsSheet(
                          title: 'Detail Kelembapan Udara',
                          value: _sensor.humidity,
                          icon: Icons.water_drop,
                          color: Colors.blue,
                          note: _airHumidityCategory(_extractNumber(_sensor.humidity)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildStatCard(
                        Icons.grass,
                        'Kelembapan Tanah',
                        _sensor.soilHumidity,
                        Colors.teal,
                        () => showDetailsSheet(
                          title: 'Detail Kelembapan Tanah',
                          value: _sensor.soilHumidity,
                          icon: Icons.grass,
                          color: Colors.teal,
                          note:
                              _soilHumidityCategory(_extractNumber(_sensor.soilHumidity)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.teal.withOpacity(0.08),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.eco, color: Colors.teal.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Status Tanaman : ${_sensor.plantStatus}',
                                  style: TextStyle(
                                    color: Colors.teal.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _triggerWatering(context),
                        icon: const Icon(Icons.water_drop),
                        label: const Text(
                          'Siram Tanaman',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Terjadi kesalahan saat memuat data: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Data realtime; tidak perlu refresh manual, tapi tombol tetap disediakan.
          debugPrint('Meminta pembaruan data sensor...');
        },
        label: const Text('Refresh'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}

class SensorReading {
  final String temperature;
  final String humidity;
  final String soilHumidity;
  final String plantStatus;
  final DateTime lastUpdatedTime;

  const SensorReading({
    required this.temperature,
    required this.humidity,
    required this.soilHumidity,
    required this.plantStatus,
    required this.lastUpdatedTime,
  });

  static SensorReading fromSnapshot(DatabaseEvent event) {
    final raw = event.snapshot.value;
    final data = raw is Map ? raw : <String, dynamic>{};
    final lastTime = _parseDate(data['updatedAt']) ?? DateTime.now();
    return SensorReading(
      temperature: _formatValue(data['Suhu'], unit: '°C'),
      humidity:
          _formatValue(data['Kelembapan_Udara'] ?? data['Kelembapan'], unit: '%'),
      soilHumidity: _formatValue(data['Kelembapan_Tanah'], unit: '%'),
      plantStatus: data['Status_Tanaman']?.toString() ?? '--',
      lastUpdatedTime: lastTime,
    );
  }

  static final placeholder = SensorReading(
    temperature: '--',
    humidity: '--',
    soilHumidity: '--',
    plantStatus: '--',
    lastUpdatedTime: DateTime.fromMillisecondsSinceEpoch(0),
  );

  static String _formatValue(dynamic value, {required String unit}) {
    if (value == null) return '--';
    if (value is num) return '${value.toStringAsFixed(1)}$unit';
    return value.toString();
  }

  String get lastUpdatedDisplay => _formatTimeAgo(lastUpdatedTime);

  bool isStale(Duration maxAge) {
    final age = DateTime.now().difference(lastUpdatedTime);
    return age > maxAge;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      // Assume milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed;
    }
    return null;
  }

  static String _formatTimeAgo(DateTime time) {
    if (time.millisecondsSinceEpoch == 0) return 'menunggu data';
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 10) return 'baru saja';
    if (diff.inMinutes < 1) return '${diff.inSeconds}s lalu';
    if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }
}
