import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../models/post_data.dart';
import '../models/comment_data.dart';

class PostProvider extends ChangeNotifier {
  final PostService postService;
  PostProvider(this.postService);

  List<PostData> _allPosts = [];
  List<PostData> get allPosts => _allPosts;

  List<PostData> _myPosts = [];
  List<PostData> get myPosts => _myPosts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadPosts({String? category, String? search}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _allPosts = await postService.getPosts(
        category: category,
        search: search,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyPosts(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _myPosts = await postService.getPosts(userId: userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add more methods for like, save, delete, comment, etc. as needed
}
