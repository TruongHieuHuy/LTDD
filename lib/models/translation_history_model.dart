import 'package:hive/hive.dart';

part 'translation_history_model.g.dart';

@HiveType(typeId: 1)
class TranslationHistoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String sourceText;

  @HiveField(2)
  String translatedText;

  @HiveField(3)
  String sourceLang;

  @HiveField(4)
  String targetLang;

  @HiveField(5)
  DateTime timestamp;

  @HiveField(6)
  bool isFromOCR;

  TranslationHistoryModel({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    DateTime? timestamp,
    this.isFromOCR = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceText': sourceText,
        'translatedText': translatedText,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
        'timestamp': timestamp.toIso8601String(),
        'isFromOCR': isFromOCR,
      };

  factory TranslationHistoryModel.fromJson(Map<String, dynamic> json) =>
      TranslationHistoryModel(
        id: json['id'],
        sourceText: json['sourceText'],
        translatedText: json['translatedText'],
        sourceLang: json['sourceLang'],
        targetLang: json['targetLang'],
        timestamp: DateTime.parse(json['timestamp']),
        isFromOCR: json['isFromOCR'] ?? false,
      );
}
