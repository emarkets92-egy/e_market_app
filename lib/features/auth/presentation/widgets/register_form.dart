import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final _companyController = TextEditingController();
  final _websiteController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Multiple inputs - lists of controllers
  final List<TextEditingController> _emailControllers = [TextEditingController()];
  final List<TextEditingController> _phoneControllers = [];
  final List<TextEditingController> _whatsappControllers = [];
  final List<TextEditingController> _addressControllers = [];

  int? _selectedUserType = AppConstants.userTypeExporter; // Exporter selected by default
  int? _selectedCountryId;
  final List<int> _additionalCountryIds = []; // Additional countries
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyController.dispose();
    _websiteController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    for (var controller in _whatsappControllers) {
      controller.dispose();
    }
    for (var controller in _addressControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'please_confirm_password'.tr();
    }
    if (value != _passwordController.text) {
      return 'passwords_do_not_match'.tr();
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCountryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('please_select_country'.tr())));
        return;
      }

      // Validate at least one email
      final emails = _emailControllers.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList();
      if (emails.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('please_enter_email_address'.tr())));
        return;
      }

      // Build website URL with https:// prefix if provided
      String? website = _websiteController.text.trim();
      if (website.isNotEmpty && !website.startsWith('http')) {
        website = 'https://$website';
      }

      // Collect phones, whatsapps, addresses (filter empty values)
      final phones = _phoneControllers.map((c) => c.text.trim()).where((p) => p.isNotEmpty).toList();
      final whatsapps = _whatsappControllers.map((c) => c.text.trim()).where((w) => w.isNotEmpty).toList();
      final addresses = _addressControllers.map((c) => c.text.trim()).where((a) => a.isNotEmpty).toList();

      // Use first email as primary email, but send all as arrays
      final request = RegisterRequestModel(
        email: emails.first,
        password: _passwordController.text,
        name: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        companyName: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        phone: phones.isNotEmpty ? phones.first : null,
        whatsapp: whatsapps.isNotEmpty ? whatsapps.first : null,
        website: website.isEmpty ? null : website,
        address: addresses.isNotEmpty ? addresses.first : null,
        userTypeId: _selectedUserType,
        countryId: _selectedCountryId!,
        countries: _additionalCountryIds.isNotEmpty ? _additionalCountryIds : null,
        fcmToken: null,
        // Pass arrays directly
        emails: emails,
        phones: phones.isNotEmpty ? phones : null,
        whatsapps: whatsapps.isNotEmpty ? whatsapps : null,
        addresses: addresses.isNotEmpty ? addresses : null,
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
            Text(
              'create_your_account'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'join_e_market'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            // Full Name
            AppTextField(
              label: 'full_name'.tr(),
              hint: 'enter_full_name'.tr(),
              controller: _fullNameController,
              prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'please_enter_full_name'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Email Addresses (Multiple)
            _buildMultipleEmailsSection(),
            const SizedBox(height: 20),
            // Phone Numbers (Multiple)
            _buildMultiplePhonesSection(),
            const SizedBox(height: 20),
            // WhatsApp Numbers (Multiple)
            _buildMultipleWhatsappsSection(),
            const SizedBox(height: 20),
            // Addresses (Multiple)
            _buildMultipleAddressesSection(),
            const SizedBox(height: 20),
            // Company Name
            AppTextField(
              label: 'company_name'.tr(),
              hint: 'company_name'.tr(),
              controller: _companyController,
              prefixIcon: Icon(Icons.business_outlined, color: Colors.grey[600]),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '${'company_name'.tr()} is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Primary Company Country
            DropdownButtonFormField<int>(
              value: _selectedCountryId,
              decoration: InputDecoration(
                labelText: 'company_country'.tr(),
                hintText: 'select_country'.tr(),
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
              items: widget.countries
                  .where((country) => country['id'] != _selectedCountryId && !_additionalCountryIds.contains(country['id']))
                  .map((country) {
                return DropdownMenuItem(value: country['id'] as int, child: Text(country['name'] as String));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCountryId = value),
              validator: (value) {
                if (value == null) {
                  return 'please_select_country'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Additional Countries
            _buildAdditionalCountriesSection(),
            const SizedBox(height: 20),
            // Company Type - Segmented Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'company_type'.tr(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompanyTypeButton(
                        label: 'exporter'.tr(),
                        icon: Icons.trending_up,
                        value: AppConstants.userTypeExporter,
                        isSelected: _selectedUserType == AppConstants.userTypeExporter,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompanyTypeButton(
                        label: 'importer'.tr(),
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
                labelText: 'company_website_optional'.tr(),
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
              label: 'password'.tr(),
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
              label: 'confirm_password'.tr(),
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
            AppButton(text: 'create_account'.tr(), onPressed: _handleSubmit, backgroundColor: AppTheme.primaryBlue, textColor: Colors.white),
            const SizedBox(height: 24),
            // Sign in link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('already_have_account'.tr(), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                TextButton(
                  onPressed: () {
                    context.go(RouteNames.login);
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(
                    'sign_in'.tr(),
                    style: TextStyle(color: AppTheme.primaryBlue, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleEmailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'email_address'.tr(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _emailControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_emailControllers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index < _emailControllers.length - 1 ? 12 : 0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: index == 0 ? 'email_address'.tr() : '${'email_address'.tr()} ${index + 1}',
                    hint: 'email_hint'.tr(),
                    controller: _emailControllers[index],
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                    validator: index == 0
                        ? Validators.email
                        : (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              return Validators.email(value);
                            }
                            return null;
                          },
                  ),
                ),
                if (_emailControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _emailControllers[index].dispose();
                        _emailControllers.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMultiplePhonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'phone_number'.tr(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _phoneControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_phoneControllers.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${'phone_number'.tr()} (Optional)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ),
        ...List.generate(_phoneControllers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index < _phoneControllers.length - 1 ? 12 : 0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: '${'phone_number'.tr()} ${index + 1}',
                    hint: '+1 (555) 000-0000',
                    controller: _phoneControllers[index],
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600]),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        return Validators.phone(value);
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _phoneControllers[index].dispose();
                      _phoneControllers.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMultipleWhatsappsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'whatsapp_number'.tr(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _whatsappControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_whatsappControllers.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${'whatsapp_number'.tr()} (Optional)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ),
        ...List.generate(_whatsappControllers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index < _whatsappControllers.length - 1 ? 12 : 0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: '${'whatsapp_number'.tr()} ${index + 1}',
                    hint: '+1 (555) 000-0000',
                    controller: _whatsappControllers[index],
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(Icons.chat_bubble_outline, color: Colors.grey[600]),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _whatsappControllers[index].dispose();
                      _whatsappControllers.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMultipleAddressesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'address'.tr(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _addressControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_addressControllers.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${'address'.tr()} (Optional)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ),
        ...List.generate(_addressControllers.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index < _addressControllers.length - 1 ? 12 : 0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: '${'address'.tr()} ${index + 1}',
                    hint: 'Enter address',
                    controller: _addressControllers[index],
                    prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _addressControllers[index].dispose();
                      _addressControllers.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAdditionalCountriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Additional Countries',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            TextButton.icon(
              onPressed: () {
                // Show dialog to select additional country
                _showCountryPicker();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_additionalCountryIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Additional Countries (Optional)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ),
        ...List.generate(_additionalCountryIds.length, (index) {
          final countryId = _additionalCountryIds[index];
          final country = widget.countries.firstWhere((c) => c['id'] == countryId);
          return Padding(
            padding: EdgeInsets.only(bottom: index < _additionalCountryIds.length - 1 ? 8 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.public_outlined, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      country['name'] as String,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _additionalCountryIds.removeAt(index);
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showCountryPicker() {
    final availableCountries = widget.countries
        .where((country) => country['id'] != _selectedCountryId && !_additionalCountryIds.contains(country['id']))
        .toList();

    if (availableCountries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No more countries available')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_country'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableCountries.length,
            itemBuilder: (context, index) {
              final country = availableCountries[index];
              return ListTile(
                title: Text(country['name'] as String),
                onTap: () {
                  setState(() {
                    _additionalCountryIds.add(country['id'] as int);
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
        ],
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
