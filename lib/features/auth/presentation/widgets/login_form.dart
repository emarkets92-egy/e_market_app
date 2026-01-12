import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../config/theme.dart';

class LoginForm extends StatefulWidget {
  final void Function(String email, String password) onLogin;

  const LoginForm({super.key, required this.onLogin});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'exporter3@test.com';
    _passwordController.text = '123456';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onLogin(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      margin: const EdgeInsets.all(32),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome heading
            Text(
              'welcome_back'.tr(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text('please_enter_details'.tr(), style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 32),
            // Email field
            AppTextField(
              label: 'email_address'.tr(),
              hint: 'email_hint'.tr(),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            // Password field
            AppTextField(
              label: 'password'.tr(),
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: Validators.password,
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[600]),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            // Remember me and Forgot password
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
                    ),
                    Text('remember_me'.tr(), style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                  },
                  child: Text('forgot_password'.tr(), style: TextStyle(color: AppTheme.primaryBlue, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Login button
            AppButton(
              text: 'login'.tr(),
              onPressed: _handleSubmit,
              icon: Icons.arrow_forward,
              iconOnRight: true,
              backgroundColor: AppTheme.primaryBlue,
              textColor: Colors.white,
            ),
            const SizedBox(height: 32),
            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('dont_have_account'.tr(), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                TextButton(
                  onPressed: () {
                    context.go(RouteNames.register);
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(
                    'sign_up'.tr(),
                    style: TextStyle(color: AppTheme.primaryBlue, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Copyright footer
            Text(
              'copyright'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
