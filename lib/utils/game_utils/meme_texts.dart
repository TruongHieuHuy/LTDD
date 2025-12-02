import 'dart:math';

/// Kho Meme Texts cực mặn cho game troll Gen Z
class MemeTexts {
  static final _random = Random();

  // ============ GAME ĐOÁN SỐ ============

  /// Đoán LỚN QUÁ (5 câu random)
  static const List<String> tooHigh = [
    "Ảo tưởng sức mạnh à? 💪❌",
    "Xuống mặt đất đi em 🤡",
    "Bay cao quá té đau đó 🚀💥",
    "Tưởng tượng phong phú thật 🎨",
    "Số bé hơn, não lớn hơn đi 🧠",
  ];

  /// Đoán BÉ QUÁ (5 câu random)
  static const List<String> tooLow = [
    "Yếu đuối vãi 😭",
    "Lên nữa đi, chưa tới đỉnh đâu 📈",
    "Thấp hơn cả điểm Toán của t 📉",
    "Tham vọng đi bro, đừng nhút nhát 🔥",
    "Số lớn hơn, can đảm lên! 💪",
  ];

  /// ĐOÁN ĐÚNG - Cà khịa khi thắng (5 câu)
  static const List<String> correct = [
    "Ăn may thôi đừng tự hào 🎲",
    "Cuối cùng não cũng hoạt động 🧠✨",
    "Plot armor dày quá 🛡️",
    "Hack à?? 🤨📸",
    "Tự nhiên thông minh lên á 🤓",
  ];

  /// THUA CUỘC - Hết lượt (5 câu)
  static const List<String> gameOver = [
    "Về nhà chăn vịt đi 🦆",
    "Non và Xanh lắm 🌿",
    "IQ âm rồi bro 📊↘️",
    "Đầu thai lại đi 🔄",
    "Thôi nghỉ đi, mệt lắm rồi 😴",
  ];

  /// GẦN ĐÚNG - Trong khoảng 5 số (4 câu)
  static const List<String> veryClose = [
    "Ấm rồi ấm rồi 🔥",
    "Sắp tới nơi rồi đó 🎯",
    "Hơi hơi gần gần 👀",
    "Tí nữa thôi, cố lên! 💪",
  ];

  /// SUY NGHĨ LÂU - Quá 15 giây không nhập (4 câu)
  static const List<String> thinking = [
    "Đang load não à? 🧠💤",
    "Cần bình oxy không? 🫁",
    "Có ngủ gật không đấy? 😪",
    "Tư duy chậm vãi 🐌",
  ];

  // ============ GAME BÒ & BÊ ============

  /// CÓ BÒ - Đúng số đúng vị trí
  static String bullsFound(int count) {
    if (count == 1) return "1 con bò về chuồng 🐮✅";
    if (count >= 5) return "Bull run detected! 📈🐂 ($count con)";
    return "$count con bò đang về chuồng 🐮✅";
  }

  /// CÓ BÊ - Đúng số sai vị trí
  static String cowsFound(int count) {
    if (count == 1) return "1 con bê đang lạc đàn 🐄❓";
    if (count >= 4) return "Gần rồi mà chưa tới 🤏 ($count con bê)";
    return "$count con bê đang lạc đàn 🐄❓";
  }

  /// 0 BÒ 0 BÊ - Sai hoàn toàn (5 câu)
  static const List<String> noBullsNoCows = [
    "Tàn rồi, từ đầu đi 💀",
    "Không ai về nhà cả 🏚️",
    "Lạc hết đường luôn 🗺️❌",
    "Toang rồi bro 💥",
    "Ăn gì mà mù vậy? 🙈",
  ];

  /// THẮNG BÒ BÊ (Rare achievement)
  static const List<String> cowsBullsWin = [
    "TÁN THẬN THIỆT À??? 🎆🎉",
    "Hack đấy 100% 🤨📸",
    "Số này mua xổ số đi bro 🎰",
    "Thần tài xuất hiện 💰✨",
    "Đỉnh của chóp luôn 🏔️👑",
  ];

  /// ĐẦU HÀNG - Khi bấm nút surrender
  static const List<String> surrender = [
    "Yếu đuối vãi, nhưng hiểu rồi 🫂",
    "Thoát hiểm thành công 🚪✅",
    "Khôn ngoan đấy, biết tự lượng sức 🧠",
    "Đầu hàng là chiến thuật cao cấp 🏳️",
  ];

  // ============ CHUNG ============

  /// Lấy random text từ list
  static String random(List<String> list) {
    return list[_random.nextInt(list.length)];
  }

  /// Feedback cho thanh kiên nhẫn (Patience Bar)
  static String patienceLevel(double percent) {
    if (percent > 0.7) return "Bình tĩnh quá, sợ 😌";
    if (percent > 0.4) return "Hơi nóng rồi đó 😰";
    if (percent > 0.2) return "Sắp nổ rồi 😡";
    return "MẤT KIỂM SOÁT 🤬💥";
  }

  /// Thời gian nghĩ > 30 giây
  static const String tooLongThinking = "Nghỉ quên mất game luôn à? 😴💤";

  /// Popup quảng cáo giả (Level 12 số)
  static const String fakeAd =
      "🛒 QUẢNG CÁO: Thuốc bổ não giá rẻ\nGiảm 99% chỉ hôm nay!\n(Bấm X để đóng) ❌";
}
