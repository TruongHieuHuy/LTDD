import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/gaming_theme.dart';
import '../widgets/gaming/gaming_button.dart';
import '../widgets/gaming/gaming_text_field.dart';
import '../widgets/gaming/gaming_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoginMode = true; // true = Login, false = Register

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isLoginMode = _tabController.index == 0;
        _formKey.currentState?.reset();
      });
    });

    // Load saved email if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.savedEmail != null) {
        _emailController.text = authProvider.savedEmail!;
        setState(() {
          _rememberMe = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();

    try {
      final result = _isLoginMode
          ? await authProvider.login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              rememberMe: _rememberMe,
            )
          : await authProvider.register(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

      setState(() => _isLoading = false);

      if (result.success && mounted) {
        // Success - Navigate based on user role
        final role = authProvider.userRole;
        debugPrint(
          'Login success - Role: $role, isAdmin: ${authProvider.isAdmin}',
        );

        if (role == 'ADMIN' || role == 'MODERATOR') {
          // Navigate to Admin Dashboard
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/admin-dashboard', (route) => false);
        } else {
          // Navigate to main app for regular users
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/modular', (route) => false);
        }
      } else if (mounted) {
        // Show error using gaming dialog
        await GamingDialog.showError(
          context,
          title: 'Error',
          message: result.message,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        await GamingDialog.showError(
          context,
          title: 'Error',
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GamingTheme.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GamingTheme.l),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: GamingTheme.gamingGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: GamingTheme.neonGlow,
                  ),
                  child: const Icon(Icons.games, size: 64, color: Colors.white),
                ),
                const SizedBox(height: GamingTheme.xl),

                // Title
                Text(
                  'GAMING HUB',
                  style: GamingTheme.h1,
                ),
                const SizedBox(height: GamingTheme.xs),
                Text(
                  'Play • Compete • Conquer',
                  style: GamingTheme.bodyMedium.copyWith(
                    color: GamingTheme.primaryAccent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: GamingTheme.xl),

                // Tab Bar with Gaming Style
                Container(
                  decoration: BoxDecoration(
                    color: GamingTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
                    border: Border.all(color: GamingTheme.border),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
                      gradient: GamingTheme.primaryGradient,
                    ),
                    labelColor: Colors.white,
                    labelStyle: GamingTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelColor: GamingTheme.textSecondary,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'ĐĂNG NHẬP'),
                      Tab(text: 'ĐĂNG KÝ'),
                    ],
                  ),
                ),
                const SizedBox(height: GamingTheme.xl),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username field (Register only)
                      if (!_isLoginMode) ...[
                        GamingTextField(
                          controller: _usernameController,
                          hintText: 'Tên người dùng (3-20 ký tự)',
                          labelText: 'Username',
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập username';
                            }
                            if (value.trim().length < 3 ||
                                value.trim().length > 20) {
                              return 'Username phải từ 3-20 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: GamingTheme.m),
                      ],

                      // Email Field
                      GamingTextField(
                        controller: _emailController,
                        hintText: 'example@email.com',
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          final authProvider = context.read<AuthProvider>();
                          if (!authProvider.isValidEmail(value.trim())) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: GamingTheme.m),

                      // Password Field
                      GamingTextField(
                        controller: _passwordController,
                        hintText: _isLoginMode
                            ? 'Nhập mật khẩu'
                            : 'Tối thiểu 6 ký tự',
                        labelText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        onSuffixIconTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập password';
                          }
                          if (value.length < 6) {
                            return 'Password phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: GamingTheme.m),

                      // Confirm Password Field (Register only)
                      if (!_isLoginMode) ...[
                        GamingTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Nhập lại mật khẩu',
                          labelText: 'Xác nhận Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onSuffixIconTap: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng xác nhận password';
                            }
                            if (value != _passwordController.text) {
                              return 'Mật khẩu không khớp';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: GamingTheme.m),
                      ],

                      // Remember Me & Forgot Password (Login only)
                      if (_isLoginMode)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: GamingTheme.primaryAccent,
                                  checkColor: GamingTheme.primaryDark,
                                ),
                                Text(
                                  'Ghi nhớ',
                                  style: GamingTheme.bodyMedium,
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              child: Text(
                                'Quên mật khẩu?',
                                style: GamingTheme.bodyMedium.copyWith(
                                  color: GamingTheme.primaryAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: GamingTheme.l),

                      // Submit Button
                      GamingButton(
                        text: _isLoginMode ? 'ĐĂNG NHẬP' : 'ĐĂNG KÝ',
                        style: GamingButtonStyle.primary,
                        onPressed: _isLoading ? null : _handleSubmit,
                        isLoading: _isLoading,
                        width: double.infinity,
                        icon: _isLoginMode ? Icons.login : Icons.app_registration,
                      ),
                      const SizedBox(height: GamingTheme.l),

                      // Info Box
                      Container(
                        padding: const EdgeInsets.all(GamingTheme.m),
                        decoration: BoxDecoration(
                          color: GamingTheme.primaryAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
                          border: Border.all(
                            color: GamingTheme.primaryAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: GamingTheme.primaryAccent,
                              size: 20,
                            ),
                            const SizedBox(width: GamingTheme.s),
                            Expanded(
                              child: Text(
                                _isLoginMode
                                    ? 'Backend API: localhost:3000'
                                    : 'Tạo tài khoản để chinh phục các thử thách',
                                style: GamingTheme.bodySmall.copyWith(
                                  color: GamingTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
