import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../config/gaming_theme.dart';
import '../widgets/gaming/gaming_app_bar.dart';
import '../widgets/gaming/gaming_card.dart';
import '../widgets/gaming/gaming_dialog.dart';
import 'auth/two_factor_setup_screen.dart';

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
        return Scaffold(
          backgroundColor: GamingTheme.primaryDark,
          appBar: const GamingAppBar(
            title: 'CÀI ĐẶT',
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(GamingTheme.m),
            children: [
              // --- Nhóm 1: Tài khoản ---
              _buildSectionTitle('TÀI KHOẢN & BẢO MẬT'),
              GamingCard(
                hasBorder: true,
                child: Column(
                  children: [
                    _buildNavTile(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                      subtitle: 'Chỉnh sửa hồ sơ, email',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.fingerprint,
                      title: 'Đăng nhập vân tay/FaceID',
                      value: false,
                      onChanged: (value) {},
                    ),
                    _buildDivider(),
                      _buildNavTile(
                        icon: Icons.lock_outline,
                        title: 'Đổi mật khẩu',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildNavTile(
                        icon: Icons.security,
                        title: 'Xác thực 2 yếu tố (2FA)',
                        subtitle: 'Bảo vệ tài khoản bằng Google Authenticator',
                        onTap: () {
                           Navigator.push(
                             context, 
                             MaterialPageRoute(builder: (_) => const TwoFactorSetupScreen())
                           );
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: GamingTheme.l),

              // --- Nhóm 2: Ứng dụng ---
              _buildSectionTitle('CÀI ĐẶT CHUNG'),
              GamingCard(
                hasBorder: true,
                child: Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.notifications_none_outlined,
                      title: 'Thông báo đẩy',
                      value: settingsProvider.settings.notificationsEnabled,
                      onChanged: (value) {
                        settingsProvider.updateNotifications(value);
                      },
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.dark_mode,
                      title: 'Chế độ Gaming Hub',
                      subtitle: 'App sử dụng chế độ tối tối ưu cho game',
                    ),
                    _buildDivider(),
                    _buildNavTile(
                      icon: Icons.language_outlined,
                      title: 'Ngôn ngữ',
                      trailingText: _getLanguageName(
                        settingsProvider.settings.selectedLanguage,
                      ),
                      onTap: () => _showLanguagePicker(context, settingsProvider),
                    ),
                    _buildDivider(),
                    _buildVolumeTile(settingsProvider: settingsProvider),
                  ],
                ),
              ),

              const SizedBox(height: GamingTheme.l),

              // --- Nhóm 3: Khác ---
              _buildSectionTitle('THÔNG TIN & HỖ TRỢ'),
              GamingCard(
                hasBorder: true,
                child: Column(
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
              ),

              const SizedBox(height: GamingTheme.xl),
              // Nút đăng xuất
              _buildLogOutButton(),
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
        return Container(
          padding: const EdgeInsets.all(GamingTheme.l),
          decoration: BoxDecoration(
            color: GamingTheme.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: GamingTheme.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: GamingTheme.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: GamingTheme.l),
              Text(
                'CHỌN NGÔN NGỮ',
                style: GamingTheme.h3,
              ),
              const SizedBox(height: GamingTheme.l),
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
                    style: GamingTheme.bodyLarge.copyWith(
                      color: isSelected 
                          ? GamingTheme.primaryAccent 
                          : GamingTheme.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: GamingTheme.primaryAccent)
                      : null,
                  onTap: () {
                    provider.updateLanguage(lang['code']!);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: GamingTheme.l),
            ],
          ),
        );
      },
    );
  }

  // --- Các Widget tiện ích ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: GamingTheme.m, bottom: GamingTheme.xs),
      child: Text(
        title,
        style: GamingTheme.h3.copyWith(
          color: GamingTheme.primaryAccent,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(GamingTheme.xs),
        decoration: BoxDecoration(
          color: GamingTheme.primaryAccent.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: GamingTheme.primaryAccent.withOpacity(0.5),
          ),
        ),
        child: Icon(icon, color: GamingTheme.primaryAccent, size: 20),
      ),
      title: Text(
        title,
        style: GamingTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle, 
              style: GamingTheme.bodySmall.copyWith(
                color: GamingTheme.textSecondary,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: GamingTheme.bodySmall,
            ),
          const SizedBox(width: GamingTheme.xxs),
          Icon(Icons.chevron_right, color: GamingTheme.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      secondary: Container(
        padding: const EdgeInsets.all(GamingTheme.xs),
        decoration: BoxDecoration(
          color: value
              ? GamingTheme.easyGreen.withOpacity(0.2)
              : GamingTheme.textDisabled.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: value 
                ? GamingTheme.easyGreen.withOpacity(0.5)
                : GamingTheme.textDisabled.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon, 
          color: value ? GamingTheme.easyGreen : GamingTheme.textDisabled,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GamingTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: GamingTheme.easyGreen,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(GamingTheme.xs),
        decoration: BoxDecoration(
          color: GamingTheme.primaryAccent.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: GamingTheme.primaryAccent.withOpacity(0.5),
          ),
        ),
        child: Icon(icon, color: GamingTheme.primaryAccent, size: 20),
      ),
      title: Text(
        title,
        style: GamingTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GamingTheme.bodySmall,
      ),
    );
  }

  Widget _buildVolumeTile({
    required SettingsProvider settingsProvider,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(GamingTheme.xs),
            decoration: BoxDecoration(
              color: GamingTheme.primaryAccent.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: GamingTheme.primaryAccent.withOpacity(0.5),
              ),
            ),
            child: Icon(Icons.volume_up, color: GamingTheme.primaryAccent, size: 20),
          ),
          title: Text(
            'Âm lượng báo thức',
            style: GamingTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GamingTheme.l),
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: GamingTheme.primaryAccent,
              inactiveTrackColor: GamingTheme.surfaceLight,
              thumbColor: GamingTheme.primaryAccent,
              overlayColor: GamingTheme.primaryAccent.withOpacity(0.2),
              valueIndicatorColor: GamingTheme.primaryAccent,
              valueIndicatorTextStyle: GamingTheme.bodySmall.copyWith(
                color: GamingTheme.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: settingsProvider.settings.alarmVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(settingsProvider.settings.alarmVolume * 100).round()}%',
              onChanged: (value) {
                settingsProvider.updateVolume(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 60,
      endIndent: GamingTheme.m,
      color: GamingTheme.border.withOpacity(0.3),
    );
  }

  Widget _buildLogOutButton() {
    return GamingCard(
      hasBorder: true,
      backgroundColor: GamingTheme.surfaceDark,
      onTap: () async {
        // Show confirmation dialog
        final confirmed = await GamingDialog.showConfirm(
          context,
          title: 'Đăng xuất',
          message: 'Bạn có chắc chắn muốn đăng xuất?',
          confirmText: 'Đăng xuất',
          cancelText: 'Hủy',
        );

        if (confirmed && context.mounted) {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        }
      },
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(GamingTheme.xs),
          decoration: BoxDecoration(
            color: GamingTheme.hardRed.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: GamingTheme.hardRed.withOpacity(0.5),
            ),
          ),
          child: Icon(Icons.logout, color: GamingTheme.hardRed, size: 20),
        ),
        title: Text(
          'ĐĂNG XUẤT',
          style: GamingTheme.bodyLarge.copyWith(
            color: GamingTheme.hardRed,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
