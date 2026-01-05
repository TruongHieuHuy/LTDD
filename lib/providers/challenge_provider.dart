import 'package:flutter/foundation.dart';
import '../models/challenge.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class ChallengeProvider with ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;

  ChallengeProvider(this._apiService, this._socketService) {
    _setupSocketListeners();
  }

  // State variables
  List<Challenge> _pendingChallenges = [];
  List<Challenge> _activeChallenges = [];
  List<Challenge> _historyChallenge = [];
  
  Challenge? _currentChallenge;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Challenge> get pendingChallenges => _pendingChallenges;
  List<Challenge> get activeChallenges => _activeChallenges;
  List<Challenge> get historyChallenges => _historyChallenge;
  Challenge? get currentChallenge => _currentChallenge;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get pendingCount => _pendingChallenges.length;

  // ==================== Socket.IO Event Listeners ====================
  
  void _setupSocketListeners() {
    // TODO: Implement socket event listeners when SocketService supports custom events
    // Currently SocketService only supports chat events
    
    /* Challenge received (new invitation)
    _socketService.on('challenge_received', (data) {
      debugPrint('[ChallengeProvider] Challenge received: $data');
      try {
        final challenge = Challenge.fromJson(data['challenge']);
        _pendingChallenges.insert(0, challenge);
        not ifyListeners();
        
        // Show notification
        _showNotification(data['message'] ?? 'New challenge received!');
      } catch (e) {
        debugPrint('[ChallengeProvider] Error parsing challenge_received: $e');
      }
    });
    */

    // Similar for other events...
    // challenge_accepted, challenge_rejected, game_selected, game_completed, challenge_completed
    
    debugPrint('[ChallengeProvider] Socket listeners setup (placeholder)');
  }

  // ==================== API Methods ====================

  /// Load pending challenges
  Future<void> loadPendingChallenges() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.getPendingChallenges();
      _pendingChallenges = data.map((json) => Challenge.fromJson(json)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChallengeProvider] Error loading pending: $e');
    }
  }

  /// Load active challenges
  Future<void> loadActiveChallenges() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.getActiveChallenges();
      _activeChallenges = data.map((json) => Challenge.fromJson(json)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChallengeProvider] Error loading active: $e');
    }
  }

  /// Load challenge history
  Future<void> loadChallengeHistory({int limit = 20, int offset = 0}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.getChallengeHistory(limit: limit, offset: offset);
      _historyChallenge = (data['challenges'] as List)
          .map((json) => Challenge.fromJson(json))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChallengeProvider] Error loading history: $e');
    }
  }

  /// Create a new challenge
  Future<Challenge?> createChallenge({
    required String opponentId,
    required int betAmount,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.createChallenge(
        opponentId: opponentId,
        betAmount: betAmount,
      );
      
      final challenge = Challenge.fromJson(data);
      
      // Add to pending list (we created it, waiting for opponent)
      _pendingChallenges.insert(0, challenge);
      
      _isLoading = false;
      notifyListeners();
      
      return challenge;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChallengeProvider] Error creating challenge: $e');
      return null;
    }
  }

  /// Accept a challenge
  Future<bool> acceptChallenge(String challengeId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.acceptChallenge(challengeId);
      final challenge = Challenge.fromJson(data);
      
      // Move from pending to active
      _pendingChallenges.removeWhere((c) => c.id == challengeId);
      _activeChallenges.insert(0, challenge);
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChallengeProvider] Error accepting challenge: $e');
      return false;
    }
  }

  /// Reject a challenge
  Future<bool> rejectChallenge(String challengeId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.rejectChallenge(challengeId);
      
      // Remove from pending
      _pendingChallenges.removeWhere((c) => c.id == challengeId);
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChallengeProvider] Error rejecting challenge: $e');
      return false;
    }
  }

  /// Vote for a game
  Future<bool> voteForGame({
    required String challengeId,
    required int gameNumber,
    required String gameType,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.voteForGame(
        challengeId: challengeId,
        gameNumber: gameNumber,
        gameType: gameType,
      );
      
      final challenge = Challenge.fromJson(data);
      
      // Update in active list
      final index = _activeChallenges.indexWhere((c) => c.id == challengeId);
      if (index != -1) {
        _activeChallenges[index] = challenge;
      }
      
      // Update current
      if (_currentChallenge?.id == challengeId) {
        _currentChallenge = challenge;
      }
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChallengeProvider] Error voting: $e');
      return false;
    }
  }

  /// Submit score for a game
  Future<bool> submitScore({
    required String challengeId,
    required int gameNumber,
    required int score,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.submitChallengeScore(
        challengeId: challengeId,
        gameNumber: gameNumber,
        score: score,
      );
      
      final challenge = Challenge.fromJson(data);
      
      // Update lists
      final activeIndex = _activeChallenges.indexWhere((c) => c.id == challengeId);
      if (activeIndex != -1) {
        if (challenge.status == ChallengeStatus.completed) {
          // Move to history
          _activeChallenges.removeAt(activeIndex);
          _historyChallenge.insert(0, challenge);
        } else {
          _activeChallenges[activeIndex] = challenge;
        }
      }
      
      // Update current
      if (_currentChallenge?.id == challengeId) {
        _currentChallenge = challenge;
      }
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChallengeProvider] Error submitting score: $e');
      return false;
    }
  }

  /// Load specific challenge details
  Future<void> loadChallengeDetails(String challengeId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _apiService.getChallengeDetails(challengeId);
      _currentChallenge = Challenge.fromJson(data);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[ChallengeProvider] Error loading details: $e');
    }
  }

  /// Set current challenge (for viewing)
  void setCurrentChallenge(Challenge? challenge) {
    _currentChallenge = challenge;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== Helpers ====================
  
  void _showNotification(String message) {
    // This would trigger a snackbar or notification
    // For now just debug print
    debugPrint('[ChallengeProvider] Notification: $message');
    // TODO: Implement actual notification system
  }

  @override
  void dispose() {
    // Clean up socket listeners if needed
    super.dispose();
  }
}
