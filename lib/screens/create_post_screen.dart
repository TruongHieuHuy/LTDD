import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../utils/database_service.dart';

/// Màn hình tạo/sửa bài viết
class CreatePostScreen extends StatefulWidget {
  final Post? post; // null = create new, not null = edit

  const CreatePostScreen({super.key, this.post});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authorNameController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  File? _selectedImage;
  bool _useImageUrl = false; // true = URL, false = device

  bool get _isEditMode => widget.post != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // Pre-fill form when editing
      _authorNameController.text = widget.post!.authorName;
      _contentController.text = widget.post!.content;
      _imageUrlController.text = widget.post!.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _authorNameController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrlController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrlController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chụp ảnh: $e')));
      }
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final postsBox = DatabaseService.postsBox;

      // Generate new ID
      final newId = postsBox.isEmpty
          ? 1
          : postsBox.values
                    .map((p) => p.id ?? 0)
                    .reduce((a, b) => a > b ? a : b) +
                1;

      final post = Post(
        id: _isEditMode ? widget.post!.id : newId,
        authorName: _authorNameController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: _selectedImage != null
            ? _selectedImage!
                  .path // Save local path
            : (_imageUrlController.text.trim().isEmpty
                  ? null
                  : _imageUrlController.text.trim()),
        timestamp: _isEditMode ? widget.post!.timestamp : DateTime.now(),
        likes: widget.post?.likes ?? 0,
        comments: widget.post?.comments ?? 0,
        authorAvatar: widget.post?.authorAvatar,
        authorId: widget.post?.authorId,
      );

      if (_isEditMode) {
        // Update existing post
        final key = postsBox.keys.firstWhere(
          (k) => postsBox.get(k)?.id == widget.post!.id,
          orElse: () => null,
        );
        if (key != null) {
          await postsBox.put(key, post);
        }
      } else {
        // Add new post
        await postsBox.add(post);
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Đã cập nhật bài viết' : 'Đã tạo bài viết mới',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Sửa bài viết' : 'Tạo bài viết'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _isEditMode ? 'Cập nhật' : 'Đăng',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Author name field
            TextFormField(
              controller: _authorNameController,
              decoration: const InputDecoration(
                labelText: 'Tên tác giả *',
                hintText: 'Nhập tên của bạn',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên tác giả';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Content field
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung *',
                hintText: 'Bạn đang nghĩ gì?',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập nội dung';
                }
                if (value.trim().length < 10) {
                  return 'Nội dung phải có ít nhất 10 ký tự';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Image source selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Thêm hình ảnh',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo_library, size: 18),
                                SizedBox(width: 4),
                                Text('Từ thiết bị'),
                              ],
                            ),
                            selected: !_useImageUrl,
                            onSelected: (selected) {
                              setState(() {
                                _useImageUrl = false;
                                _imageUrlController.clear();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.link, size: 18),
                                SizedBox(width: 4),
                                Text('Nhập URL'),
                              ],
                            ),
                            selected: _useImageUrl,
                            onSelected: (selected) {
                              setState(() {
                                _useImageUrl = true;
                                _selectedImage = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!_useImageUrl) ...[
                      // Device image picker buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _pickFromGallery,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Thư viện'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _pickFromCamera,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Máy ảnh'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // URL input field
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL hình ảnh',
                          hintText: 'https://example.com/image.jpg',
                          prefixIcon: Icon(Icons.link),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_useImageUrl &&
                              value != null &&
                              value.trim().isNotEmpty) {
                            final uri = Uri.tryParse(value.trim());
                            if (uri == null || !uri.hasScheme) {
                              return 'URL không hợp lệ';
                            }
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                        onChanged: (value) => setState(() {}),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Image preview
            if (_selectedImage != null || _imageUrlController.text.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Xem trước ảnh:', style: theme.textTheme.titleSmall),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _imageUrlController.clear();
                          });
                        },
                        tooltip: 'Xóa ảnh',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _imageUrlController.text,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 48),
                                    SizedBox(height: 8),
                                    Text('Không thể tải ảnh'),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Tips card
            Card(
              color: theme.primaryColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Mẹo viết bài',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Viết nội dung rõ ràng, dễ hiểu\n'
                      '• Sử dụng hình ảnh chất lượng cao\n'
                      '• Kiểm tra URL ảnh trước khi đăng\n'
                      '• Nội dung tối thiểu 10 ký tự',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            // Character counter
            const SizedBox(height: 16),
            Text(
              'Số ký tự: ${_contentController.text.length}',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),

            // Submit button
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Cập nhật bài viết' : 'Đăng bài viết',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
