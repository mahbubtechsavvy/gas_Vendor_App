import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme_config.dart';
import '../../config/app_config.dart';
import '../../widgets/modern_widgets.dart';
import 'enhanced_registration_screen.dart';
import 'forgot_password_screen.dart';
import '../../widgets/google_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (mounted && authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: ThemeConfig.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ThemeConfig.primaryStart.withValues(alpha: 0.1),
              ThemeConfig.secondaryStart.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Animated Logo
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: ThemeConfig.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: ThemeConfig.elevatedShadow,
                        ),
                        child: const Icon(
                          Icons.local_gas_station_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms),
                    ),
                    const SizedBox(height: 40),

                    // Welcome Text with Animation
                    Text(
                          'Welcome Back!',
                          style: ThemeConfig.heading1,
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: -0.2, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'Login to manage your vendor account',
                      style: ThemeConfig.bodyLarge.copyWith(
                        color: ThemeConfig.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 40),

                    // Glass Card with Form
                    GlassCard(
                      opacity: 0.6,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Mobile Number
                            ModernTextField(
                              controller: _mobileController,
                              label: 'Mobile Number',
                              hint: '+8801700000000',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your mobile number';
                                }
                                if (!RegExp(
                                  AppConfig.phoneRegex,
                                ).hasMatch(value)) {
                                  return 'Please enter a valid Bangladesh mobile number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password
                            ModernTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: ThemeConfig.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: ThemeConfig.primaryColor,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: ThemeConfig.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ThemeConfig.primaryColor,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 500.ms),
                            const SizedBox(height: 24),

                            // Login Button
                            GradientButton(
                              text: 'Login',
                              onPressed: _login,
                              isLoading: authProvider.isLoading,
                              icon: Icons.login_rounded,
                              height: 56,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).scale(),

                    const SizedBox(height: 40),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: ThemeConfig.borderColor,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR', style: ThemeConfig.bodySmall),
                        ),
                        Expanded(
                          child: Divider(
                            color: ThemeConfig.borderColor,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 24),

                    // Google Sign-In Button
                    GoogleSignInButton(
                      onSuccess: (vendorData) {
                        // Check approval status
                        final user = vendorData['user'];
                        // Safe check for is_approved (handle int or bool or string)
                        bool isApproved = false;
                        if (user['is_approved'] == 1 ||
                            user['is_approved'] == '1' ||
                            user['is_approved'] == true) {
                          isApproved = true;
                        }

                        if (isApproved) {
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/dashboard',
                            );
                          }
                        } else {
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Account Pending'),
                                content: const Text(
                                  'Your vendor account is waiting for admin approval.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      onError: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: ThemeConfig.errorColor,
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 650.ms),

                    const SizedBox(height: 30),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: ThemeConfig.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EnhancedRegistrationScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: ThemeConfig.primaryColor,
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) => ThemeConfig
                                .primaryGradient
                                .createShader(bounds),
                            child: Text(
                              'Register Now',
                              style: ThemeConfig.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
