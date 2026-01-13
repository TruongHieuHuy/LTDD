import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../config/gaming_theme.dart';
import '../utils/url_helper.dart';
import '../widgets/gaming/gaming_card.dart';
import '../widgets/gaming/gaming_avatar.dart';
import '../widgets/gaming/gaming_button.dart';
import '../widgets/gaming/gaming_text_field.dart';
import '../widgets/gaming/gaming_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    // Get user data
    final username = authProvider.username ?? 'Unknown Player';
    final email = authProvider.userEmail ?? 'N/A';
    final userId = authProvider.userProfile?.id?.toString() ?? 'N/A';
    final totalScore = authProvider.userProfile?.totalScore ?? 0;
    final gamesPlayed = authProvider.userProfile?.totalGamesPlayed ?? 0;

    // Calculate level based on total score
    final level = (totalScore / 1000).floor() + 1;
    final currentLevelScore = totalScore % 1000;
    final nextLevelScore = 1000;
    final levelProgress = currentLevelScore / nextLevelScore;

    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Gaming-style App Bar with gradient
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gaming gradient background
                    Container(
                      decoration: const BoxDecoration(
                        gradient: GamingTheme.gamingGradient,
                      ),
                    ),
                    // Dark overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Avatar and basic info
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          // Avatar with level badge
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Avatar with neon glow
                              GamingAvatar(
                                imageUrl: authProvider.userProfile?.avatarUrl,
                                username: username,
                                size: 100,
                                hasGlow: true,
                                glowColor: GamingTheme.primaryAccent,
                              ),
                              // Level badge
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration:
                                      GamingTheme.neonBorder(
                                        color: GamingTheme.legendaryGold,
                                      ).copyWith(
                                        gradient: LinearGradient(
                                          colors: [
                                            GamingTheme.legendaryGold,
                                            GamingTheme.primaryAccent,
                                          ],
                                        ),
                                      ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '$level',
                                        style: GamingTheme.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Username
                          Text(
                            username,
                            style: GamingTheme.h2.copyWith(
                              shadows: [
                                const Shadow(
                                  color: Colors.black54,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: GamingTheme.primaryAccent.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              'ID: $userId',
                              style: GamingTheme.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (authProvider.isAdmin)
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-dashboard',
                      );
                    },
                    tooltip: 'Chuyển sang giao diện Admin',
                  ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _showEditProfileDialog(context),
                  tooltip: 'Chỉnh sửa profile',
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: GamingTheme.l),

                  // Level Progress Bar
                  _buildLevelProgress(level, levelProgress, totalScore),

                  const SizedBox(height: GamingTheme.l),

                  // Game Stats Cards
                  _buildGameStats(gamesPlayed, totalScore, level),

                  const SizedBox(height: GamingTheme.l),

                  // Achievements Section
                  _buildAchievementsSection(),

                  const SizedBox(height: GamingTheme.l),

                  // Contact Info
                  _buildContactInfo(email),

                  const SizedBox(height: GamingTheme.l),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: GamingTheme.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgress(int level, double progress, int totalScore) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GamingTheme.l),
      child: GamingNeonCard(
        accentColor: GamingTheme.primaryAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cấp độ $level',
                  style: GamingTheme.h3.copyWith(
                    color: GamingTheme.primaryAccent,
                  ),
                ),
                Text('Cấp ${level + 1}', style: GamingTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: GamingTheme.s),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: GamingTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: GamingTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: GamingTheme.neonGlow,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GamingTheme.xs),
            Text(
              '${(progress * 100).toInt()}% - ${totalScore % 1000}/1000 XP',
              style: GamingTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStats(int gamesPlayed, int totalScore, int level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GamingTheme.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THỐNG KÊ GAME', style: GamingTheme.h3),
          const SizedBox(height: GamingTheme.m),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.games,
                  value: '$gamesPlayed',
                  label: 'Trận đã chơi',
                  color: GamingTheme.easyGreen,
                ),
              ),
              const SizedBox(width: GamingTheme.s),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  value: '$totalScore',
                  label: 'Tổng điểm',
                  color: GamingTheme.legendaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: GamingTheme.s),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  value: '$level',
                  label: 'Cấp độ',
                  color: GamingTheme.primaryAccent,
                ),
              ),
              const SizedBox(width: GamingTheme.s),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  value: '${(gamesPlayed > 0 ? totalScore ~/ gamesPlayed : 0)}',
                  label: 'Điểm TB',
                  color: GamingTheme.secondaryAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return GamingNeonCard(
      accentColor: color,
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: GamingTheme.xs),
          Text(
            value,
            style: GamingTheme.scoreDisplay.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: GamingTheme.xxs),
          Text(
            label,
            style: GamingTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    // Mock achievements data
    final achievements = [
      {'icon': '🏆', 'title': 'First Win', 'progress': 1.0},
      {'icon': '🎯', 'title': '10 Wins', 'progress': 0.6},
      {'icon': '🔥', 'title': 'Win Streak', 'progress': 0.3},
      {'icon': '⭐', 'title': 'Perfect Game', 'progress': 0.0},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GamingTheme.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('THÀNH TỰU', style: GamingTheme.h3),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/achievements');
                },
                child: Text(
                  'Xem tất cả',
                  style: GamingTheme.bodyMedium.copyWith(
                    color: GamingTheme.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GamingTheme.s),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final progress = achievement['progress'] as double;
                final isUnlocked = progress >= 1.0;

                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: GamingTheme.s),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isUnlocked
                              ? LinearGradient(
                                  colors: [
                                    GamingTheme.legendaryGold,
                                    GamingTheme.primaryAccent,
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    GamingTheme.surfaceLight,
                                    GamingTheme.surfaceDark,
                                  ],
                                ),
                          boxShadow: isUnlocked
                              ? [
                                  BoxShadow(
                                    color: GamingTheme.legendaryGold
                                        .withOpacity(0.5),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            achievement['icon'] as String,
                            style: TextStyle(
                              fontSize: 32,
                              color: isUnlocked
                                  ? null
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: GamingTheme.xs),
                      Text(
                        achievement['title'] as String,
                        textAlign: TextAlign.center,
                        style: GamingTheme.bodySmall.copyWith(
                          fontWeight: isUnlocked
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isUnlocked
                              ? GamingTheme.textPrimary
                              : GamingTheme.textDisabled,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GamingTheme.l),
      child: GamingCard(
        hasBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('THÔNG TIN LIÊN HỆ', style: GamingTheme.h3),
            const SizedBox(height: GamingTheme.m),
            _buildInfoRow(Icons.email_outlined, 'Email', email),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GamingTheme.xs),
      child: Row(
        children: [
          Container(
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
          const SizedBox(width: GamingTheme.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GamingTheme.bodySmall),
                Text(
                  value,
                  style: GamingTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GamingTheme.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TIỆN ÍCH NHANH', style: GamingTheme.h3),
          const SizedBox(height: GamingTheme.m),
          Row(
            children: [
              Expanded(
                child: GamingButton(
                  text: 'Kajima AI',
                  icon: Icons.smart_toy,
                  style: GamingButtonStyle.secondary,
                  onPressed: () => Navigator.pushNamed(context, '/chatbot'),
                ),
              ),
              const SizedBox(width: GamingTheme.s),
              Expanded(
                child: GamingButton(
                  text: 'Cài đặt',
                  icon: Icons.settings,
                  style: GamingButtonStyle.secondary,
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                ),
              ),
            ],
          ),
          const SizedBox(height: GamingTheme.s),
          // Logout Button
          GamingButton(
            text: 'ĐĂNG XUẤT',
            icon: Icons.logout,
            style: GamingButtonStyle.outline,
            width: double.infinity,
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await GamingDialog.showConfirm(
      context,
      title: 'Xác nhận đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
    );

    if (confirmed && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.username;
    final userEmail = authProvider.userEmail;

    if (userName == null) return;

    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail ?? '');

    showDialog(
      context: context,
      builder: (context) => _EditProfileDialog(
        nameController: nameController,
        emailController: emailController,
        initialUsername: userName,
        initialEmail: userEmail ?? '',
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final String initialUsername;
  final String initialEmail;

  const _EditProfileDialog({
    required this.nameController,
    required this.emailController,
    required this.initialUsername,
    required this.initialEmail,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        // Validate file extension
        final extension = image.path.toLowerCase();
        if (!extension.endsWith('.jpg') &&
            !extension.endsWith('.jpeg') &&
            !extension.endsWith('.png')) {
          if (mounted) {
            await GamingDialog.showError(
              context,
              title: 'Lỗi',
              message: 'Chỉ chấp nhận file ảnh JPG, JPEG hoặc PNG',
            );
          }
          return;
        }

        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        await GamingDialog.showError(
          context,
          title: 'Lỗi',
          message: 'Lỗi chọn ảnh: ${e.toString()}',
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            Text('Chọn nguồn ảnh', style: GamingTheme.h3),
            const SizedBox(height: GamingTheme.l),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GamingTheme.primaryAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: GamingTheme.primaryAccent),
                ),
                child: Icon(Icons.camera_alt, color: GamingTheme.primaryAccent),
              ),
              title: Text('Camera', style: GamingTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GamingTheme.secondaryAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: GamingTheme.secondaryAccent),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: GamingTheme.secondaryAccent,
                ),
              ),
              title: Text('Thư viện', style: GamingTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: GamingTheme.m),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (widget.nameController.text.isEmpty ||
        widget.emailController.text.isEmpty) {
      await GamingDialog.showError(
        context,
        title: 'Lỗi',
        message: 'Vui lòng điền đầy đủ thông tin',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService();

      // 1. Upload avatar if selected
      if (_selectedImage != null) {
        debugPrint('Uploading avatar...');
        final newAvatarUrl = await apiService.uploadAvatar(
          _selectedImage!.path,
        );
        debugPrint('Avatar uploaded successfully: $newAvatarUrl');

        // Clear image cache to force reload new avatar
        await CachedNetworkImage.evictFromCache(
          UrlHelper.getFullImageUrl(authProvider.userProfile?.avatarUrl),
        );
      }

      // 2. Update username if changed
      if (widget.nameController.text != widget.initialUsername) {
        debugPrint('Updating username...');
        await apiService.updateProfile(username: widget.nameController.text);
        debugPrint('Username updated successfully');
      }

      // 3. Refresh user profile to get latest data
      await authProvider.refreshUserProfile();

      if (mounted) {
        // Force rebuild the entire screen
        setState(() {});

        await GamingDialog.showSuccess(
          context,
          title: 'Thành công',
          message: 'Đã cập nhật profile thành công!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        await GamingDialog.showError(
          context,
          title: 'Lỗi',
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    widget.nameController.dispose();
    widget.emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: GamingTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GamingTheme.radiusLarge),
        side: BorderSide(color: GamingTheme.primaryAccent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(GamingTheme.l),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CHỈNH SỬA PROFILE', style: GamingTheme.h3),
              const SizedBox(height: GamingTheme.l),

              // Avatar Section
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Stack(
                  children: [
                    // Show local image preview or current avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GamingTheme.primaryAccent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GamingTheme.primaryAccent.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : GamingAvatar(
                                username: widget.initialUsername,
                                size: 100,
                                hasGlow:
                                    false, // No glow since outer container has it
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: GamingTheme.primaryAccent,
                          shape: BoxShape.circle,
                          boxShadow: GamingTheme.neonGlow,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GamingTheme.xs),
              Text('Nhấn để đổi ảnh đại diện', style: GamingTheme.bodySmall),
              const SizedBox(height: GamingTheme.l),

              // Name Field
              GamingTextField(
                controller: widget.nameController,
                labelText: 'Tên người dùng',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: GamingTheme.m),

              // Email Field
              GamingTextField(
                controller: widget.emailController,
                labelText: 'Email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: GamingTheme.l),

              // Info Banner
              Container(
                padding: const EdgeInsets.all(GamingTheme.s),
                decoration: BoxDecoration(
                  color: GamingTheme.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
                  border: Border.all(
                    color: GamingTheme.primaryAccent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: GamingTheme.primaryAccent,
                      size: 20,
                    ),
                    const SizedBox(width: GamingTheme.xs),
                    Expanded(
                      child: Text(
                        'Thay đổi sẽ được lưu ngay lập tức',
                        style: GamingTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GamingTheme.l),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GamingButton(
                      text: 'Hủy',
                      style: GamingButtonStyle.outline,
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: GamingTheme.s),
                  Expanded(
                    child: GamingButton(
                      text: 'Lưu',
                      style: GamingButtonStyle.primary,
                      onPressed: _isLoading ? null : _saveProfile,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
