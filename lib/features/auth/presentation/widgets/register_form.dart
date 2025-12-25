import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/register_request_model.dart';

class RegisterForm extends StatefulWidget {
  final void Function(RegisterRequestModel request) onRegister;
  final List<Map<String, dynamic>> countries; // [{id: int, name: string}]

  const RegisterForm({
    super.key,
    required this.onRegister,
    required this.countries,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();

  int? _selectedUserType = AppConstants.userTypeImporter;
  int? _selectedCountryId;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCountryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a country')),
        );
        return;
      }

      final request = RegisterRequestModel(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        companyName: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        userTypeId: _selectedUserType,
        countryId: _selectedCountryId!,
        fcmToken: null, // Not implemented yet
      );

      widget.onRegister(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            AppTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
              validator: Validators.password,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Name',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Company Name',
              controller: _companyController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'WhatsApp',
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Website',
              controller: _websiteController,
              keyboardType: TextInputType.url,
              validator: Validators.url,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Address',
              controller: _addressController,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedUserType,
              decoration: const InputDecoration(labelText: 'User Type'),
              items: const [
                DropdownMenuItem(value: AppConstants.userTypeImporter, child: Text('Importer')),
                DropdownMenuItem(value: AppConstants.userTypeExporter, child: Text('Exporter')),
              ],
              onChanged: (value) => setState(() => _selectedUserType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedCountryId,
              decoration: const InputDecoration(labelText: 'Country *'),
              items: widget.countries.map((country) {
                return DropdownMenuItem(
                  value: country['id'] as int,
                  child: Text(country['name'] as String),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCountryId = value),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Register',
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

