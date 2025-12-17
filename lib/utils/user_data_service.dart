import 'package:flutter/foundation.dart';

/// Service quản lý thông tin người dùng và thành viên nhóm
class UserDataService extends ChangeNotifier {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  // Thông tin người dùng hiện tại (owner profile)
  Map<String, dynamic> _currentUser = {
    'name': 'Trương Hiếu Huy',
    'mssv': '2280601273',
    'phone': '0948677191',
    'email': 'truonghieuhuy1401@gmail.com',
    'class': '22DTHA2',
    'role': 'Team Leader',
    'initial': 'H',
    'isLeader': true,
  };

  // Danh sách thành viên nhóm (Gaming nicknames)
  List<Map<String, dynamic>> _members = [
    {
      'name': 'Trương Hiếu Huy',
      'role': 'Team Leader',
      'initial': 'H',
      'mssv': '2280601273',
      'phone': '0948677191',
      'email': 'truonghieuhuy1401@gmail.com',
      'class': '22DTHA2',
      'isLeader': true,
    },
    {
      'name': 'System Admin',
      'role': 'Administrator',
      'initial': 'A',
      'mssv': 'ADMIN001',
      'phone': '0999999999',
      'email': 'admin@gmail.com',
      'class': 'SYSTEM',
      'isLeader': false,
    },
    {
      'name': 'ShadowBlade',
      'role': 'Assassin Master',
      'initial': 'S',
      'mssv': '2280601101',
      'phone': '0901234567',
      'email': 'shadowblade@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
    {
      'name': 'DragonKnight',
      'role': 'Tank Specialist',
      'initial': 'D',
      'mssv': '2280601102',
      'phone': '0902345678',
      'email': 'dragonknight@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
    {
      'name': 'MysticMage',
      'role': 'Mage Pro',
      'initial': 'M',
      'mssv': '2280601103',
      'phone': '0903456789',
      'email': 'mysticmage@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
    {
      'name': 'PhantomArcher',
      'role': 'Marksman Elite',
      'initial': 'P',
      'mssv': '2280601104',
      'phone': '0904567890',
      'email': 'phamtomarcher@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
    {
      'name': 'StormBreaker',
      'role': 'Fighter Legend',
      'initial': 'S',
      'mssv': '2280601105',
      'phone': '0905678901',
      'email': 'stormbreaker@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
    {
      'name': 'CrimsonWolf',
      'role': 'Jungle King',
      'initial': 'C',
      'mssv': '2280601106',
      'phone': '0906789012',
      'email': 'crimsonwolf@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
    {
      'name': 'FrostNova',
      'role': 'Support Master',
      'initial': 'F',
      'mssv': '2280601107',
      'phone': '0907890123',
      'email': 'frostnova@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
    {
      'name': 'BlazeFury',
      'role': 'Burst Damage',
      'initial': 'B',
      'mssv': '2280601108',
      'phone': '0908901234',
      'email': 'blazefury@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
    {
      'name': 'NightHunter',
      'role': 'Sniper Elite',
      'initial': 'N',
      'mssv': '2280601109',
      'phone': '0909012345',
      'email': 'nighthunter@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
    {
      'name': 'ThunderStrike',
      'role': 'All-Rounder',
      'initial': 'T',
      'mssv': '2280601110',
      'phone': '0910123456',
      'email': 'thunderstrike@gmail.com',
      'class': '22DTHA2',
      'isLeader': false,
    },
  ];

  // Getters
  Map<String, dynamic> get currentUser => Map.from(_currentUser);
  List<Map<String, dynamic>> get members => List.from(_members);

  /// Cập nhật thông tin người dùng hiện tại
  void updateCurrentUser(Map<String, dynamic> userData) {
    _currentUser = {..._currentUser, ...userData};

    // Đồng bộ với danh sách thành viên nếu user là leader
    final currentMssv = _currentUser['mssv'];
    final memberIndex = _members.indexWhere((m) => m['mssv'] == currentMssv);

    if (memberIndex != -1) {
      _members[memberIndex] = {
        ..._members[memberIndex],
        'name': _currentUser['name'],
        'phone': _currentUser['phone'],
        'email': _currentUser['email'],
        'class': _currentUser['class'],
      };
    }

    notifyListeners();
  }

  /// Cập nhật thông tin thành viên trong nhóm
  void updateMember(int index, Map<String, dynamic> memberData) {
    if (index >= 0 && index < _members.length) {
      _members[index] = {..._members[index], ...memberData};

      // Nếu member là current user, đồng bộ ngược lại
      if (_members[index]['mssv'] == _currentUser['mssv']) {
        _currentUser = {
          ..._currentUser,
          'name': _members[index]['name'],
          'phone': _members[index]['phone'],
          'email': _members[index]['email'],
          'class': _members[index]['class'],
        };
      }

      notifyListeners();
    }
  }

  /// Xóa thành viên khỏi nhóm
  void removeMember(int index) {
    if (index >= 0 && index < _members.length) {
      // Không cho xóa leader
      if (_members[index]['isLeader'] == true) {
        throw Exception('Không thể xóa Team Leader');
      }
      _members.removeAt(index);
      notifyListeners();
    }
  }

  /// Thêm thành viên mới
  void addMember(Map<String, dynamic> memberData) {
    final newMember = {
      'name': memberData['name'] ?? 'New Member',
      'role': memberData['role'] ?? 'Member',
      'initial': (memberData['name'] as String?)?.substring(0, 1) ?? 'N',
      'mssv': memberData['mssv'] ?? '',
      'phone': memberData['phone'] ?? '',
      'email': memberData['email'] ?? '',
      'class': memberData['class'] ?? '',
      'isLeader': false,
    };
    _members.add(newMember);
    notifyListeners();
  }

  /// Tìm user theo email và set làm currentUser
  Map<String, dynamic>? getUserByEmail(String email) {
    try {
      final user = _members.firstWhere(
        (m) => m['email']?.toLowerCase() == email.toLowerCase(),
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Lấy danh sách bạn bè dựa trên MSSV hiện tại
  /// Logic: TruongHieuHuy (2280601273) <-> System Admin (ADMIN001)
  List<Map<String, dynamic>> getFriends(String currentMssv) {
    // Define friends relationships
    if (currentMssv == '2280601273') {
      // TruongHieuHuy's friend is System Admin
      return _members.where((m) => m['mssv'] == 'ADMIN001').toList();
    } else if (currentMssv == 'ADMIN001') {
      // System Admin's friend is TruongHieuHuy
      return _members.where((m) => m['mssv'] == '2280601273').toList();
    }
    // Other users have no friends (for now)
    return [];
  }
}
