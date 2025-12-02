import 'package:flutter/material.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data thành viên với thông tin đầy đủ
    final List<Map<String, dynamic>> members = [
      {
        'name': 'Trương Hiếu Huy',
        'role': 'Team Leader',
        'initial': 'H',
        'mssv': '2280601273',
        'phone': '0948677191',
        'email': 'truonghieuhuy14101@gmail.com',
        'class': '22DTHA2',
        'isLeader': true,
      },
      {
        'name': 'Nguyễn Hoàng Chung',
        'role': 'Mobile Developer',
        'initial': 'C',
        'mssv': '2254810012',
        'phone': '0987654321',
        'email': 'chung.nguyen@example.com',
        'class': 'DHKTPM18ATT',
        'isLeader': false,
      },
      {
        'name': 'Ngô Nguyễn Việt Thắng',
        'role': 'UI/UX Designer',
        'initial': 'T',
        'mssv': '2254810078',
        'phone': '0369852147',
        'email': 'thang.ngo@example.com',
        'class': 'DHKTPM18ATT',
        'isLeader': false,
      },
      {
        'name': 'Lê Nhật Tân',
        'role': 'Backend Developer',
        'initial': 'T',
        'mssv': '2254810045',
        'phone': '0741852963',
        'email': 'tan.le@example.com',
        'class': 'DHKTPM18ATT',
        'isLeader': false,
      },
      {
        'name': 'Đoàn Thành Phát',
        'role': 'QA/Tester',
        'initial': 'P',
        'mssv': '2254810056',
        'phone': '0258963147',
        'email': 'phat.doan@example.com',
        'class': 'DHKTPM18ATT',
        'isLeader': false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền xám nhẹ hiện đại
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Team Members',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Phần Header thống kê
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.group, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dự án Flutter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${members.length} Thành viên • Active',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách thành viên',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
              ],
            ),
          ),

          // Danh sách thành viên
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return _buildMemberCard(context, member, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2575FC),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    Map<String, dynamic> member,
    int index,
  ) {
    // Các màu sắc ngẫu nhiên cho Avatar để đỡ nhàm chán
    final List<Color> avatarColors = [
      Colors.orangeAccent,
      Colors.greenAccent,
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4), // Đổ bóng xuống dưới
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Nếu là leader thì chuyển sang profile, còn lại hiện dialog
            if (member['isLeader'] == true) {
              Navigator.pushNamed(context, '/profile');
            } else {
              _showMemberDetailDialog(
                context,
                member,
                avatarColors[index % avatarColors.length],
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: avatarColors[index % avatarColors.length]
                      .withOpacity(0.2),
                  child: Text(
                    member['initial']!,
                    style: TextStyle(
                      color: avatarColors[index % avatarColors.length]
                          .withOpacity(1), // Màu chữ đậm hơn nền
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          member['role']!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.message_outlined,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () {
                        // TODO: Open chat
                      },
                    ),
                    // Icon để xem chi tiết hoặc star cho leader
                    if (member['isLeader'] == true)
                      const Icon(Icons.star, color: Colors.amber, size: 20)
                    else
                      Icon(Icons.menu, color: Colors.grey[400], size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMemberDetailDialog(
    BuildContext context,
    Map<String, dynamic> member,
    Color themeColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [themeColor.withOpacity(0.1), Colors.white],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: themeColor.withOpacity(0.2),
                child: Text(
                  member['initial']!,
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tên
              Text(
                member['name']!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Role
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  member['role']!,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Thông tin chi tiết
              _buildInfoRow(Icons.badge, 'MSSV', member['mssv']!, themeColor),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.phone,
                'Số điện thoại',
                member['phone']!,
                themeColor,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.email, 'Email', member['email']!, themeColor),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.school, 'Lớp', member['class']!, themeColor),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Call
                      },
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Gọi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: themeColor,
                        side: BorderSide(color: themeColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Message
                      },
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text('Nhắn tin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
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
}
