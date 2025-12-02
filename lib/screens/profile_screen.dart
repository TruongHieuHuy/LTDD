import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Data mẫu
  final String name = 'Trương Hiếu Huy';
  final String mssv = '2280601273';
  final String phone = '0948677191';
  final String youtubeUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

  static const MethodChannel _channel = MethodChannel('smart_student_tools');

  Future<void> _callPhone(BuildContext context) async {
    try {
      await _channel.invokeMethod('callPhone', {'phone': phone});
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gọi điện: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _openYouTube(BuildContext context) async {
    try {
      await _channel.invokeMethod('openYouTube', {'url': youtubeUrl});
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi mở YouTube: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền xám sáng hiện đại
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Phần 1: Header & Avatar ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Background Gradient cong
                Container(
                  height: size.height * 0.22, // Chiếm 22% màn hình
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                // Nút Back hoặc Settings trên Header (Optional)
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      // Mở cài đặt
                    },
                  ),
                ),
                // Avatar nằm đè lên ranh giới
                Positioned(
                  top: size.height * 0.22 - 60, // Tính toán để căn giữa biên
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(
                        'lib/assets/images/Huy Đẹp Trai 1 0 2.jpg',
                      ),
                      // child: Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),

            // Khoảng trống bù cho Avatar
            const SizedBox(height: 70),

            // --- Phần 2: Tên & MSSV ---
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'MSSV: $mssv',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Phần 3: Thông tin chi tiết (Card) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin liên hệ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          Icons.phone_iphone,
                          'Số điện thoại',
                          phone,
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildInfoTile(
                          Icons.email_outlined,
                          'Email',
                          'truonghieuhuy1401@gmail.com',
                        ), // Ví dụ thêm
                        const Divider(height: 1, indent: 60),
                        _buildInfoTile(
                          Icons.school_outlined,
                          'Lớp',
                          '22DTHA2',
                        ), // Ví dụ thêm
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- Phần 4: Tiện ích / Action Buttons ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tiện ích khẩn cấp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      // Nút Gọi khẩn cấp (Ưu tiên cao - Màu đỏ)
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: Icons.sos,
                          label: 'Gọi khẩn cấp',
                          color: const Color(0xFFFF4757),
                          onTap: () => _callPhone(context),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Nút YouTube (Ưu tiên thấp hơn - Màu Brand hoặc Xám)
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: Icons.play_circle_fill,
                          label: 'YouTube',
                          color: const Color(
                            0xFF2F3542,
                          ), // Màu đen/xám đậm sang trọng
                          onTap: () => _openYouTube(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget con: Dòng thông tin
  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Widget con: Nút bấm to đẹp
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), // Nền nhạt
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
