import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

// Chuyển sang StatefulWidget để quản lý trạng thái các nút bật/tắt
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load settings từ Hive khi màn hình khởi động
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final isDarkMode = settingsProvider.settings.isDarkMode;
        final bgColor = isDarkMode
            ? const Color(0xFF0D1B2A)
            : const Color(0xFFF0F2F5);
        final cardColor = isDarkMode ? const Color(0xFF1B263B) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final subtitleColor = isDarkMode
            ? const Color(0xFF778DA9)
            : Colors.grey[600];

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              'Cài đặt',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Nhóm 1: Tài khoản ---
              _buildSectionTitle('Tài khoản & Bảo mật', subtitleColor!),
              _buildSettingsContainer(
                cardColor: cardColor,
                children: [
                  _buildNavTile(
                    icon: Icons.person_outline,
                    title: 'Thông tin cá nhân',
                    subtitle: 'Chỉnh sửa hồ sơ, email',
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    onTap: () {
                      // Điều hướng đến trang thông tin
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.fingerprint,
                    title: 'Đăng nhập vân tay/FaceID',
                    value: false, // TODO: Implement biometric
                    textColor: textColor,
                    onChanged: (value) {
                      // TODO: Save biometric preference
                    },
                  ),
                  _buildDivider(),
                  _buildNavTile(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Nhóm 2: Ứng dụng ---
              _buildSectionTitle('Cài đặt chung', subtitleColor),
              _buildSettingsContainer(
                cardColor: cardColor,
                children: [
                  _buildSwitchTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Thông báo đẩy',
                    value: settingsProvider.settings.notificationsEnabled,
                    textColor: textColor,
                    onChanged: (value) {
                      settingsProvider.updateNotifications(value);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Chế độ tối (Dark Mode)',
                    value: isDarkMode,
                    textColor: textColor,
                    onChanged: (value) {
                      settingsProvider.updateTheme(value ? 'dark' : 'light');
                    },
                  ),
                  _buildDivider(),
                  _buildNavTile(
                    icon: Icons.language_outlined,
                    title: 'Ngôn ngữ',
                    trailingText: _getLanguageName(
                      settingsProvider.settings.selectedLanguage,
                    ),
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    onTap: () => _showLanguagePicker(context, settingsProvider),
                  ),
                  _buildDivider(),
                  _buildVolumeTile(
                    settingsProvider: settingsProvider,
                    textColor: textColor,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Nhóm 3: Khác ---
              _buildSectionTitle('Thông tin & Hỗ trợ', subtitleColor),
              _buildSettingsContainer(
                cardColor: cardColor,
                children: [
                  _buildNavTile(
                    icon: Icons.help_outline,
                    title: 'Trợ giúp & Phản hồi',
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildNavTile(
                    icon: Icons.info_outline,
                    title: 'Về ứng dụng',
                    trailingText: 'v1.0.2',
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 32),
              // Nút đăng xuất tách biệt
              _buildLogOutButton(cardColor),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageName(String code) {
    const languages = {
      'vi': 'Tiếng Việt',
      'en': 'English',
      'zh-cn': '中文',
      'ja': '日本語',
      'ko': '한국어',
    };
    return languages[code] ?? 'Tiếng Việt';
  }

  void _showLanguagePicker(BuildContext context, SettingsProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = provider.settings.isDarkMode;
        final bgColor = isDarkMode ? const Color(0xFF1B263B) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black87;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              Text(
                'Chọn ngôn ngữ',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ...[
                {'code': 'vi', 'name': 'Tiếng Việt'},
                {'code': 'en', 'name': 'English'},
                {'code': 'zh-cn', 'name': '中文'},
                {'code': 'ja', 'name': '日本語'},
                {'code': 'ko', 'name': '한국어'},
              ].map((lang) {
                final isSelected =
                    provider.settings.selectedLanguage == lang['code'];
                return ListTile(
                  title: Text(
                    lang['name']!,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF4A9FFF) : textColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF4A9FFF))
                      : null,
                  onTap: () {
                    provider.updateLanguage(lang['code']!);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- Các Widget tiện ích (Helper Widgets) để tái sử dụng code ---

  // 1. Tiêu đề section
  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 2. Container bo góc chứa các mục cài đặt
  Widget _buildSettingsContainer({
    required List<Widget> children,
    required Color cardColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
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
    required Color textColor,
    required Color subtitleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4A9FFF).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF4A9FFF)),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(color: subtitleColor, fontSize: 13),
            ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: subtitleColor),
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
    required Color textColor,
  }) {
    return SwitchListTile.adaptive(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: value ? Colors.green : Colors.grey),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // 4.5. Volume slider tile
  Widget _buildVolumeTile({
    required SettingsProvider settingsProvider,
    required Color textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4A9FFF).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.volume_up, color: Color(0xFF4A9FFF)),
      ),
      title: Text(
        'Âm lượng báo thức',
        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
      ),
      subtitle: Slider(
        value: settingsProvider.settings.alarmVolume,
        min: 0.0,
        max: 1.0,
        divisions: 10,
        activeColor: const Color(0xFF4A9FFF),
        inactiveColor: const Color(0xFF415A77),
        label: '${(settingsProvider.settings.alarmVolume * 100).round()}%',
        onChanged: (value) {
          settingsProvider.updateVolume(value);
        },
      ),
    );
  }

  // 5. Đường kẻ phân cách
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 60, endIndent: 16);
  }

  // 6. Nút đăng xuất
  Widget _buildLogOutButton(Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout, color: Colors.redAccent),
        ),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          // Xử lý đăng xuất
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
