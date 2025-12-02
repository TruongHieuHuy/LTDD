import 'package:flutter/material.dart';
import '../models/translation_history_model.dart';
import '../utils/database_service.dart';

class TranslationProvider with ChangeNotifier {
  List<TranslationHistoryModel> _history = [];
  String _searchQuery = '';

  List<TranslationHistoryModel> get history {
    if (_searchQuery.isEmpty) {
      return _history;
    }
    return _history
        .where(
          (trans) =>
              trans.sourceText.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              trans.translatedText.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  String get searchQuery => _searchQuery;

  TranslationProvider() {
    loadHistory();
  }

  Future<void> loadHistory({int? limit}) async {
    _history = DatabaseService.getAllTranslations(limit: limit);
    notifyListeners();
  }

  Future<void> addTranslation(TranslationHistoryModel translation) async {
    await DatabaseService.saveTranslation(translation);
    await loadHistory();
  }

  Future<void> deleteTranslation(String id) async {
    await DatabaseService.deleteTranslation(id);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await DatabaseService.clearTranslationHistory();
    await loadHistory();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
