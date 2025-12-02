import 'package:flutter/material.dart';

// Chuyển sang StatefulWidget để quản lý trạng thái các nút bật/tắt
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Giả lập trạng thái cho các cài đặt
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Màu nền xám hiện đại
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Nhóm 1: Tài khoản ---
          _buildSectionTitle('Tài khoản & Bảo mật'),
          _buildSettingsContainer(
            children: [
              _buildNavTile(
                icon: Icons.person_outline,
                title: 'Thông tin cá nhân',
                subtitle: 'Chỉnh sửa hồ sơ, email',
                onTap: () {
                  // Điều hướng đến trang thông tin
                },
              ),
              _buildDivider(),
               _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Đăng nhập vân tay/FaceID',
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() => _biometricEnabled = value);
                },
              ),
              _buildDivider(),
              _buildNavTile(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- Nhóm 2: Ứng dụng ---
          _buildSectionTitle('Cài đặt chung'),
          _buildSettingsContainer(
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_none_outlined,
                title: 'Thông báo đẩy',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Chế độ tối (Dark Mode)',
                value: _darkModeEnabled,
                onChanged: (value) {
                   setState(() => _darkModeEnabled = value);
                   // Thực tế bạn sẽ gọi theme provider ở đây
                },
              ),
               _buildDivider(),
               _buildNavTile(
                icon: Icons.language_outlined,
                title: 'Ngôn ngữ',
                trailingText: 'Tiếng Việt', // Hiển thị lựa chọn hiện tại
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- Nhóm 3: Khác ---
          _buildSectionTitle('Thông tin & Hỗ trợ'),
          _buildSettingsContainer(
            children: [
              _buildNavTile(
                icon: Icons.help_outline,
                title: 'Trợ giúp & Phản hồi',
                onTap: () {},
              ),
              _buildDivider(),
              _buildNavTile(
                icon: Icons.info_outline,
                title: 'Về ứng dụng',
                trailingText: 'v1.0.2',
                onTap: () {},
              ),
            ],
          ),
           
           const SizedBox(height: 32),
           // Nút đăng xuất tách biệt
           _buildLogOutButton(),
        ],
      ),
    );
  }

  // --- Các Widget tiện ích (Helper Widgets) để tái sử dụng code ---

  // 1. Tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 2. Container bo góc chứa các mục cài đặt
  Widget _buildSettingsContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Column(children: children),
    );
  }

  // 3. Mục cài đặt dạng điều hướng (có mũi tên)
  Widget _buildNavTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) 
            Text(trailingText, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // 4. Mục cài đặt dạng bật/tắt (Switch)
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      secondary: Container(
         padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle
        ),
        child: Icon(icon, color: value ? Colors.green : Colors.grey),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // 5. Đường kẻ phân cách
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 60, endIndent: 16);
  }

  // 6. Nút đăng xuất
  Widget _buildLogOutButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2))
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            shape: BoxShape.circle
          ),
          child: const Icon(Icons.logout, color: Colors.redAccent),
        ),
        title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
        onTap: () {
          // Xử lý đăng xuất
        },
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}