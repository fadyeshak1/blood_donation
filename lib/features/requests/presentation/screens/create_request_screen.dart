import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/constants.dart';
import 'package:blood_donation/features/requests/data/models/create_request_model.dart';
import 'package:blood_donation/features/requests/presentation/providers/requests_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _chronicDiseasesController;
  late final TextEditingController _hospitalNameController;
  late final TextEditingController _hospitalLocationController;
  late final TextEditingController _bloodQuantityController;
  
  String _selectedBloodType = AppConstants.bloodTypes[0];
  String _selectedUrgency = 'Normal';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _chronicDiseasesController = TextEditingController();
    _hospitalNameController = TextEditingController();
    _hospitalLocationController = TextEditingController();
    _bloodQuantityController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _chronicDiseasesController.dispose();
    _hospitalNameController.dispose();
    _hospitalLocationController.dispose();
    _bloodQuantityController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final request = CreateRequestModel(
      bloodType: _selectedBloodType,
      chronicDiseases: _chronicDiseasesController.text.trim(),
      urgency: _selectedUrgency.toLowerCase(),
      hospitalName: _hospitalNameController.text.trim(),
      hospitalLocation: _hospitalLocationController.text.trim(),
      bloodQuantity: int.parse(_bloodQuantityController.text.trim()),
    );

    final success = await context.read<RequestsProvider>().createRequest(request);

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request created successfully!'),
            backgroundColor: AppTheme.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create request'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Blood Request'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.red,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.check),
              tooltip: 'Submit',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Blood Type Required'),
            const SizedBox(height: 8),
            _buildBloodTypeSelector(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Patient Information'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _chronicDiseasesController,
              label: 'Chronic Diseases',
              hint: 'Enter any chronic diseases (e.g., Diabetes, Hypertension)',
              icon: Icons.medical_information,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter chronic diseases or type "None"';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Request Priority'),
            const SizedBox(height: 8),
            _buildUrgencySelector(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Hospital Information'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _hospitalNameController,
              label: 'Hospital Name',
              hint: 'Enter hospital name',
              icon: Icons.local_hospital,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter hospital name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _hospitalLocationController,
              label: 'Hospital Location',
              hint: 'Enter hospital location/address',
              icon: Icons.location_on,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter hospital location';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Blood Quantity'),
            const SizedBox(height: 8),
            _buildQuantitySelector(),
            const SizedBox(height: 32),
            
            _buildSubmitButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.black,
      ),
    );
  }

  Widget _buildBloodTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bloodtype, color: AppTheme.red, size: 20),
              SizedBox(width: 8),
              Text(
                'Select Blood Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.bloodTypes.map((type) {
              final isSelected = _selectedBloodType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedBloodType = type),
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.red
                        : AppTheme.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.red : AppTheme.grey,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.white : AppTheme.black,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: AppTheme.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Request Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildUrgencyOption(
                  'Normal',
                  'Regular donation needed',
                  Icons.schedule,
                  AppTheme.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUrgencyOption(
                  'Emergency',
                  'Urgent donation required',
                  Icons.warning_amber,
                  AppTheme.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyOption(
    String type,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedUrgency == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedUrgency = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppTheme.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppTheme.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : AppTheme.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.grey.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: AppTheme.red, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Units Needed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              final currentValue = int.tryParse(_bloodQuantityController.text) ?? 1;
              if (currentValue > 1) {
                _bloodQuantityController.text = (currentValue - 1).toString();
              }
            },
            icon: const Icon(Icons.remove_circle_outline),
            color: AppTheme.red,
          ),
          SizedBox(
            width: 60,
            child: TextFormField(
              controller: _bloodQuantityController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                final quantity = int.tryParse(value.trim());
                if (quantity == null || quantity < 1) {
                  return 'Min 1';
                }
                if (quantity > 10) {
                  return 'Max 10';
                }
                return null;
              },
            ),
          ),
          IconButton(
            onPressed: () {
              final currentValue = int.tryParse(_bloodQuantityController.text) ?? 1;
              if (currentValue < 10) {
                _bloodQuantityController.text = (currentValue + 1).toString();
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.red,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.red, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.white,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.white,
              ),
            )
          : const Text(
              'Create Request',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}