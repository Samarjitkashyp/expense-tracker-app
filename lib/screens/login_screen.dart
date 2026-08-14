import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    bool success;

    if (_isLogin) {
      success = await authNotifier.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await authNotifier.signup(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Login successful!' : 'Account registered successfully!'),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C1B), // Midnight blue
              Color(0xFF1E1435), // Dark deep purple
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing logo/title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.tealAccent, Colors.purpleAccent],
                  ).createShader(bounds),
                  child: const Text(
                    'SPENDWISE',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your budget in style',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 40),
                
                // Form Container Card
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2C).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isLogin ? 'Sign In' : 'Create Account',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Error message banner
                        if (authState.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    authState.errorMessage!,
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Username Input
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Username or Email',
                            labelStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(Icons.person_outline, color: Colors.tealAccent),
                            filled: true,
                            fillColor: const Color(0xFF131320),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.tealAccent),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.redAccent),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                            ),
                          ),
                           validator: (value) {
                             if (value == null || value.trim().isEmpty) {
                               return 'Please enter your username or email';
                             }
                             if (value.trim().length > 50) {
                               return 'Username or email is too long';
                             }
                             final regex = RegExp(r'^[a-zA-Z0-9._@+-]+$');
                             if (!regex.hasMatch(value.trim())) {
                               return 'Invalid characters in username or email';
                             }
                             if (!_isLogin) {
                               if (value.trim().length < 3 || value.trim().length > 20) {
                                 return 'Username must be between 3 and 20 characters';
                               }
                               final userRegex = RegExp(r'^[a-zA-Z0-9._]+$');
                               if (!userRegex.hasMatch(value.trim())) {
                                 return 'Username can only contain letters, numbers, dot (.) and underscore (_)';
                               }
                             }
                             return null;
                           },
                        ),
                        if (!_isLogin) ...[
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '• 3-20 characters, only letters, numbers, dot (.) or underscore (_)',
                              style: TextStyle(color: Colors.white30, fontSize: 10),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '• Enter your registered username or email address',
                              style: TextStyle(color: Colors.white30, fontSize: 10),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Email Input (Signup only)
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.tealAccent),
                              filled: true,
                              fillColor: const Color(0xFF131320),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.tealAccent),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!regex.hasMatch(value.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '• Enter a valid email (e.g. user@example.com)',
                              style: TextStyle(color: Colors.white30, fontSize: 10),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Password Input
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.white),
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.tealAccent),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white38,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF131320),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.tealAccent),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.redAccent),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length > 100) {
                              return 'Password is too long';
                            }
                            if (!_isLogin) {
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Password must contain at least one uppercase letter';
                              }
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return 'Password must contain at least one lowercase letter';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return 'Password must contain at least one digit';
                              }
                              if (!RegExp(r'[!@#$&*~%]').hasMatch(value)) {
                                return r'Password must contain at least one special character (!@#$&*~%)';
                              }
                            } else {
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                            }
                            return null;
                          },
                        ),
                        if (!_isLogin) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• Minimum 8 characters', style: TextStyle(color: Colors.white30, fontSize: 10)),
                                const SizedBox(height: 2),
                                const Text('• At least one uppercase & one lowercase letter', style: TextStyle(color: Colors.white30, fontSize: 10)),
                                const SizedBox(height: 2),
                                Text(r'• At least one number & one special symbol (!@#$&*~%)', style: const TextStyle(color: Colors.white30, fontSize: 10)),
                              ],
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '• Enter your account password to sign in',
                              style: TextStyle(color: Colors.white30, fontSize: 10),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),

                        // Login/Signup Button
                        ElevatedButton(
                          onPressed: authState.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent,
                            foregroundColor: const Color(0xFF0F0C1B),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: Colors.tealAccent.withOpacity(0.3),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0F0C1B),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Sign In' : 'Get Started',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Toggle Mode Link
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    _formKey.currentState?.reset();
                                  });
                                },
                          child: Text(
                            _isLogin ? 'New to SpendWise? Sign Up' : 'Already have an account? Sign In',
                            style: const TextStyle(color: Colors.tealAccent),
                          ),
                        ),
                      ],
                    ),
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
