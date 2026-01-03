import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes/route_names.dart';
import '../../data/models/register_request_model.dart';

class RegisterForm extends StatefulWidget {
  final void Function(RegisterRequestModel request) onRegister;
  final List<Map<String, dynamic>> countries; // [{id: int, name: string}]

  const RegisterForm({super.key, required this.onRegister, required this.countries});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _companyController = TextEditingController();
  final _websiteController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int? _selectedUserType = AppConstants.userTypeExporter; // Exporter selected by default
  int? _selectedCountryId;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _companyController.dispose();
    _websiteController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCountryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a country')));
        return;
      }

      // Build website URL with https:// prefix if provided
      String? website = _websiteController.text.trim();
      if (website.isNotEmpty && !website.startsWith('http')) {
        website = 'https://$website';
      }

      final request = RegisterRequestModel(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        companyName: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        website: website.isEmpty ? null : website,
        address: null,
        userTypeId: _selectedUserType,
        countryId: _selectedCountryId!,
        fcmToken: null,
      );

      widget.onRegister(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
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
            // Logo
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                child: const Icon(Icons.public, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Create Your Account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'Join E Market and start exploring global export opportunities today.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            // Full Name
            AppTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _fullNameController,
              prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Email Address
            AppTextField(
              label: 'Email Address',
              hint: 'name@company.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
              validator: Validators.email,
            ),
            const SizedBox(height: 20),
            // Phone Number
            AppTextField(
              label: 'Phone Number',
              hint: '+1 (555) 000-0000',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600]),
              validator: Validators.phone,
            ),
            const SizedBox(height: 20),
            // WhatsApp Number
            AppTextField(
              label: 'WhatsApp Number',
              hint: '+1 (555) 000-0000',
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            // Company Name
            AppTextField(
              label: 'Company Name',
              hint: 'Enter company name',
              controller: _companyController,
              prefixIcon: Icon(Icons.business_outlined, color: Colors.grey[600]),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter company name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Company Country
            DropdownButtonFormField<int>(
              value: _selectedCountryId,
              decoration: InputDecoration(
                labelText: 'Company Country',
                hintText: 'Select country',
                prefixIcon: Icon(Icons.public_outlined, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
              items: widget.countries.map((country) {
                return DropdownMenuItem(value: country['id'] as int, child: Text(country['name'] as String));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCountryId = value),
              validator: (value) {
                if (value == null) {
                  return 'Please select a country';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Company Type - Segmented Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Type',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompanyTypeButton(
                        label: 'Exporter',
                        icon: Icons.trending_up,
                        value: AppConstants.userTypeExporter,
                        isSelected: _selectedUserType == AppConstants.userTypeExporter,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompanyTypeButton(
                        label: 'Importer',
                        icon: Icons.trending_down,
                        value: AppConstants.userTypeImporter,
                        isSelected: _selectedUserType == AppConstants.userTypeImporter,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Company Website (Optional)
            TextFormField(
              controller: _websiteController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Company Website (Optional)',
                hintText: 'example.com',
                prefixIcon: Icon(Icons.public_outlined, color: Colors.grey[600]),
                prefixText: 'https://',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  return Validators.url(value);
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Password
            AppTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[600]),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: Validators.password,
            ),
            const SizedBox(height: 20),
            // Confirm Password
            AppTextField(
              label: 'Confirm Password',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icon(Icons.refresh_outlined, color: Colors.grey[600]),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[600]),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: 32),
            // Register Button
            AppButton(text: 'Create Account', onPressed: _handleSubmit, backgroundColor: AppTheme.primaryBlue, textColor: Colors.white),
            const SizedBox(height: 24),
            // Sign in link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                TextButton(
                  onPressed: () {
                    context.go(RouteNames.login);
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(
                    'Sign in',
                    style: TextStyle(color: AppTheme.primaryBlue, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyTypeButton({required String label, required IconData icon, required int value, required bool isSelected}) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserType = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[const SizedBox(width: 4), Icon(Icons.check, size: 16, color: Colors.white)],
          ],
        ),
      ),
    );
  }
}
