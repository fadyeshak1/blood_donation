import 'package:blood_donation/core/theme/app_theme.dart';
import 'package:blood_donation/core/utils/constants.dart';
import 'package:blood_donation/core/utils/date_formatter.dart';
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

  final _hospitalNameController = TextEditingController();
  final _hospitalLocationController = TextEditingController();
  final _bloodQuantityController = TextEditingController(text: '1');

  String _selectedBloodType = AppConstants.bloodTypes[0];
  DateTime? _neededByDate;
  bool _isSubmitting = false;

  // Derived from selected date
  int? get _daysRemaining {
    if (_neededByDate == null) return null;
    return _neededByDate!.difference(DateTime.now()).inDays;
  }

  String? get _urgencyLabel {
    if (_daysRemaining == null) return null;
    return _daysRemaining! <= 3 ? 'Emergency' : 'Normal';
  }

  Color get _urgencyColor =>
      _urgencyLabel == 'Emergency' ? AppTheme.red : AppTheme.green;

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _hospitalLocationController.dispose();
    _bloodQuantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.red),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _neededByDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_neededByDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the blood receiving date'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final request = CreateRequestModel(
      bloodType: _selectedBloodType,
      hospitalName: _hospitalNameController.text.trim(),
      hospitalLocation: _hospitalLocationController.text.trim(),
      bloodQuantity: int.parse(_bloodQuantityController.text.trim()),
      neededByDate: _neededByDate!,
    );

    final success =
        await context.read<RequestsProvider>().createRequest(request);

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

            _buildSectionTitle('Blood Receiving Date'),
            const SizedBox(height: 8),
            _buildDatePicker(),
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

  // ─── Widgets ─────────────────────────────────────────────────────────────────

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
                        color:
                            isSelected ? AppTheme.white : AppTheme.black,
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

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _neededByDate != null
                    ? AppTheme.red
                    : AppTheme.grey.withValues(alpha: 0.3),
                width: _neededByDate != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color:
                      _neededByDate != null ? AppTheme.red : AppTheme.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _neededByDate != null
                        ? DateFormatter.formatDate(_neededByDate!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _neededByDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: _neededByDate != null
                          ? AppTheme.black
                          : AppTheme.grey,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.grey.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        // Auto urgency badge
        if (_urgencyLabel != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _urgencyLabel == 'Emergency'
                    ? Icons.warning_amber
                    : Icons.schedule,
                size: 16,
                color: _urgencyColor,
              ),
              const SizedBox(width: 6),
              Text(
                '$_daysRemaining ${_daysRemaining == 1 ? 'day' : 'days'} remaining — ',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF444444),
                ),
              ),
              Text(
                _urgencyLabel!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _urgencyColor,
                ),
              ),
            ],
          ),
        ],
      ],
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
              final current =
                  int.tryParse(_bloodQuantityController.text) ?? 1;
              if (current > 1) {
                _bloodQuantityController.text = (current - 1).toString();
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
                if (value == null || value.trim().isEmpty) return 'Required';
                final q = int.tryParse(value.trim());
                if (q == null || q < 1) return 'Min 1';
                if (q > 10) return 'Max 10';
                return null;
              },
            ),
          ),
          IconButton(
            onPressed: () {
              final current =
                  int.tryParse(_bloodQuantityController.text) ?? 1;
              if (current < 10) {
                _bloodQuantityController.text = (current + 1).toString();
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppTheme.grey.withValues(alpha: 0.3)),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}