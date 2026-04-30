import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Sign-in / Sign-up / Continue as guest.
///
/// Hits LocalAuthService today; swap to FirebaseAuth later without changing
/// this widget — only the AuthService instance changes.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Mode { signIn, signUp }

class _LoginScreenState extends State<LoginScreen> {
  _Mode _mode = _Mode.signIn;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  bool _busy = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = LocalAuthService.instance;
      if (_mode == _Mode.signIn) {
        await auth.signInWithEmail(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      } else {
        await auth.registerWithEmail(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          displayName: _nameCtrl.text,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await LocalAuthService.instance.signInAnonymously();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not start guest session.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = _mode == _Mode.signUp;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAF8FF), Color(0xFFEDE5FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _logo(),
                const SizedBox(height: 28),
                Text(
                  isSignUp ? 'Create account' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF161633),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSignUp
                      ? 'Track your mood and grow your streak.'
                      : 'Sign in to keep your mood history.',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6F6B80),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                _formCard(isSignUp),
                const SizedBox(height: 14),
                if (_error != null) _errorBox(_error!),
                const SizedBox(height: 14),
                _primaryButton(isSignUp),
                const SizedBox(height: 14),
                _toggleMode(isSignUp),
                const SizedBox(height: 22),
                _divider(),
                const SizedBox(height: 16),
                _guestButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Center(
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C4DFF).withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(
          Icons.favorite_rounded,
          color: Colors.white,
          size: 38,
        ),
      ),
    );
  }

  Widget _formCard(bool isSignUp) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDE8FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isSignUp) ...[
            _textField(
              controller: _nameCtrl,
              icon: Icons.person_outline_rounded,
              hint: 'Your name',
            ),
            const SizedBox(height: 12),
          ],
          _textField(
            controller: _emailCtrl,
            icon: Icons.alternate_email_rounded,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _textField(
            controller: _passwordCtrl,
            icon: Icons.lock_outline_rounded,
            hint: 'Password',
            obscureText: _obscurePassword,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: const Color(0xFF8D889A),
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE8FF)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        style: const TextStyle(fontSize: 15, color: Color(0xFF24212D)),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF8D889A)),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8D889A)),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3DF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Color(0xFFCC4A4A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                color: Color(0xFFB23A3A),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(bool isSignUp) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3FD6).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _busy ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Text(
                isSignUp ? 'Create account' : 'Sign in',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Widget _toggleMode(bool isSignUp) {
    return Center(
      child: TextButton(
        onPressed: _busy
            ? null
            : () => setState(() {
                  _mode = isSignUp ? _Mode.signIn : _Mode.signUp;
                  _error = null;
                }),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF6F6B80), fontSize: 14),
            children: [
              TextSpan(
                text: isSignUp
                    ? 'Already have an account? '
                    : "Don't have an account? ",
              ),
              TextSpan(
                text: isSignUp ? 'Sign in' : 'Sign up',
                style: const TextStyle(
                  color: Color(0xFF6B3FD6),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: const Color(0xFF8D889A).withOpacity(0.25)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(color: Color(0xFF8D889A), fontSize: 13),
          ),
        ),
        Expanded(
          child: Divider(color: const Color(0xFF8D889A).withOpacity(0.25)),
        ),
      ],
    );
  }

  Widget _guestButton() {
    return OutlinedButton.icon(
      onPressed: _busy ? null : _continueAsGuest,
      icon: const Icon(Icons.person_outline_rounded),
      label: const Text('Continue as guest'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF6B3FD6),
        side: const BorderSide(color: Color(0xFFE5DFFF), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}
