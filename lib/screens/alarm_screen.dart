import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with TickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  static const MethodChannel _channel = MethodChannel('smart_student_tools');

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Load alarms from Hive database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlarmProvider>().loadAlarms();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showAddAlarmDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddAlarmSheet(),
    );
  }

  void _listenVoiceCommand() async {
    setState(() => _isListening = true);

    // Hiển thị overlay đang nghe
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildListeningOverlay(),
    );

    try {
      final result = await _channel.invokeMethod('processVoiceAlarmCommand');

      if (!mounted) return;

      Navigator.of(context).pop(); // Đóng overlay

      setState(() => _isListening = false);

      if (result != null) {
        // Xử lý kết quả từ Kotlin (Map)
        if (result is Map) {
          final success = result['success'] as bool? ?? false;
          final message = result['message'] as String? ?? '';
          final time = result['time'] as String? ?? '';

          if (success && time.isNotEmpty) {
            // Thêm báo thức vào Hive database
            final alarm = AlarmModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              time: time,
              label: 'Báo thức giọng nói',
              isEnabled: true,
            );

            await context.read<AlarmProvider>().addAlarm(alarm);
            _showConfirmationSnackbar(message);
          } else {
            _showConfirmationSnackbar(message);
          }
        } else if (result is String && result.isNotEmpty) {
          // Fallback cho format cũ
          _showConfirmationSnackbar(result);
        }
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop(); // Đóng overlay

      setState(() => _isListening = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConfirmationSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleAlarm(String alarmId) {
    context.read<AlarmProvider>().toggleAlarm(alarmId);
  }

  void _deleteAlarm(String alarmId) {
    context.read<AlarmProvider>().deleteAlarm(alarmId);
  }

  @override
  Widget build(BuildContext context) {
    final alarmProvider = context.watch<AlarmProvider>();
    final alarms = alarmProvider.alarms;
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Báo thức',
          style: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(greeting, now, alarms),
          Expanded(
            child: alarms.isEmpty
                ? _buildEmptyState()
                : _buildAlarmList(alarms),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String _formatRepeatDays(List<int> days) {
    if (days.isEmpty) return '';
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days.map((d) => weekdays[d % 7]).join(', ');
  }

  Widget _buildHeader(String greeting, DateTime now, List<AlarmModel> alarms) {
    final enabledAlarms = alarms.where((a) => a.isEnabled).toList();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 56,
              fontWeight: FontWeight.w300,
              letterSpacing: -2,
            ),
          ),
          if (enabledAlarms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Color(0xFF4A9FFF),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Báo thức tiếp theo: ${enabledAlarms.first.time}',
                    style: const TextStyle(
                      color: Color(0xFF4A9FFF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1B263B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_add,
              size: 48,
              color: Color(0xFF778DA9),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có báo thức nào',
            style: TextStyle(
              color: Color(0xFF778DA9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nhấn + hoặc dùng giọng nói để tạo',
            style: TextStyle(color: Color(0xFF415A77), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmList(List<AlarmModel> alarms) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: alarms.length,
      itemBuilder: (context, index) {
        final alarm = alarms[index];
        return Dismissible(
          key: Key(alarm.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE63946),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => _deleteAlarm(alarm.id),
          child: _buildAlarmCard(alarm),
        );
      },
    );
  }

  Widget _buildAlarmCard(AlarmModel alarm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: alarm.isEnabled
            ? const Color(0xFF1B263B)
            : const Color(0xFF0F1922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alarm.isEnabled
              ? const Color(0xFF4A9FFF).withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.time,
                  style: TextStyle(
                    color: alarm.isEnabled
                        ? Colors.white
                        : const Color(0xFF415A77),
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -1,
                  ),
                ),
                if (alarm.label.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      alarm.label,
                      style: TextStyle(
                        color: alarm.isEnabled
                            ? const Color(0xFF778DA9)
                            : const Color(0xFF415A77),
                        fontSize: 14,
                      ),
                    ),
                  ),
                if (alarm.repeatDays.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _formatRepeatDays(alarm.repeatDays),
                      style: TextStyle(
                        color: alarm.isEnabled
                            ? const Color(0xFF4A9FFF)
                            : const Color(0xFF415A77),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: alarm.isEnabled,
            onChanged: (value) => _toggleAlarm(alarm.id),
            activeThumbColor: const Color(0xFF4A9FFF),
            activeTrackColor: const Color(0xFF4A9FFF).withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildVoiceButton()),
          const SizedBox(width: 16),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Material(
      color: const Color(0xFF415A77),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _isListening ? null : _listenVoiceCommand,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Icon(
                    Icons.mic,
                    color: _isListening
                        ? Color.lerp(
                            const Color(0xFFE63946),
                            Colors.white,
                            _pulseController.value,
                          )
                        : const Color(0xFF778DA9),
                    size: 24,
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Dùng giọng nói',
                style: TextStyle(
                  color: _isListening ? Colors.white : const Color(0xFF778DA9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: const Color(0xFF4A9FFF),
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        onTap: _showAddAlarmDialog,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildListeningOverlay() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(200, 100),
                  painter: SoundWavePainter(_waveController.value),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Đang nghe...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ví dụ: "Đánh thức tôi lúc 7 giờ sáng"',
              style: TextStyle(color: Color(0xFF778DA9), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAlarmSheet() {
    TimeOfDay selectedTime = TimeOfDay.now();

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1B263B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF415A77),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thêm báo thức',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setModalState(() => selectedTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    selectedTime.format(context),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Color(0xFF778DA9)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final alarm = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        int millis = alarm.difference(now).inMilliseconds;
                        if (millis <= 0) {
                          millis += const Duration(days: 1).inMilliseconds;
                        }

                        // Save alarm to Hive database
                        final newAlarm = AlarmModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          time: selectedTime.format(context),
                          label: '',
                          isEnabled: true,
                        );

                        await context.read<AlarmProvider>().addAlarm(newAlarm);

                        try {
                          await _channel.invokeMethod('setAlarm', {
                            'millis': millis,
                          });
                          if (!mounted) return;
                          Navigator.pop(context);
                          _showConfirmationSnackbar(
                            'Đã đặt báo thức ${selectedTime.format(context)}',
                          );
                        } catch (e) {
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${e.toString()}')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A9FFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lưu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }
}

// Custom painter cho hiệu ứng sóng âm thanh
class SoundWavePainter extends CustomPainter {
  final double animationValue;

  SoundWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A9FFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final offsetY = size.height / 2;

      for (double x = 0; x < size.width; x += 5) {
        final y =
            offsetY +
            (20 + i * 5) *
                math.sin(
                  (x / size.width * 2 * math.pi) +
                      (animationValue * 2 * math.pi) +
                      (i * 0.5),
                );
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(
        path,
        paint..color = Color(0xFF4A9FFF).withValues(alpha: 1 - i * 0.15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
