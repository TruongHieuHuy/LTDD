import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/user_data_service.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const MethodChannel _channel = MethodChannel('smart_student_tools');
  final UserDataService _userService = UserDataService();

  // Data sẽ được load từ service
  late String name;
  late String mssv;
  late String phone;
  late String email;
  late String className;
  final String youtubeUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Load user profile from backend
    final authProvider = context.read<AuthProvider>();
    final userEmail = authProvider.userEmail;
    final username = authProvider.username;

    if (userEmail != null && username != null) {
      setState(() {
        name = username;
        email = userEmail;
        mssv = authProvider.userProfile?.id?.toString() ?? 'N/A';
        // Default values for fields not yet in backend
        phone = 'N/A';
        className = 'N/A';
      });
      return;
    }

    // Fallback to default
    setState(() {
      name = 'Unknown User';
      mssv = 'N/A';
      phone = 'N/A';
      email = userEmail ?? 'N/A';
      className = 'N/A';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Lấy kích thước màn hình
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          'Thông tin cá nhân',
          style: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
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
                  height:
                      size.height *
                      0.18, // Chiếm 18% màn hình (giảm vì có AppBar)
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
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    tooltip: 'Chỉnh sửa profile',
                    onPressed: () => _showEditProfileDialog(context),
                  ),
                ),
                // Avatar nằm đè lên ranh giới
                Positioned(
                  top:
                      size.height * 0.18 -
                      60, // Căn vào đáy background (0.18 - radius)
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

            // Khoảng trống bù cho Avatar (radius 60 + padding)
            const SizedBox(height: 72),

            // --- Phần 2: Tên & MSSV ---
            Text(
              name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
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
                  Text(
                    'Thông tin liên hệ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
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
                        _buildInfoTile(Icons.email_outlined, 'Email', email),
                        const Divider(height: 1, indent: 60),
                        _buildInfoTile(Icons.school_outlined, 'Lớp', className),
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
                  Text(
                    'Tiện ích nhanh',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Row 2 nút nằm ngang
                  Row(
                    children: [
                      // Nút Gọi khẩn cấp
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: Icons.phone_in_talk,
                          label: 'Gọi khẩn cấp',
                          color: const Color(0xFFFF4757),
                          onTap: () => _callPhone(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nút Chatbot AI
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: Icons.smart_toy,
                          label: 'Kajima AI',
                          color: const Color(0xFF5F27CD),
                          onTap: () => Navigator.pushNamed(context, '/chatbot'),
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          title: Text(title, style: theme.textTheme.bodySmall),
          subtitle: Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
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

  // Hàm gọi điện thoại
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

  // Hàm hiển thị dialog chỉnh sửa profile
  void _showEditProfileDialog(BuildContext context) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: name);
    final mssvController = TextEditingController(text: mssv);
    final phoneController = TextEditingController(text: phone);
    final emailController = TextEditingController(text: email);
    final classController = TextEditingController(text: className);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Chỉnh sửa Profile'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField(
                controller: nameController,
                label: 'Họ và tên',
                icon: Icons.person,
              ),
              const SizedBox(height: 12),
              _buildEditField(
                controller: mssvController,
                label: 'MSSV',
                icon: Icons.badge,
              ),
              const SizedBox(height: 12),
              _buildEditField(
                controller: phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildEditField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildEditField(
                controller: classController,
                label: 'Lớp',
                icon: Icons.school,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Cập nhật state local
              setState(() {
                name = nameController.text;
                mssv = mssvController.text;
                phone = phoneController.text;
                email = emailController.text;
                className = classController.text;
              });

              // Đồng bộ với service (sẽ tự động update group screen)
              _userService.updateCurrentUser({
                'name': name,
                'mssv': mssv,
                'phone': phone,
                'email': email,
                'class': className,
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Đã cập nhật profile và đồng bộ với nhóm!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // Widget con: TextField cho dialog chỉnh sửa
  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
      ),
    );
  }
}
