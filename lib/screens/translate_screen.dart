import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'dart:async';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _sourceController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  String _translatedText = '';
  String _sourceLang = 'vi';
  String _targetLang = 'en';
  bool _isLoading = false;
  List<File> _selectedImages = [];
  Timer? _debounce;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  static const MethodChannel _channel = MethodChannel('smart_student_tools');

  final Map<String, String> _languages = {
    'vi': 'Tiếng Việt',
    'en': 'English',
    'zh-cn': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _sourceController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _sourceController.removeListener(_onTextChanged);
    _sourceController.dispose();
    _debounce?.cancel();
    _animController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_sourceController.text.isNotEmpty) {
        _translateText();
      } else {
        setState(() => _translatedText = '');
      }
    });
  }

  Future<void> _translateText() async {
    if (_sourceController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final translation = await _translator.translate(
        _sourceController.text,
        from: _sourceLang,
        to: _targetLang,
      );

      setState(() {
        _translatedText = translation.text;
        _isLoading = false;
      });

      _animController.forward(from: 0.0);
    } catch (e) {
      setState(() {
        _translatedText = 'Lỗi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showError('Lỗi chọn ảnh: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showError('Lỗi chụp ảnh: ${e.toString()}');
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _selectedImages.add(imageFile);
    });

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      String extractedText = recognizedText.text;

      if (extractedText.isEmpty) {
        _showError('Không tìm thấy văn bản trong ảnh');
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _sourceController.text = extractedText;
        _isLoading = false;
      });

      // Tự động dịch sau khi nhận diện
      await _translateText();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Lỗi nhận diện văn bản: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _listenVoiceForTranslation() async {
    try {
      final result = await _channel.invokeMethod('startSpeechRecognition');

      if (result != null && result.toString().isNotEmpty) {
        setState(() {
          _sourceController.text = result.toString();
        });
        await _translateText();
      }
    } catch (e) {
      _showError('Lỗi nhận giọng nói: ${e.toString()}');
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;

      final tempText = _sourceController.text;
      _sourceController.text = _translatedText;
      _translatedText = tempText;
    });
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF415A77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chọn nguồn ảnh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildPickerOption(
              icon: Icons.camera_alt,
              title: 'Chụp ảnh',
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            const SizedBox(height: 12),
            _buildPickerOption(
              icon: Icons.photo_library,
              title: 'Chọn từ thư viện',
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF0D1B2A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9FFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4A9FFF)),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1B263B),
        title: const Text(
          'Dịch thuật',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF778DA9)),
            onPressed: () {
              // TODO: Show translation history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLanguageSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSourceTextBox(),
                  const SizedBox(height: 16),
                  if (_selectedImages.isNotEmpty) _buildSelectedImages(),
                  if (_selectedImages.isNotEmpty) const SizedBox(height: 16),
                  _buildTranslatedTextBox(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1B263B),
        border: Border(
          bottom: BorderSide(color: Color(0xFF415A77), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildLanguageDropdown(_sourceLang, true)),
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Color(0xFF4A9FFF)),
            onPressed: _swapLanguages,
          ),
          Expanded(child: _buildLanguageDropdown(_targetLang, false)),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(String currentLang, bool isSource) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: currentLang,
        isExpanded: true,
        dropdownColor: const Color(0xFF1B263B),
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF778DA9)),
        items: _languages.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              if (isSource) {
                _sourceLang = value;
              } else {
                _targetLang = value;
              }
            });
            if (_sourceController.text.isNotEmpty) {
              _translateText();
            }
          }
        },
      ),
    );
  }

  Widget _buildSourceTextBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF415A77).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _languages[_sourceLang]!,
                style: const TextStyle(
                  color: Color(0xFF778DA9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_sourceController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  color: const Color(0xFF778DA9),
                  onPressed: () {
                    setState(() {
                      _sourceController.clear();
                      _translatedText = '';
                      _selectedImages.clear();
                    });
                  },
                ),
            ],
          ),
          TextField(
            controller: _sourceController,
            maxLines: 6,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'Nhập văn bản cần dịch...',
              hintStyle: TextStyle(color: Color(0xFF415A77)),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedImages() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1B263B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImages[index],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(28, 28),
                    ),
                    onPressed: () {
                      setState(() => _selectedImages.removeAt(index));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTranslatedTextBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A9FFF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _languages[_targetLang]!,
                style: const TextStyle(
                  color: Color(0xFF4A9FFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_translatedText.isNotEmpty)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 20),
                      color: const Color(0xFF778DA9),
                      onPressed: () {
                        // TODO: Copy to clipboard
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20),
                      color: const Color(0xFF778DA9),
                      onPressed: () {
                        // TODO: Text to speech
                      },
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Color(0xFF4A9FFF)),
              ),
            )
          else
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                _translatedText.isEmpty ? 'Bản dịch...' : _translatedText,
                style: TextStyle(
                  color: _translatedText.isEmpty
                      ? const Color(0xFF415A77)
                      : Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBottomButton(
            icon: Icons.mic,
            label: 'Giọng nói',
            onTap: _listenVoiceForTranslation,
          ),
          const SizedBox(width: 12),
          _buildBottomButton(
            icon: Icons.photo_camera,
            label: 'Ảnh',
            onTap: _showImagePickerOptions,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _translateText,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9FFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Dịch',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF415A77),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
